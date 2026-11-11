--[[
Aviso por cantidad de objetos
=============================

Motor de los avisos "te quedan pocos X": los fragmentos de alma y la piedra
de salud del brujo. (La munición del cazador tiene el suyo, Features/Ammo.lua,
porque además mira qué arma llevas.) Cada uno es una descripción:

  ns.Shards = ns.CountWarning.Create({
      key = "shards",                    -- sus preferencias (Storage.Get)
      boxName = "FranToolsShardsNotice", -- nombre global del recuadro
      classes = { WARLOCK = true },      -- para quién es
      items = { 6265 },                  -- objetos que cuentan (se suman)
      requires = { ... },                -- opcional: solo si sabe alguno de
                                         -- estos hechizos (crear la piedra)
      low = 5, critical = 2,             -- umbrales por defecto
      texts = { none = "Sin fragmentos de alma",
                critical = "Fragmentos de alma: %d",
                low = "Fragmentos de alma: %d" },
      tooltip = { ... },
  })

Muestra un recuadro discreto (UI/NoticeBox.lua) en ámbar por debajo de "low"
y en rojo por debajo de "critical" (ver Core/Thresholds.lua). Los umbrales se
pueden cambiar en la ventana (GetThreshold/SetThreshold); con critical = 0,
quedarse sin ninguno es solo un aviso ámbar.

Cada aviso creado tiene IsEnabled/SetEnabled/Toggle, GetThreshold/
SetThreshold, Check y Count.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage

local CountWarning = {}
ns.CountWarning = CountWarning

-- Grupo con el que se guardan los umbrales (cada aviso tiene un solo par).
local GROUP = "count"

local methods = {}

-- Unidades en las bolsas de todos los objetos que cuentan.
function methods.Count(w)
    local total = 0
    for _, id in ipairs(w.def.items) do total = total + Api.ItemCount(id) end
    return total
end

function methods.GetThreshold(w, which)
    return w.thresholds:Get(GROUP, which)
end

function methods.SetThreshold(w, which, value)
    w.thresholds:Set(GROUP, which, value)
end

-- Si el aviso es para este personaje: su clase y, si hace falta, que sepa
-- alguno de los hechizos (sin saber crear la piedra no tiene sentido avisar).
function methods.Applies(w)
    if not w.def.classes[Api.PlayerClass()] then return false end
    if not w.def.requires then return true end
    for _, id in ipairs(w.def.requires) do
        if Api.IsSpellKnown(id) then return true end
    end
    return false
end

function methods.Check(w)
    local level, text
    if w.IsEnabled() and w.Applies() and not Api.IsDead() then
        level, text = ns.Thresholds.Notice(w.Count(), w.GetThreshold("low"), w.GetThreshold("critical"), w.def.texts)
    end
    w.box:ShowIf(Api.ItemIcon(w.def.items[1]), text, level)
end

local function listenEvents(w)
    local checkSoon = Util.Debounce(Const.COUNT_CHECK_DELAY, function() w.Check() end)
    for _, event in ipairs({ "PLAYER_ENTERING_WORLD", "BAG_UPDATE_DELAYED", "SPELLS_CHANGED",
                             "PLAYER_DEAD", "PLAYER_ALIVE", "PLAYER_UNGHOST" }) do
        Util.On(event, checkSoon)
    end
end

function CountWarning.Create(def)
    local w = { def = def }
    local settings = function() return Storage.Get(def.key) end
    -- Cada función queda atada a este aviso: se llaman con punto, como las de
    -- cualquier otro módulo (Shards.Check()).
    for name, fn in pairs(methods) do w[name] = function(...) return fn(w, ...) end end
    w.thresholds = ns.Thresholds.Create({
        settings = settings,
        defaults = function() return { low = def.low, critical = def.critical } end,
        onChange = function() w.Check() end,
    })
    w.box = ns.NoticeBox.Create({ name = def.boxName, settings = settings, tooltip = def.tooltip })
    local switch = Util.Switch(settings, function() w.Check() end)
    w.IsEnabled, w.SetEnabled, w.Toggle = switch.IsEnabled, switch.SetEnabled, switch.Toggle
    listenEvents(w)
    return w
end
