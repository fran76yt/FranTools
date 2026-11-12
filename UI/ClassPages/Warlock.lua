--[[
Sección del brujo
=================

Opciones propias del brujo en /fran config, en tres páginas:
  Mascota      aviso del taunt del abisario (Tormento)
  Reactivos    fragmentos de alma (con sus umbrales) y piedra de salud
  Armadura     aviso de Piel de demonio o Armadura demoníaca
Solo describe las filas (ver UI/OptionRows.lua); el estado lo guardan los
módulos de Features/.
]]

local _, ns = ...
local Rows = ns.OptionRows

local petPage = {
    title = "Mascota",
    rows = {
        Rows.PetTaunt(),
        { kind = "note", text = "En mazmorra y banda el Tormento automático del abisario debe ir desactivado; fuera, activado, para que aguante a los enemigos. El aviso sale en el centro de la pantalla, con sonido." },
    },
}

local reagentsPage = {
    title = "Reactivos",
    rows = Rows.Concat(
        { Rows.Switch(ns.Shards, "Avisar con pocos fragmentos de alma", {
            "Aviso de fragmentos de alma",
            "Un recuadro discreto cuando te quedan pocos, según los umbrales de abajo.",
            "Solo desde que sabes Drenar alma (nivel 10), que es lo que los da.",
            "También con /fran fragmentos.",
        }) },
        Rows.Thresholds(ns.Shards, "Fragmentos de alma"),
        { Rows.Switch(ns.Healthstone, "Avisar si no llevo piedra de salud", {
            "Aviso de piedra de salud",
            "Un recuadro discreto si no llevas ninguna y sabes crearla.",
            "También con /fran piedra.",
        }) }
    ),
}

local armorPage = {
    title = "Armadura",
    rows = {
        Rows.Switch(ns.DemonArmor, "Avisar si no llevo armadura", {
            "Aviso de armadura",
            "Un recuadro discreto si no llevas Piel de demonio ni Armadura demoníaca.",
            "También con /fran armadura.",
        }),
        Rows.CombatOnly(ns.DemonArmor),
        { kind = "note", text = "Los recuadros se pueden mover arrastrándolos." },
    },
}

ns.ClassPages.Register("WARLOCK", {
    title = "Brujo",
    pages = { petPage, reagentsPage, armorPage },
})
