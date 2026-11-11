--[[
Sección del guerrero
====================

Opciones propias del guerrero en /fran config:
  Gritos   aviso de Grito de guerra
Solo describe las filas (ver UI/OptionRows.lua); el estado lo guardan los
módulos de Features/.
]]

local _, ns = ...
local Rows = ns.OptionRows

ns.ClassPages.Register("WARRIOR", {
    title = "Guerrero",
    pages = {
        { title = "Gritos", rows = {
            Rows.Switch(ns.BattleShout, "Avisar si no llevo Grito de guerra", {
                "Aviso de Grito de guerra",
                "Un recuadro discreto si no lo llevas; vale también el de otro guerrero.",
                "También con /fran grito.",
            }),
            Rows.CombatOnly(ns.BattleShout),
            { kind = "note", text = "El recuadro se puede mover arrastrándolo." },
        } },
    },
})
