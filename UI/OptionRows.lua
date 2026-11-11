--[[
Filas de opciones comunes
=========================

Filas (ver UI/OptionsPage.lua) que se repiten en las páginas de varias
clases, hechas una vez a partir del módulo del aviso:

  Rows.Switch(module, label, tooltip)   casilla de encender o apagar el aviso
  Rows.CombatOnly(module)               casilla "Solo en combate"
  Rows.Choices(module, title)           título y una casilla con icono por
                                        elemento de la lista (los que valen)
  Rows.Thresholds(module, label)        títulos Ámbar/Rojo y sus dos cajas
  Rows.PetTaunt()                       el aviso del taunt de la mascota
  Rows.Concat(...)                      une varias listas de filas en una

"module" es un aviso creado con Features/BuffWarning.lua o
Features/CountWarning.lua (o cualquiera con las mismas funciones).
]]

local _, ns = ...
local Util, Api, UI = ns.Util, ns.Api, ns.Const.UI

local Rows = {}
ns.OptionRows = Rows

function Rows.Switch(module, label, tooltip)
    return {
        kind = "check",
        label = label,
        tooltip = tooltip,
        get = function() return module.IsEnabled() end,
        set = function(on) module.SetEnabled(on) end,
    }
end

function Rows.CombatOnly(module)
    return {
        kind = "check",
        label = "Solo en combate",
        tooltip = {
            "Solo en combate",
            "Fuera de combate no avisa, para no molestar mientras viajas o descansas.",
            "Desmárcala para que avise siempre.",
        },
        get = function() return module.IsCombatOnly() end,
        set = function(on) module.SetCombatOnly(on) end,
    }
end

-- Casilla de un elemento de la lista, con su icono (que se pide al juego al
-- dibujar la ventana, cuando ya está cargado).
local function choiceCheck(module, item)
    return {
        label = item.label,
        icon = function() return Api.SpellIcon(item.spells[1]) end,
        tooltip = {
            Api.SpellName(item.spells[1]) or item.label,
            "Marcado: llevarlo cuenta como puesto.",
            "Sin marcar: si lo llevas, el aviso sale en rojo.",
        },
        get = function() return module.IsChosen(item) end,
        set = function(on) module.SetChosen(item, on) end,
    }
end

function Rows.Choices(module, title)
    local rows = { { kind = "header", label = title } }
    local checks = {}
    for i, item in ipairs(module.list) do checks[i] = choiceCheck(module, item) end
    for _, items in ipairs(Util.Chunk(checks, UI.CHECKS_PER_ROW)) do
        rows[#rows + 1] = { kind = "checks", items = items }
    end
    return rows
end

function Rows.Thresholds(module, label)
    local function field(which)
        return {
            get = function() return module.GetThreshold(which) end,
            set = function(value) module.SetThreshold(which, value) end,
        }
    end
    return {
        { kind = "columns", label = "Avisar con menos de", columns = { "Ámbar", "Rojo" } },
        {
            kind = "numbers",
            label = label,
            tooltip = {
                label,
                "Ámbar: avisa con menos de esta cantidad.",
                "Rojo: casi sin ninguno (no puede ser mayor que el ámbar).",
                "Intro para aplicar; 0 en ámbar apaga el aviso.",
            },
            fields = { field("low"), field("critical") },
        },
    }
end

function Rows.PetTaunt()
    return {
        kind = "check",
        label = "Avisar del taunt de la mascota",
        tooltip = {
            "Aviso del taunt de la mascota",
            "Avisa si su taunt automático (Bramido, Tormento) está activado en mazmorra",
            "o banda (le quita los enemigos al tanque) o desactivado fuera de ellas.",
            "También con /fran aviso.",
        },
        get = function() return ns.PetTaunt.IsEnabled() end,
        set = function(on) ns.PetTaunt.SetEnabled(on) end,
    }
end

function Rows.Concat(...)
    local all = {}
    for _, list in ipairs({ ... }) do
        for _, row in ipairs(list) do all[#all + 1] = row end
    end
    return all
end
