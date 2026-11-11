--[[
Sección del paladín
===================

Opciones propias del paladín en /fran config, en tres páginas:
  Aura          aviso de aura y qué auras valen
  Bendición     aviso de bendición
  Furia justa   aviso de Furia justa y la casilla "Tanqueo yo"
Solo describe las filas (ver UI/OptionRows.lua); el estado lo guardan los
módulos de Features/.
]]

local _, ns = ...
local Rows = ns.OptionRows

local auraPage = {
    title = "Aura",
    rows = Rows.Concat(
        {
            Rows.Switch(ns.Aura, "Avisar si no llevo un aura de las marcadas", {
                "Aviso de aura",
                "Un recuadro discreto si no llevas aura (ámbar) o si llevas",
                "una sin marcar (rojo). También con /fran aura.",
            }),
            Rows.CombatOnly(ns.Aura),
        },
        Rows.Choices(ns.Aura, "Auras que valen")
    ),
}

local blessingPage = {
    title = "Bendición",
    rows = {
        Rows.Switch(ns.Blessing, "Avisar si no llevo ninguna bendición", {
            "Aviso de bendición",
            "Un recuadro discreto si no llevas ninguna; vale la de cualquier paladín.",
            "También con /fran bendicion.",
        }),
        Rows.CombatOnly(ns.Blessing),
        { kind = "note", text = "El recuadro se puede mover arrastrándolo." },
    },
}

local furyPage = {
    title = "Furia justa",
    rows = {
        Rows.Switch(ns.RighteousFury, "Avisar de Furia justa en grupo", {
            "Aviso de Furia justa",
            "Ámbar: tanqueas y no la llevas. Rojo: la llevas sin tanquear.",
            "Solo en grupo. También con /fran furia.",
        }),
        {
            kind = "check",
            label = "Tanqueo yo",
            tooltip = {
                "Tanqueo yo",
                "Para cuando el juego no sabe tu rol en el grupo.",
                "Si el grupo tiene roles puestos, manda el rol.",
            },
            get = function() return ns.RighteousFury.IsManualTank() end,
            set = function(on) ns.RighteousFury.SetManualTank(on) end,
        },
        { kind = "note", text = "Quién tanquea lo dice el rol del grupo si está puesto; si no, esta casilla. Solo, no avisa." },
    },
}

ns.ClassPages.Register("PALADIN", {
    title = "Paladín",
    pages = { auraPage, blessingPage, furyPage },
})
