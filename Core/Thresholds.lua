--[[
Umbrales de aviso
=================

Los avisos por cantidad (munición, fragmentos de alma...) tienen dos umbrales
que el jugador puede cambiar: por debajo de "low" el aviso sale en ámbar y
por debajo de "critical", en rojo. Este módulo los guarda y decide el nivel y
el texto del aviso.

  local thresholds = ns.Thresholds.Create({
      settings = Storage.GetAmmo,     -- tabla de preferencias del aviso
      defaults = function(group) return { low = 200, critical = 50 } end,
      onChange = function() ... end,  -- tras cambiar uno
  })
  thresholds:Get(group, "low")
  thresholds:Set(group, "critical", 30)

"group" separa umbrales dentro del mismo aviso (flechas y balas en la
munición); un aviso con un solo par usa siempre el mismo. Se guardan en
settings().thresholds[group][which] y solo si difieren del valor por
defecto, para que cambiar el valor por defecto en una versión nueva llegue a
quien no lo ha tocado.
]]

local _, ns = ...
local Const, Util = ns.Const, ns.Util

local Thresholds = {}
ns.Thresholds = Thresholds

-- Tope de un umbral: lo que cabe en las cajas numéricas de la ventana.
local MAX = math.floor(10 ^ Const.UI.NUMBER_MAX_DIGITS - 1)

local function clamp(value)
    return math.max(0, math.min(MAX, math.floor(value)))
end

local methods = {}

-- Umbral guardado, o nil. Solo lee: consultar no debe dejar tablas vacías en
-- el archivo de quien nunca ha tocado los umbrales.
function methods:Saved(group, which)
    local all = self.settings().thresholds
    local own = all and all[group]
    return own and own[which]
end

-- which = "low" (ámbar) o "critical" (rojo).
function methods:Get(group, which)
    return self:Saved(group, which) or self.defaults(group)[which]
end

-- Guarda un umbral; las tablas se crean solo aquí, al escribir.
function methods:Store(group, which, value)
    local settings = self.settings()
    settings.thresholds = settings.thresholds or {}
    settings.thresholds[group] = settings.thresholds[group] or {}
    Util.SetOverride(settings.thresholds[group], which, value, self.defaults(group)[which])
end

-- El rojo nunca puede quedar por encima del ámbar: si se pide, se ajusta. Al
-- bajar el ámbar por debajo del rojo, el rojo baja con él.
function methods:Set(group, which, value)
    value = clamp(value)
    if which == "critical" then
        value = math.min(value, self:Get(group, "low"))
    elseif self:Get(group, "critical") > value then
        self:Store(group, "critical", value)
    end
    self:Store(group, which, value)
    self.onChange()
    Util.Fire(Const.MSG.SETTINGS_CHANGED)
end

function Thresholds.Create(opts)
    local t = { settings = opts.settings, defaults = opts.defaults, onChange = opts.onChange }
    for name, fn in pairs(methods) do t[name] = fn end
    return t
end

-- Nivel y texto del aviso para una cantidad, o nil si hay de sobra.
-- texts = { none = "Sin munición", critical = "Munición muy baja: %d",
-- low = "Munición baja: %d" }. Con 0 se usa "none", en rojo si el umbral rojo
-- es mayor que 0 (con rojo 0, cero es solo un aviso ámbar: la piedra de salud).
function Thresholds.Notice(count, low, critical, texts)
    if count >= low then return nil end
    local level = count < critical and "critical" or "warning"
    if count == 0 then return level, texts.none end
    return level, (level == "critical" and texts.critical or texts.low):format(count)
end
