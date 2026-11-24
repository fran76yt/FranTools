--[[
Agro en las barras de nombre
============================

En la barra de nombre de cada enemigo con el que estás en combate, un marco
de color (UI/ThreatBadge.lua) según quién tiene el agro y tu porcentaje de
amenaza al lado (a 100 se lo quitas a quien lo tiene):

  rojo    va a por ti
  ámbar   aún no, pero estás a punto (te acercas a 100 o ya lo pasas)
  verde   lo tiene tu mascota
  gris    lo tiene otro (el tanque del grupo)

El ámbar va por delante del verde: es justo lo que interesa al cazador que
deja tanquear a la mascota, saber que está a punto de quitárselo.

Si tanqueas (Core/Role.lua: el rol del grupo o la casilla "Tanqueo yo"), lo
que importa es lo contrario, y los colores cambian:

  verde   va a por ti (o a por tu mascota): bien
  ámbar   va a por ti, pero otro está a punto de quitártelo
  rojo    se te ha escapado: va a por otro (un sanador, un DPS...)

Los enemigos con los que no estáis en combate ni tú ni tu mascota no llevan
nada. Para cualquier clase; se apaga en la página General de /fran config o
con /fran agro.

El cliente de Forever es el moderno, que en combate puede ocultar la amenaza
a los addons ("valor secreto", ver Core/Api.lua). Ocultar no es quitar: el
addon no puede mirarla, pero sí pasársela a la interfaz para que la pinte
(UI/ThreatBadge.lua, ShowSecret), con los mismos colores. Si el juego no
dejara ni eso, se quita el marco y se explica una vez por sesión en el chat,
en lugar de dar un error de Lua cada vez.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage
local C = Const.THREAT

local Threat = {}
ns.Threat = Threat

--------------------------------------------------------------------------------
-- Qué mostrar
--------------------------------------------------------------------------------

-- Situación del agro (una clave de Const.THREAT.COLOR) a partir de tu amenaza
-- y la de tu mascota; cualquiera de las dos puede ser nil.
local function situation(player, pet)
    if player and player.tanking then return "player" end
    if player and (player.status == 1 or player.percent >= C.WARN_PERCENT) then return "warning" end
    if pet and pet.tanking then return "pet" end
    return "other"
end

-- Lo mismo si tanqueas. status 2: va a por ti, pero otro tiene más amenaza.
local function tankSituation(player, pet)
    if player and player.tanking then
        return player.status == 2 and "shaky" or "held"
    end
    if pet and pet.tanking then return "held" end
    return "loose"
end

-- Colores para la amenaza oculta (ThreatBadge.ShowSecret). Ahí no se puede
-- distinguir el ámbar del tanque (haría falta mirar status), así que el
-- tanque solo ve verde o rojo.
local SCHEMES = {
    normal = { player = C.COLOR.player, pet = C.COLOR.pet, other = C.COLOR.other, warning = C.COLOR.warning },
    tank = { player = C.COLOR.held, pet = C.COLOR.held, other = C.COLOR.loose },
}

local function percentText(player)
    if not player then return "" end
    return C.PERCENT_FORMAT:format(player.percent)
end

-- Un campo de la amenaza que puede ser secreto: se devuelve tal cual, sin
-- mirarlo (ni siquiera "x or y", que ya es mirarlo). Sin amenaza, default.
local function raw(t, key, default)
    if not t then return default end
    local value = t[key]
    if Api.IsSecret(value) then return value end
    if value == nil then return default end
    return value
end

-- Lo que hay que pintar en la barra de unit, o nil si no lleva nada:
--   { color, text }    con la amenaza a la vista
--   { secret = true, scheme, tanking, petTanking, percent, hasPercent }
--                      con la amenaza oculta, para ThreatBadge.ShowSecret
local function display(unit)
    if not Threat.IsEnabled() or not Api.CanAttack(unit) then return nil end
    local player, pet = Api.Threat("player", unit), Api.Threat("pet", unit)
    if not player and not pet then return nil end
    local tank = ns.Role.IsTank()
    if raw(player, "secret", false) or raw(pet, "secret", false) then
        return {
            secret = true,
            scheme = tank and SCHEMES.tank or SCHEMES.normal,
            tanking = raw(player, "tanking", false),
            petTanking = raw(pet, "tanking", false),
            percent = raw(player, "percent", 0),
            hasPercent = player ~= nil,
        }
    end
    local key = tank and tankSituation(player, pet) or situation(player, pet)
    return { color = C.COLOR[key], text = percentText(player) }
end

--------------------------------------------------------------------------------
-- Actualizar
--------------------------------------------------------------------------------

local secretFailureShown = false

-- Si el juego no deja ni pintar la amenaza oculta, se explica una vez por
-- sesión (con el motivo, para saber qué ha fallado) en lugar de dar un error
-- de Lua en cada actualización.
local function onSecretFailure(reason)
    if secretFailureShown then return end
    secretFailureShown = true
    Util.Print(("este cliente oculta la amenaza en combate y no deja pintarla, así que el agro en las barras de nombre no funciona aquí (%s). /fran agro para apagarlo."):format(tostring(reason)))
end

local function showSecret(plate, look)
    local ok, reason = pcall(ns.ThreatBadge.ShowSecret, plate, look, look.scheme)
    if ok then return end
    ns.ThreatBadge.Hide(plate)
    onSecretFailure(reason)
end

function Threat.Update(unit)
    local plate = Api.NamePlateFor(unit)
    if not plate then return end
    local look = display(unit)
    if not look then
        ns.ThreatBadge.Hide(plate)
    elseif look.secret then
        showSecret(plate, look)
    else
        ns.ThreatBadge.Show(plate, look.color, look.text)
    end
end

function Threat.UpdateAll()
    for _, unit in ipairs(Api.NamePlateUnits()) do Threat.Update(unit) end
end

local updateSoon = Util.Debounce(C.UPDATE_DELAY, Threat.UpdateAll)

-- Una barra que aparece se pinta enseguida; una que se va se limpia, porque
-- el juego la reutilizará para otra unidad.
Util.On("NAME_PLATE_UNIT_ADDED", Threat.Update)
Util.On("NAME_PLATE_UNIT_REMOVED", function(unit)
    local plate = Api.NamePlateFor(unit)
    if plate then ns.ThreatBadge.Hide(plate) end
end)
-- Los de amenaza llegan sin parar en combate y no siempre con el token de la
-- barra (a veces "target"): se agrupan y se repasan todas. Al entrar o salir
-- de combate y al cambiar de mascota, lo mismo.
-- Al cambiar los roles del grupo o la casilla "Tanqueo yo", cambian los colores.
for _, event in ipairs({ "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE",
                         "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_PET",
                         "GROUP_ROSTER_UPDATE", "PLAYER_ROLES_ASSIGNED" }) do
    Util.On(event, updateSoon)
end
Util.Listen(Util.SETTINGS_CHANGED, updateSoon)

--------------------------------------------------------------------------------
-- API del módulo
--------------------------------------------------------------------------------

local switch = Util.Switch(Storage.GetThreat, function() Threat.UpdateAll() end)
Threat.IsEnabled, Threat.SetEnabled, Threat.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle

--------------------------------------------------------------------------------
-- Diagnóstico
--------------------------------------------------------------------------------
-- Si no se ve nada, cada paso del camino puede fallar en un cliente distinto
-- (sin amenaza, barras de nombre de otra forma...). Esto los repasa con el
-- objetivo para saber cuál, desde el chat: /fran agro estado.

local function yesNo(value)
    return value and "sí" or "no"
end

local function threatText(t)
    if not t then return "nada (no estáis en combate)" end
    if t.secret then return "oculta por el juego (valor secreto): el addon la pinta sin leerla" end
    return ("tanqueando %s, situación %s, %s%%"):format(yesNo(t.tanking), tostring(t.status), tostring(t.percent))
end

local function statusLines(unit)
    local plate = Api.NamePlateFor(unit)
    local badge = plate and ns.ThreatBadge.Get(plate)
    return {
        ("aviso: %s"):format(Threat.IsEnabled() and "encendido" or "apagado (/fran agro)"),
        ("colores: %s"):format(ns.Role.IsTank() and "de tanque (verde, va a por ti; rojo, se te escapa)" or "normales"),
        ("el juego da la amenaza: %s"):format(yesNo(Api.HasThreat())),
        ("objetivo: %s, enemigo: %s"):format(tostring(Api.UnitName(unit)), yesNo(Api.CanAttack(unit))),
        ("barra de nombre: %s"):format(plate and "sí" or "no (¿están a la vista? tecla V)"),
        ("barra de vida dentro: %s"):format(yesNo(plate and Api.NamePlateHealthBar(plate))),
        ("tu amenaza: %s"):format(threatText(Api.Threat("player", unit))),
        ("la de tu mascota: %s"):format(threatText(Api.Threat("pet", unit))),
        ("marco de agro: %s"):format(badge and (badge:IsShown() and "visible" or "oculto") or "sin crear"),
    }
end

function Threat.PrintStatus()
    if not Api.UnitName("target") then
        Util.Print("selecciona un enemigo y repite /fran agro estado.")
        return
    end
    Threat.Update("target")
    Util.Print("agro del objetivo, paso a paso:")
    for _, line in ipairs(statusLines("target")) do print("  " .. line) end
end
