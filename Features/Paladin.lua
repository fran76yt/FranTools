--[[
Ayudas del paladín
==================

  Aura        recuadro si no llevas ninguna de las que has marcado en la
              ventana (ámbar) o llevas una sin marcar (rojo), como los
              aspectos del cazador (Features/BuffWarning.lua).
  Bendición   recuadro si no llevas ninguna; vale la de cualquier paladín.

Furia justa tiene su propio aviso (Features/RighteousFury.lua), porque
depende de si tanqueas o no.
]]

local _, ns = ...
local P = ns.Const.PALADIN
local CLASSES = { PALADIN = true }

ns.Aura = ns.BuffWarning.Create({
    key = "aura",
    boxName = "FranToolsAuraNotice",
    classes = CLASSES,
    list = P.AURAS,
    choosable = true,
    missing = "Sin aura",
    wrong = "Aura: %s",
    tooltip = {
        "Aura",
        "Ámbar: no llevas ningún aura. Rojo: llevas una que no has marcado.",
        "Arrástralo para moverlo. Las auras que valen se eligen en /fran config, sección Paladín.",
    },
})

ns.Blessing = ns.BuffWarning.Create({
    key = "blessing",
    boxName = "FranToolsBlessingNotice",
    classes = CLASSES,
    list = P.BLESSINGS,
    missing = "Sin bendición",
    tooltip = {
        "Bendición",
        "No llevas ninguna bendición, ni tuya ni de otro paladín.",
        "Arrástralo para moverlo.",
    },
})
