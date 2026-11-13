--[[
Almacenamiento (SavedVariables)
===============================

Único módulo que toca la variable guardada FranToolsChar (declarada en el
.toc como SavedVariablesPerCharacter). WoW la carga desde disco antes de
PLAYER_LOGIN y la escribe al hacer /reload, al cerrar sesión o al salir.

Cada parte del addon tiene su tabla de preferencias, y en ella solo se guarda
lo que el jugador ha cambiado:

  sidebar    barra lateral de la ventana de opciones:
               <grupo>  true si el jugador lo ha plegado ({ Cazador = true })
  minimap    botón del minimapa:
               angle    posición alrededor del minimapa, en grados
                        (nil -> la de por defecto)
               hidden   true si lo ha ocultado con /fran minimapa
  petTaunt   aviso del taunt de la mascota:
               off      true si lo ha apagado
  ammo       aviso de munición baja:
               off      true si lo ha apagado
               point    posición del recuadro: { punto, punto relativo, x, y }
                        (nil -> la de por defecto)
               thresholds  umbrales cambiados, por tipo:
                        { arrow = { low = 300, critical = 80 }, bullet = {...} }
                        (los que no están usan los de Const.AMMO.TYPES)
  aspect     aviso de aspecto:
               off      true si lo ha apagado
               point    posición del recuadro, como en ammo
               anytime  true si avisa también fuera de combate
               chosen   aspectos que valen, solo los cambiados respecto a
                        Const.ASPECT.LIST: { hawk = false, wild = true }
  repair     reparar solo al abrir un vendedor:
               off      true si lo ha apagado
  junk       vender la basura sola al abrir un vendedor:
               off      true si lo ha apagado
  threat     agro en las barras de nombre de los enemigos:
               off      true si lo ha apagado
  battleShout, demonArmor, aura, blessing
             avisos de beneficio (Features/BuffWarning.lua) del guerrero,
             el brujo y el paladín: off, point y anytime como en aspect; el
             aura también chosen. En demonArmor, que avisa siempre de
             entrada, anytime = false si el jugador lo ha dejado solo en
             combate
  shards, healthstone
             avisos por cantidad (Features/CountWarning.lua) del brujo: off,
             point y, los fragmentos, thresholds = { count = { low, critical } }
  righteousFury
             aviso de Furia justa del paladín: off, point y
               tank     true si el jugador ha dicho que tanquea (cuando el
                        juego no sabe su rol)
]]

local _, ns = ...

local Storage = {}
ns.Storage = Storage

-- La primera vez que se usa el addon la variable no existe: la creamos.
local function db()
    FranToolsChar = FranToolsChar or {}
    return FranToolsChar
end

-- Tabla de preferencias de una parte del addon, creada si no existe. Devuelve
-- la tabla misma (no una copia): quien la recibe la modifica y WoW la guardará
-- con el resto al escribir las SavedVariables.
local function section(key)
    local d = db()
    d[key] = d[key] or {}
    return d[key]
end

-- Tabla de preferencias de cualquier parte, por su nombre: la usan los avisos
-- que se crean a partir de una descripción (Features/BuffWarning.lua...).
function Storage.Get(key)
    return section(key)
end

-- Si ya hay preferencias de una parte (para no pisarlas al traer las de otro
-- addon, ver Core/Migration.lua).
function Storage.HasSection(key)
    return db()[key] ~= nil
end

-- Guarda una tabla de preferencias entera.
function Storage.SetSection(key, value)
    db()[key] = value
end

function Storage.GetSidebar()
    return section("sidebar")
end

function Storage.GetMinimap()
    return section("minimap")
end

function Storage.GetPetTaunt()
    return section("petTaunt")
end

function Storage.GetAmmo()
    return section("ammo")
end

function Storage.GetAspect()
    return section("aspect")
end

function Storage.GetRepair()
    return section("repair")
end

function Storage.GetJunk()
    return section("junk")
end

function Storage.GetThreat()
    return section("threat")
end
