--[[
Preferencias traídas de StreamDeckWoW
=====================================

Los avisos, el vendedor y el agro estuvieron un tiempo dentro de
StreamDeckWoW, que los guardaba en su variable StreamDeckWoWChar. La primera
vez que entras con FranTools se pasan aquí, para no perder lo que tenías
configurado (avisos apagados, posición de los recuadros, umbrales...), y se
quitan de allí.

Se hace al entrar (PLAYER_LOGIN) porque entonces ya están cargadas las
SavedVariables de todos los addons, se cargue antes uno u otro. Si FranTools
ya tiene una parte, no se pisa con la antigua.
]]

local _, ns = ...
local Util, Storage = ns.Util, ns.Storage

-- Partes que se mudaron a FranTools. El botón del minimapa no: StreamDeckWoW
-- sigue teniendo el suyo.
local MOVED_SECTIONS = { "petTaunt", "ammo", "aspect", "repair", "junk", "threat" }

local function migrate(old)
    local moved = 0
    for _, key in ipairs(MOVED_SECTIONS) do
        if old[key] ~= nil then
            if not Storage.HasSection(key) then
                Storage.SetSection(key, old[key])
                moved = moved + 1
            end
            old[key] = nil
        end
    end
    return moved
end

Util.On("PLAYER_LOGIN", function()
    if type(StreamDeckWoWChar) ~= "table" then return end
    if migrate(StreamDeckWoWChar) > 0 then
        Util.Print("traídas tus opciones de avisos, vendedor y agro desde StreamDeckWoW.")
    end
end)
