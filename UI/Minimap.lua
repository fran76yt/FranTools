--[[
Botón del minimapa de FranTools
===============================

El botón compartido (UI/MinimapButton.lua) con lo propio de este addon:
  clic             abrir o cerrar la ventana de opciones
  arrastrar        moverlo alrededor del minimapa
  /fran minimapa   ocultarlo o volver a mostrarlo
]]

local _, ns = ...

ns.Minimap = ns.MinimapButton.Create({
    settings = ns.Storage.GetMinimap,
    tooltip = {
        ns.Const.UI.TITLE,
        "Clic: opciones",
        "Arrastrar: mover este botón",
        "/fran minimapa: ocultarlo",
    },
    -- Los módulos se buscan en ns al hacer clic: la ventana se carga después.
    onClick = {
        LeftButton = function() ns.ConfigWindow.Toggle() end,
    },
})
