--[[
Registro de combate en mazmorras y bandas
=========================================

Al entrar en una mazmorra o banda enciende el registro de combate del juego,
lo mismo que escribir /combatlog: el cliente guarda todo lo que pasa en
combate (lanzamientos, auras, daño, muertes) en Logs\WoWCombatLog-<fecha>.txt.
Ese archivo es el que permite analizar la pelea fuera del juego, porque a los
addons Forever no les deja leer el registro de combate.

Al salir de la instancia lo apaga, pero solo si lo encendió el addon: si lo
pusiste tú a mano con /combatlog, se respeta. Que lo encendió él se guarda en
las SavedVariables del personaje, porque un /reload dentro de la mazmorra no
apaga el registro del juego y al salir hay que seguir sabiéndolo.

Viene encendido. Se apaga en la página General de /fran config o con
/fran registro; al apagarlo, si el registro lo había puesto el addon, se
quita en ese momento.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage
local C = Const.COMBAT_LOG

local CombatLog = {}
ns.CombatLog = CombatLog

--------------------------------------------------------------------------------
-- Estado
--------------------------------------------------------------------------------

local function settings()
    return Storage.GetCombatLog()
end

-- Si el registro que está corriendo lo encendió el addon (y no el jugador).
local function startedByUs()
    return settings().startedByUs == true
end

local function setStartedByUs(on)
    settings().startedByUs = on or nil
end

local function inLoggedInstance()
    return C.INSTANCE_TYPES[Api.InstanceType()] == true
end

--------------------------------------------------------------------------------
-- Encender y apagar
--------------------------------------------------------------------------------

local function start()
    if Api.IsLoggingCombat() then return end   -- ya estaba: lo puso el jugador
    if Api.SetLoggingCombat(true) then
        setStartedByUs(true)
        Util.Print("registro de combate activado (%s).", C.FILE_HINT)
    else
        Util.Print("no se ha podido activar el registro de combate; escribe /combatlog.")
    end
end

local function stop()
    if not startedByUs() then return end
    setStartedByUs(false)
    if Api.IsLoggingCombat() and Api.SetLoggingCombat(false) then
        Util.Print("registro de combate desactivado.")
    end
end

-- Pone el registro como toca para donde está el jugador.
local function update()
    if CombatLog.IsEnabled() and inLoggedInstance() then
        start()
    else
        stop()
    end
end

--------------------------------------------------------------------------------
-- Interruptor
--------------------------------------------------------------------------------

local switch = Util.Switch(settings, update)
CombatLog.IsEnabled, CombatLog.SetEnabled, CombatLog.Toggle =
    switch.IsEnabled, switch.SetEnabled, switch.Toggle

--------------------------------------------------------------------------------
-- Eventos
--------------------------------------------------------------------------------
-- Tras cada pantalla de carga (entrar o salir de una instancia). Con un
-- pequeño retraso, porque justo al cargar el cliente aún puede no saber el
-- tipo de instancia.

local function updateSoon()
    Util.After(C.CHECK_DELAY, update)
end

Util.On("PLAYER_ENTERING_WORLD", updateSoon)
Util.On("ZONE_CHANGED_NEW_AREA", updateSoon)
