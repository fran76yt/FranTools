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

Los enemigos con los que no estáis en combate ni tú ni tu mascota no llevan
nada. Para cualquier clase; se apaga en la página General de /fran config o
con /fran agro.

El cliente de Forever es el moderno, que en combate puede ocultar la amenaza
a los addons ("valor secreto", ver Core/Api.lua). Si pasa, no hay nada que
pintar: se quitan los marcos y se explica una vez por sesión en el chat, en
lugar de dar un error de Lua cada vez.
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

local function percentText(player)
    if not player then return "" end
    return ("%d%%"):format(math.floor(player.percent + 0.5))
end

local secretNoticeShown = false

local function onSecretThreat()
    if secretNoticeShown then return end
    secretNoticeShown = true
    Util.Print("este cliente no deja a los addons leer la amenaza en combate, así que el agro en las barras de nombre no puede funcionar aquí. /fran agro para apagarlo.")
end

-- Color y texto para la barra de unit, o nil si no lleva nada.
local function display(unit)
    if not Threat.IsEnabled() or not Api.CanAttack(unit) then return nil end
    local player, playerSecret = Api.Threat("player", unit)
    local pet, petSecret = Api.Threat("pet", unit)
    if playerSecret or petSecret then
        onSecretThreat()
        return nil
    end
    if not player and not pet then return nil end
    return C.COLOR[situation(player, pet)], percentText(player)
end

--------------------------------------------------------------------------------
-- Actualizar
--------------------------------------------------------------------------------

function Threat.Update(unit)
    local plate = Api.NamePlateFor(unit)
    if not plate then return end
    local color, text = display(unit)
    if color then
        ns.ThreatBadge.Show(plate, color, text)
    else
        ns.ThreatBadge.Hide(plate)
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
for _, event in ipairs({ "UNIT_THREAT_LIST_UPDATE", "UNIT_THREAT_SITUATION_UPDATE",
                         "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "UNIT_PET" }) do
    Util.On(event, updateSoon)
end

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

local function threatText(t, secret)
    if secret then return "oculta por el juego (valor secreto): el addon no puede leerla" end
    if not t then return "nada (no estáis en combate)" end
    return ("tanqueando %s, situación %s, %s%%"):format(yesNo(t.tanking), tostring(t.status), tostring(t.percent))
end

local function statusLines(unit)
    local plate = Api.NamePlateFor(unit)
    local badge = plate and ns.ThreatBadge.Get(plate)
    return {
        ("aviso: %s"):format(Threat.IsEnabled() and "encendido" or "apagado (/fran agro)"),
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
