--[[
Ayudas del brujo
================

  Fragmentos de alma   recuadro cuando quedan pocos, con umbrales que se
                       cambian en la ventana (Features/CountWarning.lua).
                       Solo si sabes Drenar alma, que es lo que los da.
  Piedra de salud      recuadro si no llevas ninguna y sabes crearla.
  Armadura             recuadro si no llevas Piel de demonio ni Armadura
                       demoníaca (Features/BuffWarning.lua). También fuera
                       de combate, salvo que el jugador lo cambie.

El taunt del abisario (Tormento) lo vigila el mismo aviso que el Bramido del
cazador (Features/PetTaunt.lua).
]]

local _, ns = ...
local W = ns.Const.WARLOCK
local CLASSES = { WARLOCK = true }

ns.Shards = ns.CountWarning.Create({
    key = "shards",
    boxName = "FranToolsShardsNotice",
    classes = CLASSES,
    items = { W.SOUL_SHARD },
    requires = W.DRAIN_SOUL,
    low = W.SHARDS_LOW,
    critical = W.SHARDS_CRITICAL,
    texts = { none = "Sin fragmentos de alma", critical = "Fragmentos de alma: %d", low = "Fragmentos de alma: %d" },
    tooltip = {
        "Fragmentos de alma",
        "Ámbar: te quedan pocos. Rojo: casi ninguno.",
        "Arrástralo para moverlo. Los umbrales se cambian en /fran config, sección Brujo.",
    },
})

-- Avisa en ámbar con 0 (bajo de 1) y nunca en rojo: una piedra basta.
ns.Healthstone = ns.CountWarning.Create({
    key = "healthstone",
    boxName = "FranToolsHealthstoneNotice",
    classes = CLASSES,
    items = W.HEALTHSTONES,
    requires = W.CREATE_HEALTHSTONE,
    low = 1,
    critical = 0,
    texts = { none = "Sin piedra de salud" },
    tooltip = {
        "Piedra de salud",
        "No llevas ninguna en las bolsas.",
        "Arrástralo para moverlo.",
    },
})

ns.DemonArmor = ns.BuffWarning.Create({
    key = "demonArmor",
    boxName = "FranToolsDemonArmorNotice",
    classes = CLASSES,
    -- Las dos valen; la armadura va primero porque, si la sabes, es la que
    -- toca ponerse (y su icono es el del aviso).
    list = {
        { key = "demonArmor", label = "Armadura demoníaca", spells = W.DEMON_ARMOR },
        { key = "demonSkin", label = "Piel de demonio", spells = W.DEMON_SKIN },
    },
    missing = "Sin armadura",
    -- Dura media hora y se pone antes de empezar: el aviso sirve justo fuera
    -- de combate, para no entrar en una pelea sin ella.
    anytime = true,
    tooltip = {
        "Armadura del brujo",
        "No llevas Piel de demonio ni Armadura demoníaca.",
        "Arrástralo para moverlo.",
    },
})
