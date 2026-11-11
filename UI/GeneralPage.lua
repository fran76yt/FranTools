--[[
Página General
==============

Opciones para cualquier clase en /fran config, la primera página. Como las
secciones de clase (UI/ClassPages), solo describe las filas (ver
UI/OptionsPage.lua); el estado lo guardan los módulos de Features/.
]]

local _, ns = ...

ns.GeneralPage = {
    title = "General",
    rows = {
        { kind = "header", label = "Al abrir un vendedor" },
        {
            kind = "check",
            label = "Reparar el equipo",
            tooltip = {
                "Reparar solo",
                "Repara todo el equipo si el vendedor repara y te llega el dinero.",
                "Lo que cuesta sale en el chat. También con /fran reparar.",
            },
            get = function() return ns.Merchant.IsRepairEnabled() end,
            set = function(on) ns.Merchant.SetRepairEnabled(on) end,
        },
        {
            kind = "check",
            label = "Vender la basura (objetos grises)",
            tooltip = {
                "Vender la basura",
                "Vende los objetos grises que el vendedor compra; nada blanco o mejor.",
                "Lo que da sale en el chat. También con /fran basura.",
            },
            get = function() return ns.Merchant.IsJunkEnabled() end,
            set = function(on) ns.Merchant.SetJunkEnabled(on) end,
        },
        { kind = "note", text = "Primero vende y después repara, así cuenta con lo que da la basura. Abre el vendedor con Mayús pulsada para que no haga nada." },
        { kind = "header", label = "Barras de nombre" },
        {
            kind = "check",
            label = "Mostrar el agro en las de los enemigos",
            tooltip = {
                "Agro en las barras de nombre",
                "Un marco de color alrededor de la barra de vida y tu amenaza al lado:",
                "rojo, va a por ti; ámbar, estás a punto de quitarle el agro a quien lo tiene;",
                "verde, lo tiene tu mascota; gris, lo tiene otro. También con /fran agro.",
            },
            get = function() return ns.Threat.IsEnabled() end,
            set = function(on) ns.Threat.SetEnabled(on) end,
        },
    },
}
