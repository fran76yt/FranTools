--[[
Beneficios del jugador
======================

Reconoce qué beneficio de una lista lleva puesto el jugador. Cada elemento de
la lista es { spells = { ID de cada rango }, ... }: un aspecto, un aura, una
bendición... Lo usan los avisos de beneficios (Features/BuffWarning.lua) y el
de Furia justa.

  local buffs = ns.Buffs.List(lista)
  buffs:Active()       -- el elemento que lleva puesto, o nil
  buffs:IsKnown(item)  -- si sabe lanzar algún rango de ese elemento

Se reconoce por el ID del aura o, si el cliente no lo da, por el nombre: todos
los rangos de un hechizo se llaman igual, así que basta el del primero. El
nombre sale del juego (va en su idioma) y solo se puede pedir con el
personaje cargado, por eso se mira al comprobar y no al crear la lista.
]]

local _, ns = ...
local Api = ns.Api

local Buffs = {}
ns.Buffs = Buffs

local methods = {}

function methods:ByName(name)
    for _, item in ipairs(self.items) do
        if Api.SpellName(item.spells[1]) == name then return item end
    end
end

-- Elemento de la lista al que corresponde un beneficio, o nil.
function methods:Match(buff)
    return self.byID[buff.spellID] or self:ByName(buff.name)
end

function methods:Active()
    for _, buff in ipairs(Api.PlayerBuffs()) do
        local item = self:Match(buff)
        if item then return item end
    end
end

function methods:IsKnown(item)
    for _, id in ipairs(item.spells) do
        if Api.IsSpellKnown(id) then return true end
    end
    return false
end

function Buffs.List(items)
    local list = { items = items, byID = {} }
    for _, item in ipairs(items) do
        for _, id in ipairs(item.spells) do list.byID[id] = item end
    end
    for name, fn in pairs(methods) do list[name] = fn end
    return list
end
