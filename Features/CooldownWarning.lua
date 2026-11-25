--[[
Aviso de enfriamiento
=====================

Motor de los avisos "cuánto le queda a X": Provocar del guerrero, y
cualquier otro hechizo con enfriamiento que convenga tener a la vista. Cada
uno es una descripción:

  ns.TauntCooldown = ns.CooldownWarning.Create({
      key = "taunt",                      -- sus preferencias (Storage.Get)
      boxName = "FranToolsTauntNotice",   -- nombre global del recuadro
      classes = { WARRIOR = true },
      spells = { 355 },                   -- rangos, de menor a mayor
      label = "Provocar",
      cooldown = 8,                       -- segundos, si el juego no lo dice
      talents = { { spell, seconds } },   -- opcional: talentos que lo rebajan,
                                          -- el que más rebaja primero
      tooltip = { ... },
  })

Desde que lo usas hasta que vuelve a estar listo, un recuadro
(UI/NoticeBox.lua) con su icono apagado y los segundos que le quedan encima,
"Provocar: 5 s". Listo, no se ve: así solo aparece cuando hay algo que saber.

En combate el juego oculta los enfriamientos a los addons (valor secreto, ver
la documentación de C_Spell.GetSpellCooldown) y su reloj de enfriamiento no
acepta valores ocultos de un addon. Por eso la cuenta es propia: al lanzarlo
(UNIT_SPELLCAST_SUCCEEDED, que para tus hechizos no se oculta) empieza la
cuenta atrás de "cooldown" segundos, o los del talento que tengas. Si el
juego sí da el enfriamiento (fuera de combate), manda el suyo.

Por defecto solo en combate; se puede hacer que se vea también fuera. Cada aviso
creado tiene IsEnabled/SetEnabled/Toggle, IsCombatOnly/SetCombatOnly, Check
y Remaining (segundos que le quedan, 0 si está listo).
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage
local C = Const.COOLDOWN

local CooldownWarning = {}
ns.CooldownWarning = CooldownWarning

local CHECK_EVENTS = { "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED", "SPELLS_CHANGED",
                       "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_ENTERING_WORLD" }

--------------------------------------------------------------------------------
-- Cuánto dura
--------------------------------------------------------------------------------

-- Segundos de enfriamiento según los talentos que tengas.
local function ownCooldown(def)
    for _, talent in ipairs(def.talents or {}) do
        if Api.IsSpellKnown(talent.spell) then return talent.seconds end
    end
    return def.cooldown
end

-- Cuándo estará listo según el juego, o nil si no lo dice (en combate) o si
-- lo que dice es solo el enfriamiento global.
local function gameReadyAt(spell)
    local start, duration = Api.SpellCooldown(spell)
    if not start or duration <= C.GCD then return nil end
    return start + duration
end

--------------------------------------------------------------------------------
-- Aviso
--------------------------------------------------------------------------------

local function applies(w)
    return w.IsEnabled() and w.def.classes[Api.PlayerClass()] and not Api.IsDead()
        and (not w.IsCombatOnly() or Util.InCombat())
end

-- Icono, texto, nivel y extra del aviso, o nil si no hay nada que avisar.
local function notice(w)
    if not applies(w) then return nil end
    local spell = Api.KnownSpell(w.def.spells)
    if not spell then return nil end
    local left = math.ceil(w.Remaining())
    if left <= 0 then return nil end
    return Api.SpellIcon(spell), ("%s: %d s"):format(w.def.label, left), "warning", { badge = tostring(left), dim = true }
end

--------------------------------------------------------------------------------
-- Cuenta atrás
--------------------------------------------------------------------------------

-- Repinta cada TICK mientras quede algo; al acabar, un último repintado lo
-- quita. Solo hay una cuenta en marcha a la vez.
local function tick(w)
    w.Check()
    if w.Remaining() > 0 then
        Util.After(C.TICK, function() tick(w) end)
    else
        w.ticking = false
    end
end

local function startTicking(w)
    if w.ticking then return end
    w.ticking = true
    tick(w)
end

local function onCast(w, unit, spellID)
    if unit ~= "player" or Api.IsSecret(spellID) or not Util.Contains(w.def.spells, spellID) then return end
    w.readyAt = gameReadyAt(spellID) or (Api.Time() + ownCooldown(w.def))
    startTicking(w)
end

-- Si el juego da el enfriamiento de verdad (fuera de combate, o si un
-- talento lo reinicia), se corrige la cuenta propia.
local function onCooldownUpdate(w)
    local spell = Api.KnownSpell(w.def.spells)
    local readyAt = spell and gameReadyAt(spell)
    if readyAt then
        w.readyAt = readyAt
        startTicking(w)
    end
end

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

function CooldownWarning.Create(def)
    local w = { def = def, readyAt = nil, ticking = false }
    local function settings() return Storage.Get(def.key) end
    w.box = ns.NoticeBox.Create({ name = def.boxName, settings = settings, tooltip = def.tooltip })
    function w.Remaining()
        if not w.readyAt then return 0 end
        return math.max(0, w.readyAt - Api.Time())
    end
    function w.Check()
        w.box:ShowIf(notice(w))
    end
    local switch = Util.Switch(settings, w.Check)
    w.IsEnabled, w.SetEnabled, w.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
    local combat = Util.CombatOnly(settings, false, w.Check)
    w.IsCombatOnly, w.SetCombatOnly = combat.IsCombatOnly, combat.SetCombatOnly
    Util.On("UNIT_SPELLCAST_SUCCEEDED", function(unit, _, spellID) onCast(w, unit, spellID) end)
    Util.On("SPELL_UPDATE_COOLDOWN", function() onCooldownUpdate(w) end)
    local checkSoon = Util.Debounce(Const.READY.CHECK_DELAY, w.Check)
    for _, event in ipairs(CHECK_EVENTS) do Util.On(event, checkSoon) end
    return w
end
