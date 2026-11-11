--[[
Ayudas del guerrero
===================

  Grito de guerra   recuadro si no lo llevas (Features/BuffWarning.lua).
                    Lo cuenta también el de otro guerrero del grupo.
]]

local _, ns = ...
local W = ns.Const.WARRIOR

ns.BattleShout = ns.BuffWarning.Create({
    key = "battleShout",
    boxName = "FranToolsBattleShoutNotice",
    classes = { WARRIOR = true },
    list = { { key = "battleShout", label = "Grito de guerra", spells = W.BATTLE_SHOUT } },
    missing = "Sin Grito de guerra",
    tooltip = {
        "Grito de guerra",
        "No llevas Grito de guerra.",
        "Arrástralo para moverlo. Se configura en /fran config, sección Guerrero.",
    },
})
