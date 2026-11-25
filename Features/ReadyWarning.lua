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

Mientras se pueda usar, un recuadro verde con su icono (UI/NoticeBox.lua).
Solo en combate, que es donde tiene sentido, y solo si ya lo has aprendido.

Cómo se sabe que se puede usar, según la documentación de Forever:

  * Si el juego ilumina el hechizo en las barras de acción (Core/SpellGlow.lua),
    esa luz manda: sale con ella y se va con ella, justo cuando toca.
  * Si no lo ha iluminado nunca, se pregunta si se puede lanzar
    (Api.IsSpellUsable, que no se oculta en combate). El evento que avisa de
    esos cambios en Forever es ACTION_USABLE_CHANGED (el antiguo
    ACTIONBAR_UPDATE_USABLE está desactivado en sus barras), pero solo llega
    por lo que está en las barras; por eso en combate se pregunta además cada
    READY.POLL segundos.

Cada aviso creado tiene IsEnabled/SetEnabled/Toggle y Check.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage
local R = Const.READY

local ReadyWarning = {}
ns.ReadyWarning = ReadyWarning

-- Cuándo puede cambiar: entrar o salir de combate, aprender un rango, morir.
local CHECK_EVENTS = { "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "SPELLS_CHANGED",
                       "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_ENTERING_WORLD" }
-- Y los de "algo se puede usar o ha dejado de poderse", que cambian de un
-- cliente a otro: se escuchan los que existan.
local USABLE_EVENTS = { "ACTION_USABLE_CHANGED", "SPELL_UPDATE_USABLE", "ACTIONBAR_UPDATE_USABLE" }

--------------------------------------------------------------------------------
-- Si se puede usar
--------------------------------------------------------------------------------

local function anyRank(spells, test)
    for _, id in ipairs(spells) do
        if test(id) then return true end
    end
    return false
end

-- Con la luz del juego si alguna vez lo ha iluminado; si no, preguntando.
local function available(w, spell)
    if anyRank(w.def.spells, ns.SpellGlow.HasGlowed) then
        return anyRank(w.def.spells, ns.SpellGlow.IsGlowing)
    end
    return Api.IsSpellUsable(spell)
end

--------------------------------------------------------------------------------
-- Aviso
--------------------------------------------------------------------------------

-- Si toca mirar: encendido, de su clase y vivo (el combate se mira aparte).
local function watching(w)
    return w.IsEnabled() and w.def.classes[Api.PlayerClass()] and not Api.IsDead()
end

-- Icono, texto y nivel del aviso, o nil si no hay nada que avisar.
local function notice(w)
    if not watching(w) or not Util.InCombat() then return nil end
    local spell = Api.KnownSpell(w.def.spells)
    if not spell or not available(w, spell) then return nil end
    return Api.SpellIcon(spell), w.def.label, "ready"
end

-- En combate, pregunta cada POLL segundos mientras dure la pelea. Solo hay
-- una ronda en marcha a la vez.
local function poll(w)
    w.Check()
    if watching(w) and Util.InCombat() then
        Util.After(R.POLL, function() poll(w) end)
    else
        w.polling = false
    end
end

local function startPolling(w)
    if w.polling or not watching(w) then return end
    w.polling = true
    poll(w)
end

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

local function listenEvents(w)
    local checkSoon = Util.Debounce(R.CHECK_DELAY, w.Check)
    for _, event in ipairs(CHECK_EVENTS) do Util.On(event, checkSoon) end
    for _, event in ipairs(USABLE_EVENTS) do Util.OnIfExists(event, checkSoon) end
    -- La luz del juego es la señal más fina: se repinta al momento.
    Util.Listen(Const.MSG_SPELL_GLOW, function(spellID)
        if Util.Contains(w.def.spells, spellID) then w.Check() end
    end)
    Util.On("PLAYER_REGEN_DISABLED", function() startPolling(w) end)
end

function ReadyWarning.Create(def)
    local w = { def = def, polling = false }
    local function settings() return Storage.Get(def.key) end
    w.box = ns.NoticeBox.Create({ name = def.boxName, settings = settings, tooltip = def.tooltip })
    function w.Check()
        w.box:ShowIf(notice(w))
    end
    local switch = Util.Switch(settings, function()
        w.Check()
        if Util.InCombat() then startPolling(w) end
    end)
    w.IsEnabled, w.SetEnabled, w.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
    listenEvents(w)
    return w
end
