--[[
Aviso de beneficio
==================

Motor de los avisos "no llevas X puesto": el aspecto del cazador, el Grito de
guerra del guerrero, la armadura del brujo, el aura y la bendición del
paladín. Cada uno es una descripción y este archivo hace el resto:

  ns.Aspect = ns.BuffWarning.Create({
      key = "aspect",                    -- sus preferencias (Storage.Get)
      boxName = "FranToolsAspectNotice", -- nombre global del recuadro
      classes = { HUNTER = true },       -- para quién es
      list = { { key, label, default, spells }, ... },
      choosable = true,                  -- el jugador elige cuáles valen
      missing = "Sin aspecto",           -- texto sin ninguno (ámbar)
      wrong = "Aspecto: %s",             -- con uno que no vale (rojo)
      anytime = true,                    -- opcional: avisar también fuera de
                                         -- combate de entrada
      tooltip = { ... },
  })

Muestra un recuadro discreto (UI/NoticeBox.lua):

  sin ninguno de la lista       -> borde ámbar, "Sin aspecto"
  con uno que no vale           -> borde rojo, "Aspecto: Guepardo"
                                   (solo si choosable: el jugador quitó ese)

El icono es el del primer elemento que vale y que el jugador sabe usar: el
que toca ponerse. Sin choosable valen todos (cualquier bendición sirve).

Por defecto solo avisa en combate, para no molestar mientras viajas o
descansas; se puede hacer que avise siempre. Los beneficios largos que se
ponen antes de empezar (la armadura del brujo) avisan siempre de entrada
(def.anytime); el jugador puede cambiar cualquiera de los dos. No avisa muerto ni de lo que aún
no has aprendido: si no sabes usar ninguno de los que valen, no hay aviso.

Cada aviso creado tiene IsEnabled/SetEnabled/Toggle, IsCombatOnly/
SetCombatOnly, IsChosen/SetChosen, Check y su lista en .list.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage

local BuffWarning = {}
ns.BuffWarning = BuffWarning

-- Eventos tras los que se vuelve a comprobar: entrar y salir de combate
-- (aparece o desaparece el aviso), aprender algo nuevo y morir o revivir.
local CHECK_EVENTS = { "PLAYER_ENTERING_WORLD", "PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED",
                       "SPELLS_CHANGED", "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST" }

--------------------------------------------------------------------------------
-- Preferencias
--------------------------------------------------------------------------------

local methods = {}

function methods.Settings(w)
    return Storage.Get(w.def.key)
end

function methods.Changed(w)
    w.Check()
    Util.Fire(Const.MSG.SETTINGS_CHANGED)
end

-- Si un elemento vale: lo elegido por el jugador o, si no lo ha tocado, su
-- valor por defecto. Solo lee, para no dejar tablas vacías.
function methods.IsChosen(w, item)
    if not w.def.choosable then return true end
    local chosen = w.Settings().chosen
    local saved = chosen and chosen[item.key]
    if saved == nil then return item.default end
    return saved
end

function methods.SetChosen(w, item, on)
    local settings = w.Settings()
    settings.chosen = settings.chosen or {}
    Util.SetOverride(settings.chosen, item.key, on and true or false, item.default)
    w.Changed()
end

-- Se guarda como anytime (avisa también fuera de combate) y solo si difiere
-- del valor por defecto del aviso (def.anytime), para que lo normal no ocupe
-- nada en el archivo.
local function anytimeDefault(w)
    return w.def.anytime == true
end

function methods.IsCombatOnly(w)
    local saved = w.Settings().anytime
    if saved == nil then return not anytimeDefault(w) end
    return not saved
end

function methods.SetCombatOnly(w, on)
    Util.SetOverride(w.Settings(), "anytime", not on, anytimeDefault(w))
    w.Changed()
end

--------------------------------------------------------------------------------
-- Aviso
--------------------------------------------------------------------------------

-- Elementos que valen y que el jugador ya sabe usar, en el orden de la lista.
function methods.Wanted(w)
    local wanted = {}
    for _, item in ipairs(w.list) do
        if w.IsChosen(item) and w.buffs:IsKnown(item) then wanted[#wanted + 1] = item end
    end
    return wanted
end

-- Si toca comprobar ahora: aviso encendido, clase, vivo y, salvo que avise
-- siempre, en combate.
function methods.ShouldCheck(w)
    return w.IsEnabled() and w.def.classes[Api.PlayerClass()] and not Api.IsDead()
        and (not w.IsCombatOnly() or Util.InCombat())
end

-- Icono, texto y nivel del aviso, o nil si no hay nada que avisar.
function methods.Notice(w)
    if not w.ShouldCheck() then return nil end
    local wanted = w.Wanted()
    if #wanted == 0 then return nil end
    local active = w.buffs:Active()
    if active and w.IsChosen(active) then return nil end
    local icon = Api.SpellIcon(wanted[1].spells[1])
    if active then return icon, w.def.wrong:format(active.label), "critical" end
    return icon, w.def.missing, "warning"
end

function methods.Check(w)
    w.box:ShowIf(w.Notice())
end

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

local function listenEvents(w)
    local checkSoon = Util.Debounce(Const.BUFF_CHECK_DELAY, function() w.Check() end)
    Util.On("UNIT_AURA", function(unit)
        if unit == "player" then checkSoon() end
    end)
    for _, event in ipairs(CHECK_EVENTS) do Util.On(event, checkSoon) end
end

function BuffWarning.Create(def)
    local w = { def = def, list = def.list, buffs = ns.Buffs.List(def.list) }
    -- Cada función queda atada a este aviso: se llaman con punto, como las de
    -- cualquier otro módulo (Aspect.Check(), Aspect.IsChosen(aspecto)).
    for name, fn in pairs(methods) do w[name] = function(...) return fn(w, ...) end end
    w.box = ns.NoticeBox.Create({
        name = def.boxName,
        settings = function() return Storage.Get(def.key) end,
        tooltip = def.tooltip,
    })
    local switch = Util.Switch(function() return Storage.Get(def.key) end, function() w.Check() end)
    w.IsEnabled, w.SetEnabled, w.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
    listenEvents(w)
    return w
end
