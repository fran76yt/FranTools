--[[
Comandos de chat
================

  /fran            abrir o cerrar la ventana de opciones (igual que /fran config)
  /fran config     abrir o cerrar la ventana de opciones
  /fran minimapa   ocultar o mostrar el botón del minimapa
  /fran aviso      apagar o encender el aviso del taunt de la mascota
  /fran municion   apagar o encender el aviso de munición baja
  /fran aspecto    apagar o encender el aviso de aspecto
  /fran reparar    apagar o encender reparar al abrir un vendedor
  /fran basura     apagar o encender vender la basura al abrir un vendedor
  /fran agro       apagar o encender el agro en las barras de nombre
  /fran ayuda      versión y lista de comandos (también con cualquier otro texto)

Cada subcomando es una función en la tabla "commands": añadir uno nuevo es
añadir una entrada. Los que encienden y apagan algo se describen como datos
en TOGGLES, porque todos hacen lo mismo con otro módulo y otro texto.
]]

local _, ns = ...
local Util = ns.Util

local commands = {}

--------------------------------------------------------------------------------
-- Interruptores
--------------------------------------------------------------------------------
-- { comando, función que invierte la opción y devuelve si queda encendida,
--   qué es (para el mensaje), ayuda }. Las funciones se buscan en ns al
-- ejecutar el comando, no al cargar.

local TOGGLES = {
    { "aviso", function() return ns.PetTaunt.Toggle() end, "aviso del taunt de la mascota",
      "apagar o encender el aviso del taunt de la mascota" },
    { "municion", function() return ns.Ammo.Toggle() end, "aviso de munición baja",
      "apagar o encender el aviso de munición baja" },
    { "aspecto", function() return ns.Aspect.Toggle() end, "aviso de aspecto",
      "apagar o encender el aviso de aspecto" },
    { "reparar", function() return ns.Merchant.ToggleRepair() end, "reparar al abrir un vendedor",
      "apagar o encender reparar al abrir un vendedor" },
    { "basura", function() return ns.Merchant.ToggleJunk() end, "vender la basura al abrir un vendedor",
      "apagar o encender vender la basura al abrir un vendedor" },
    { "agro", function() return ns.Threat.Toggle() end, "agro en las barras de nombre",
      "apagar o encender el agro en las barras de nombre" },
}

local function toggleCommand(name, toggle, what)
    return function()
        if toggle() then
            Util.Print("%s: encendido.", what)
        else
            Util.Print("%s: apagado. /fran %s para volver a encenderlo.", what, name)
        end
    end
end

for _, t in ipairs(TOGGLES) do
    commands[t[1]] = toggleCommand(t[1], t[2], t[3])
end

--------------------------------------------------------------------------------
-- Resto de subcomandos
--------------------------------------------------------------------------------

function commands.config()
    ns.ConfigWindow.Toggle()
end

function commands.minimapa()
    local shown = ns.Minimap:ToggleShown()
    Util.Print(shown and "botón del minimapa visible." or "botón del minimapa oculto. /fran minimapa para recuperarlo.")
end

function commands.ayuda()
    Util.Print("versión %s. Comandos:", ns.Api.AddOnVersion())
    print("  /fran  -  abrir las opciones (también /fran config o clic en el botón del minimapa)")
    print("  /fran minimapa  -  ocultar o mostrar el botón del minimapa")
    for _, t in ipairs(TOGGLES) do
        print(("  /fran %s  -  %s"):format(t[1], t[4]))
    end
    print("  /fran ayuda  -  esta ayuda")
end

-- Sin argumentos: las opciones.
commands[""] = commands.config

--------------------------------------------------------------------------------
-- Registro del comando
--------------------------------------------------------------------------------
-- Ejecuta el subcomando escrito tras /fran. Un subcomando desconocido muestra
-- la ayuda. Se publica en ns para que otras partes de la interfaz lancen los
-- mismos comandos sin repetir su código.
local Commands = {}
ns.Commands = Commands

function Commands.Run(msg)
    local name = (msg or ""):match("^%s*(%S*)"):lower()
    local run = commands[name] or commands.ayuda
    run()
end

-- WoW registra comandos con la convención SLASH_<NOMBRE>1 + SlashCmdList.<NOMBRE>.
SLASH_FRANTOOLS1 = "/fran"
SLASH_FRANTOOLS2 = "/frantools"
SlashCmdList.FRANTOOLS = Commands.Run
