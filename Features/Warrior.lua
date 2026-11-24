--[[
Ayudas del guerrero
===================

  Grito de guerra   recuadro si no lo llevas (Features/BuffWarning.lua).
                    Lo cuenta también el de otro guerrero del grupo.
  Revancha          recuadro verde mientras se puede usar, tras bloquear,
                    esquivar o parar (Features/ReadyWarning.lua).
  Provocar          recuadro con lo que le queda de enfriamiento, o "listo"
                    (Features/CooldownWarning.lua).

Para el tanque también cuentan los colores de tanque del agro en las barras
de nombre (Features/Threat.lua), que dependen de la casilla "Tanqueo yo" o
del rol del grupo (Core/Role.lua).
]]

local _, ns = ...
local W = ns.Const.WARRIOR

local MOVE_HINT = "Arrástralo para moverlo. Se configura en /fran config, sección Guerrero."

ns.BattleShout = ns.BuffWarning.Create({
    key = "battleShout",
    boxName = "FranToolsBattleShoutNotice",
    classes = { WARRIOR = true },
    list = { { key = "battleShout", label = "Grito de guerra", spells = W.BATTLE_SHOUT } },
    missing = "Sin Grito de guerra",
    tooltip = {
        "Grito de guerra",
        "No llevas Grito de guerra.",
        MOVE_HINT,
    },
})

ns.Revenge = ns.ReadyWarning.Create({
    key = "revenge",
    boxName = "FranToolsRevengeNotice",
    classes = { WARRIOR = true },
    spells = W.REVENGE,
    label = "Revancha",
    tooltip = {
        "Revancha",
        "Ya puedes usarla: acabas de bloquear, esquivar o parar, y dura poco.",
        MOVE_HINT,
    },
})

ns.TauntCooldown = ns.CooldownWarning.Create({
    key = "taunt",
    boxName = "FranToolsTauntNotice",
    classes = { WARRIOR = true },
    spells = W.TAUNT,
    label = "Provocar",
    cooldown = W.TAUNT_COOLDOWN,
    talents = W.TAUNT_TALENTS,
    tooltip = {
        "Provocar",
        "Verde: listo. Apagado con una cifra: los segundos que le quedan.",
        MOVE_HINT,
    },
})
