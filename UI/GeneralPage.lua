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
                "Si tanqueas (casilla Tanqueo yo o rol del grupo): verde, va a por ti;",
                "ámbar, te lo van a quitar; rojo, se te ha escapado.",
            },
            get = function() return ns.Threat.IsEnabled() end,
            set = function(on) ns.Threat.SetEnabled(on) end,
        },
        { kind = "header", label = "Recuadros de aviso" },
        {
            kind = "check",
            label = "Solo el icono, sin texto",
            tooltip = {
                "Solo el icono",
                "Todos los avisos (Revancha, Provocar, aspecto, munición...) como un icono",
                "cuadrado, sin texto. Al pasar el ratón se explica. También con /fran iconos.",
            },
            get = function() return ns.NoticeBox.IsIconOnly() end,
            set = function(on) ns.NoticeBox.SetIconOnly(on) end,
        },
        {
            kind = "numbers",
            label = "Tamaño del icono",
            tooltip = {
                "Tamaño del icono",
                ("En píxeles, de %d a %d. Intro para aplicar."):format(ns.Const.NOTICE.ICON_SIZE_MIN, ns.Const.NOTICE.ICON_SIZE_MAX),
            },
            fields = {
                {
                    get = function() return ns.NoticeBox.IconSize() end,
                    set = function(size) ns.NoticeBox.SetIconSize(size) end,
                },
            },
        },
        { kind = "note", text = "Los recuadros se mueven arrastrándolos y cada uno recuerda su sitio." },
        { kind = "header", label = "Registro de combate" },
        {
            kind = "check",
            label = "Activarlo en mazmorras y bandas",
            tooltip = {
                "Registro de combate",
                "Al entrar en una mazmorra o banda hace lo mismo que /combatlog: el juego",
                "guarda todo el combate en " .. ns.Const.COMBAT_LOG.FILE_HINT .. ",",
                "para analizarlo fuera del juego. Al salir lo apaga, si lo encendió él.",
                "También con /fran registro.",
            },
            get = function() return ns.CombatLog.IsEnabled() end,
            set = function(on) ns.CombatLog.SetEnabled(on) end,
        },
    },
}
