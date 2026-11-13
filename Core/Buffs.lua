--[[
Beneficios del jugador
======================

Reconoce qué beneficio de una lista lleva puesto el jugador. Cada elemento de
la lista es { spells = { ID de cada rango }, ... }: un aspecto, un aura, una
bendición... Lo usan los avisos de beneficios (Features/BuffWarning.lua) y el
de Furia justa.

  local buffs = ns.Buffs.List(lista)
  buffs:Active()       -- el elemento que lleva puesto (o nil) y si se ha
                       -- podido saber (false: el juego lo oculta ahora)
  buffs:Current()      -- como Active, pero si no se puede saber, el último
                       -- que se supo
  buffs:IsKnown(item)  -- si sabe lanzar algún rango de ese elemento

Se reconoce por el ID del aura o, si el cliente no lo da, por el nombre: todos
los rangos de un hechizo se llaman igual, así que basta el del primero. El
nombre sale del juego (va en su idioma) y solo se puede pedir con el
personaje cargado, por eso se mira al comprobar y no al crear la lista.

En combate el cliente moderno oculta a los addons la lista de beneficios. Si
pasa, se pregunta hechizo a hechizo (Api.HasPlayerAura), que puede seguir
permitido; si tampoco, Active devuelve nil, false y quien la usa decide qué
hacer; Current recuerda lo último que se leyó.
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

-- Con la lista completa de beneficios.
local function activeFromList(list)
    local buffs = Api.PlayerBuffs()
    if not buffs then return nil, false end
    for _, buff in ipairs(buffs) do
        local item = list:Match(buff)
        if item then return item, true end
    end
    return nil, true
end

-- Preguntando por cada rango de cada elemento.
local function activeByID(list)
    for _, item in ipairs(list.items) do
        for _, id in ipairs(item.spells) do
            local has = Api.HasPlayerAura(id)
            if has == nil then return nil, false end
            if has then return item, true end
        end
    end
    return nil, true
end

function methods:Active()
    local item, known = activeFromList(self)
    if known then return item, true end
    return activeByID(self)
end

-- Como Active, pero si ahora no se puede saber devuelve el último que se
-- supo: lo normal es que sea el de antes de empezar la pelea. Lo que se caiga
-- en combate no se puede saber.
function methods:Current()
    local item, known = self:Active()
    if known then self.last = item end
    return self.last
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
