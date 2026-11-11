--[[
Aviso de aspecto
================

Un recuadro discreto (Features/BuffWarning.lua) cuando el cazador no lleva
ninguno de los aspectos que ha elegido en la ventana:

  sin aspecto                       -> borde ámbar, "Sin aspecto"
  con un aspecto no elegido         -> borde rojo, "Aspecto: Guepardo"
                                       (el típico: entrar en combate con el
                                       guepardo y quedarse aturdido)

Los aspectos que valen se eligen en /fran config, sección Aspectos. Por
defecto, los de combate: halcón y mono.
]]

local _, ns = ...

ns.Aspect = ns.BuffWarning.Create({
    key = "aspect",
    boxName = "FranToolsAspectNotice",
    classes = ns.Const.ASPECT.CLASSES,
    list = ns.Const.ASPECT.LIST,
    choosable = true,
    missing = "Sin aspecto",
    wrong = "Aspecto: %s",
    tooltip = {
        "Aspecto",
        "Ámbar: no llevas ningún aspecto.",
        "Rojo: llevas uno que no has elegido (por ejemplo, el guepardo en combate).",
        "Arrástralo para moverlo.",
        "Los aspectos que valen se eligen en /fran config, sección Aspectos.",
    },
})
