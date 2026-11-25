--[[
Sección del guerrero
====================

Opciones propias del guerrero en /fran config, en dos páginas:
  Gritos   aviso de Grito de guerra
  Tanque   la casilla "Tanqueo yo", Revancha y Provocar
Solo describe las filas (ver UI/OptionRows.lua); el estado lo guardan los
módulos de Features/.
]]

local _, ns = ...
local Rows = ns.OptionRows

local shoutsPage = {
    title = "Gritos",
    rows = {
        Rows.Switch(ns.BattleShout, "Avisar si no llevo Grito de guerra", {
            "Aviso de Grito de guerra",
            "Un recuadro discreto si no lo llevas; vale también el de otro guerrero.",
            "También con /fran grito.",
        }),
        Rows.CombatOnly(ns.BattleShout),
        { kind = "note", text = "El recuadro se puede mover arrastrándolo." },
    },
}

local tankPage = {
    title = "Tanque",
    rows = {
        Rows.ManualTank(),
        { kind = "note", text = "Si tanqueas, el agro en las barras de nombre cambia: verde, va a por ti; ámbar, te lo van a quitar; rojo, se te ha escapado." },
        { kind = "header", label = "Iconos" },
        Rows.Switch(ns.Revenge, "Revancha: avisar cuando se puede usar", {
            "Revancha",
            "Un icono verde mientras puedes usarla, tras bloquear, esquivar o parar.",
            "Dura poco y es lo que más amenaza da por ira. También con /fran revancha.",
        }),
        Rows.Switch(ns.TauntCooldown, "Provocar: mostrar el enfriamiento", {
            "Provocar",
            "Al usarlo, un icono con los segundos que le quedan; se quita al estar listo.",
            "También con /fran provocar.",
        }),
        Rows.CombatOnly(ns.TauntCooldown),
        { kind = "note", text = "Los iconos se mueven arrastrándolos. Solo el icono, sin texto, y su tamaño: en General." },
    },
}

ns.ClassPages.Register("WARRIOR", {
    title = "Guerrero",
    pages = { shoutsPage, tankPage },
})
