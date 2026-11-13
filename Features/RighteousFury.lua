--[[
Aviso de Furia justa
====================

Furia justa (Righteous Fury) hace que el daño sagrado del paladín genere
mucha más amenaza: la tiene que llevar el paladín que tanquea y quitársela el
que no, para no robarle los enemigos al tanque. En grupo, un recuadro
(UI/NoticeBox.lua) avisa cuando no toca:

  tanqueas y no la llevas      -> borde ámbar, "Sin Furia justa"
  no tanqueas y la llevas      -> borde rojo, "Furia justa: quítala"

Solo, no avisa: un paladín protección la lleva aunque no haya tanque. Quién
tanquea lo dice el rol del grupo (el del buscador de grupo, si el cliente lo
tiene y está puesto); si no, la casilla "Tanqueo yo" de la ventana.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage
local P = Const.PALADIN

local RighteousFury = {}
ns.RighteousFury = RighteousFury

local function settings()
    return Storage.Get("righteousFury")
end

local fury = ns.Buffs.List({ { key = "righteousFury", spells = { P.RIGHTEOUS_FURY } } })

--------------------------------------------------------------------------------
-- Preferencias
--------------------------------------------------------------------------------

-- Si el jugador ha dicho que tanquea (para cuando el juego no sabe su rol).
function RighteousFury.IsManualTank()
    return settings().tank == true
end

function RighteousFury.SetManualTank(on)
    settings().tank = on or nil
    RighteousFury.Check()
    Util.Fire(Const.MSG.SETTINGS_CHANGED)
end

-- El rol del grupo manda; sin rol, la casilla.
function RighteousFury.IsTank()
    local role = Api.GroupRole()
    if role then return role == P.TANK_ROLE end
    return RighteousFury.IsManualTank()
end

--------------------------------------------------------------------------------
-- Aviso
--------------------------------------------------------------------------------

local function applies()
    return RighteousFury.IsEnabled() and Api.PlayerClass() == "PALADIN" and Api.IsInGroup()
        and not Api.IsDead() and Api.IsSpellKnown(P.RIGHTEOUS_FURY)
end

-- Texto y nivel del aviso, o nil si está como toca.
-- Si la lleva se lee aunque no toque avisar, para recordarlo de cara al
-- combate (en combate el juego puede ocultarla: ver Core/Buffs.lua).
local function notice()
    if Api.PlayerClass() ~= "PALADIN" then return nil end
    local wearing = fury:Current() ~= nil
    if not applies() then return nil end
    local tank = RighteousFury.IsTank()
    if tank and not wearing then return "Sin Furia justa", "warning" end
    if wearing and not tank then return "Furia justa: quítala", "critical" end
end

local box = ns.NoticeBox.Create({
    name = "FranToolsRighteousFuryNotice",
    settings = settings,
    tooltip = {
        "Furia justa",
        "Ámbar: tanqueas y no la llevas. Rojo: la llevas sin tanquear.",
        "Quién tanquea lo dice el rol del grupo o la casilla Tanqueo yo de /fran config.",
        "Arrástralo para moverlo.",
    },
})

function RighteousFury.Check()
    local text, level = notice()
    box:ShowIf(Api.SpellIcon(P.RIGHTEOUS_FURY), text, level)
end

local checkSoon = Util.Debounce(P.CHECK_DELAY, RighteousFury.Check)

local function onPlayer(unit)
    if unit == "player" then checkSoon() end
end
-- Tras lanzar algo también: en combate es la única forma de saber que se la
-- ha puesto (Core/Buffs.lua).
Util.On("UNIT_AURA", onPlayer)
Util.On("UNIT_SPELLCAST_SUCCEEDED", onPlayer)
-- Al entrar o salir de un grupo, al cambiar los roles, al aprenderla y al
-- morir o revivir.
for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "GROUP_ROSTER_UPDATE", "PLAYER_ROLES_ASSIGNED",
                         "SPELLS_CHANGED", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST" }) do
    Util.On(event, checkSoon)
end

--------------------------------------------------------------------------------
-- API del módulo
--------------------------------------------------------------------------------

local switch = Util.Switch(settings, function() RighteousFury.Check() end)
RighteousFury.IsEnabled, RighteousFury.SetEnabled, RighteousFury.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
