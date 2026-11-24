--[[
Aviso de "ya puedes usarlo"
===========================

Motor de los avisos de hechizos que solo se pueden usar un rato tras algo:
Revancha del guerrero (tras bloquear, esquivar o parar), y cualquier otro
del mismo tipo (Abrumar, Mordedura de mangosta...). Cada uno es una
descripción:

  ns.Revenge = ns.ReadyWarning.Create({
      key = "revenge",                     -- sus preferencias (Storage.Get)
      boxName = "FranToolsRevengeNotice",  -- nombre global del recuadro
      classes = { WARRIOR = true },
      spells = { 6572, 6574, ... },        -- rangos, de menor a mayor
      label = "Revancha",
      tooltip = { ... },
  })

Mientras el juego diga que se puede lanzar (Api.IsSpellUsable, que no se
oculta en combate), un recuadro verde con su icono (UI/NoticeBox.lua). Solo
en combate, que es donde tiene sentido, y solo si ya lo has aprendido.

Cada aviso creado tiene IsEnabled/SetEnabled/Toggle y Check.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage

local ReadyWarning = {}
ns.ReadyWarning = ReadyWarning

-- Cuándo puede cambiar: el juego avisa de que algo se puede usar o ha
-- dejado de poderse; entrar o salir de combate; aprender un rango; morir.
local CHECK_EVENTS = { "SPELL_UPDATE_USABLE", "ACTIONBAR_UPDATE_USABLE", "PLAYER_REGEN_DISABLED",
                       "PLAYER_REGEN_ENABLED", "SPELLS_CHANGED", "PLAYER_DEAD", "PLAYER_ALIVE",
                       "PLAYER_ENTERING_WORLD" }

-- Si toca mirar: encendido, de su clase, vivo y en combate.
local function applies(w)
    return w.IsEnabled() and w.def.classes[Api.PlayerClass()] and not Api.IsDead() and Util.InCombat()
end

-- Icono, texto y nivel del aviso, o nil si no hay nada que avisar.
local function notice(w)
    if not applies(w) then return nil end
    local spell = Api.KnownSpell(w.def.spells)
    if not spell or not Api.IsSpellUsable(spell) then return nil end
    return Api.SpellIcon(spell), w.def.label, "ready"
end

function ReadyWarning.Create(def)
    local w = { def = def }
    local function settings() return Storage.Get(def.key) end
    w.box = ns.NoticeBox.Create({ name = def.boxName, settings = settings, tooltip = def.tooltip })
    function w.Check()
        w.box:ShowIf(notice(w))
    end
    local switch = Util.Switch(settings, w.Check)
    w.IsEnabled, w.SetEnabled, w.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
    -- Revancha dura poco: se agrupa lo justo para no repintar diez veces.
    local checkSoon = Util.Debounce(Const.READY_CHECK_DELAY, w.Check)
    for _, event in ipairs(CHECK_EVENTS) do Util.On(event, checkSoon) end
    return w
end
