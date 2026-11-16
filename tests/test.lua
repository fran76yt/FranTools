--[[
Pruebas de FranTools
====================

Las ejecuta tests/run.js después de cargar la API simulada
(tests/api_stubs.lua) y el addon. Cada check() que pasa escribe "ok" y el
primero que falla para con un error. Al final, __SV guarda las
SavedVariables del personaje para revisarlas (tests/out/).
]]

local ns = FranTools
local function check(cond, msg) if not cond then error("FALLO: " .. msg) end io.write("ok  ", msg, "\n") end
local function hasPrinted(text) for _, l in ipairs(printed) do if l:find(text, 1, true) then return true end end end

-- error al cargar, antes de que el juego lea la variable de la cuenta
ns.Util.On("PRUEBA_TEMPRANA", function() error("prueba de error temprana") end)
fire("PRUEBA_TEMPRANA")
check(hasPrinted("se ha producido un error de Lua") , "aviso en el chat del primer error")
FranToolsLog = { entries = {} }
fire("ADDON_LOADED", "OtroAddon")
fire("ADDON_LOADED", __ADDON)
printed = {}
-- opciones traídas de StreamDeckWoW
StreamDeckWoWChar = { petTaunt = { off = true }, repair = { off = true }, minimap = { angle = 10 }, slots = { { empty = true } } }
FranToolsChar = { repair = {} }
loggedIn = true
fire("PLAYER_LOGIN")
check(FranToolsChar.petTaunt and FranToolsChar.petTaunt.off == true and StreamDeckWoWChar.petTaunt == nil, "trae las opciones de StreamDeckWoW y las quita de allí")
check(FranToolsChar.repair.off == nil and StreamDeckWoWChar.repair == nil, "lo que FranTools ya tenía no se pisa")
check(StreamDeckWoWChar.minimap.angle == 10 and StreamDeckWoWChar.slots[1].empty, "lo de las teclas y su minimapa se queda en StreamDeckWoW")
check(hasPrinted("traídas tus opciones"), "lo dice en el chat")
printed = {}
fire("PLAYER_LOGIN")
check(not hasPrinted("traídas"), "solo la primera vez")
FranToolsChar.petTaunt = nil

-- botón del minimapa y ventana
local mb = _G.FranToolsMinimapButton
check(mb and rawget(mb, "_shown") ~= false, "botón del minimapa de FranTools")
rawget(mb, "_OnClick")(mb, "LeftButton")
local win = _G.FranToolsConfig
check(win and rawget(win, "_shown") == true, "clic: abre las opciones")
SlashCmdList.FRANTOOLS("config")
check(rawget(win, "_shown") == false, "/fran config la cierra")
SlashCmdList.FRANTOOLS("")
check(rawget(win, "_shown") == true, "/fran sin nada la abre")
SlashCmdList.FRANTOOLS("minimapa")
check(rawget(mb, "_shown") == false and FranToolsChar.minimap.hidden == true, "/fran minimapa lo oculta y lo recuerda")
SlashCmdList.FRANTOOLS("minimapa")
check(rawget(mb, "_shown") == true, "otra vez lo muestra")
printed = {}
SlashCmdList.FRANTOOLS("xyz")
check(printed[1]:find("Comandos") and printed[1]:find("versión 0.1.0", 1, true) and hasPrinted("/fran agro"), "subcomando desconocido: ayuda con la versión y los comandos")
check(printed[1]:find("INV_Misc_Wrench_01:14:14", 1, true), "el prefijo del chat lleva el icono")

-- aviso del taunt de la mascota
local function step(event, ...) fire(event, ...) runTimers() end
pet, petBar = true, { { "Atacar" }, [4] = { "Bramido", 14916, true } }
step("PET_BAR_UPDATE")
check(#warnings == 0, "fuera con Bramido activado: no avisa")
instance = "party"
step("PLAYER_ENTERING_WORLD")
check(#warnings == 1 and warnings[1]:find("ACTIVADO en mazmorra", 1, true) and sounds == 1, "al entrar en mazmorra con Bramido activado: aviso en pantalla y sonido")
check(hasPrinted("ACTIVADO en mazmorra"), "y también en el chat")
step("PET_BAR_UPDATE"); step("ZONE_CHANGED_NEW_AREA")
check(#warnings == 1, "no se repite con cada actualización")
fire("PLAYER_REGEN_DISABLED")
check(#warnings == 2, "se repite al entrar en combate si sigue mal")
printed = {}
petBar[4][3] = false
step("PET_BAR_UPDATE")
check(#warnings == 2 and hasPrinted("Bramido de la mascota desactivado: correcto"), "al desactivarlo confirma en el chat")
fire("PLAYER_REGEN_DISABLED")
check(#warnings == 2, "en combate, si está bien, no avisa")
instance = "none"
step("PLAYER_ENTERING_WORLD")
check(#warnings == 3 and warnings[3]:find("DESACTIVADO fuera de mazmorra", 1, true), "al salir con Bramido desactivado: aviso")
spellnames[2649] = "Bramido"
petBar[4] = { "Bramido", nil, true }
printed = {}
step("PET_BAR_UPDATE")
check(hasPrinted("activado: correcto"), "sin ID en la barra lo reconoce por el nombre")
pet = false
step("UNIT_PET", "player")
instance = "raid"
step("PLAYER_ENTERING_WORLD")
check(#warnings == 3, "sin mascota no avisa")
pet = true
step("UNIT_PET", "player")
check(#warnings == 4 and warnings[4]:find("banda", 1, true), "al invocarla en banda con Bramido activado: aviso")
SlashCmdList.FRANTOOLS("aviso")
check(FranToolsChar.petTaunt.off == true, "/fran aviso lo apaga y lo recuerda")
fire("PLAYER_REGEN_DISABLED"); step("PET_BAR_UPDATE")
check(#warnings == 4, "apagado no avisa")
SlashCmdList.FRANTOOLS("aviso")
check(#warnings == 5 and FranToolsChar.petTaunt.off == nil, "al encenderlo comprueba enseguida")
petBar[4] = { "Mordisco", 17253, true }
step("PET_BAR_UPDATE")
check(#warnings == 5, "una mascota sin Bramido no da avisos")
local nav = {}
for i = 1, 5 do nav[i] = _G["FranToolsConfigNav" .. i] end
check(nav[4] and not nav[5], "barra lateral con General, Mascota, Munición y Aspectos")
check(rawget(nav[1].selection, "_shown") == true and rawget(nav[2].selection, "_shown") == false, "General elegida al abrir")
rawget(nav[2], "_OnClick")(nav[2])
check(rawget(nav[2].selection, "_shown") == true and rawget(nav[1].selection, "_shown") == false, "clic en Mascota la elige")
check(rawget(nav[2].label, "_color")[1] == 1 and rawget(nav[1].label, "_color")[1] == 0.85, "la elegida, en dorado")
local header
for _, f in ipairs(frames) do if rawget(f, "_text") == "Cazador" then header = f end end
check(header and rawget(header, "_color")[1] == 0.67, "grupo Cazador con el color de la clase")
-- grupos plegables
local grp = _G.FranToolsConfigGroup1
check(grp and rawget(grp.toggle, "_tex"):find("Minus", 1, true), "Cazador desplegado, con el menos")
rawget(grp, "_OnClick")(grp)
check(rawget(nav[2], "_shown") == false and rawget(nav[4], "_shown") == false and rawget(nav[1], "_shown") == true,
      "al pulsar Cazador se ocultan sus páginas")
check(FranToolsChar.sidebar.Cazador == true and rawget(grp.toggle, "_tex"):find("Plus", 1, true), "se recuerda plegado, con el más")
rawget(grp, "_OnClick")(grp)
check(rawget(nav[2], "_shown") == true and FranToolsChar.sidebar.Cazador == nil, "otra vez se despliega y no queda nada guardado")
check(rawget(nav[2], "_point")[3] < rawget(grp, "_point")[3], "las páginas van debajo de su título")
-- una nota de varias líneas empuja lo que viene después
local note, section
for _, f in ipairs(frames) do
  local t = rawget(f, "_text")
  if type(t) == "string" and t:find("^Primero vende") then note = f end
  if t == "Barras de nombre" then section = f end
end
local noteBottom = rawget(note, "_point")[5] - note:GetStringHeight()
local sectionTop = rawget(section, "_point")[5] + ns.Const.UI.ROW_HEIGHT / 2
check(note:GetStringHeight() > ns.Const.UI.ROW_HEIGHT and sectionTop < noteBottom, "la nota larga no pisa el título de debajo")
local function openPage(i) rawget(nav[i], "_OnClick")(nav[i]) end
openPage(2)
check(ns.ClassPages.For("MAGE") == nil and ns.ClassPages.For("HUNTER").title == "Cazador" and ns.ClassPages.For("WARRIOR").title == "Guerrero", "secciones por clase (el mago aún no tiene)")
local cbs = {}
for _, f in ipairs(frames) do if rawget(f, "_checked") ~= nil and rawget(f, "_OnClick") then cbs[#cbs+1] = f end end
local gcbs = { table.remove(cbs, 1), table.remove(cbs, 1), table.remove(cbs, 1) }   -- página General
local cb = cbs[1]
check(cb and rawget(cb, "_checked") == true, "la ventana tiene la casilla del aviso, marcada")
rawset(cb, "_checked", false); rawget(cb, "_OnClick")(cb)
check(FranToolsChar.petTaunt.off == true and rawget(cb, "_checked") == false, "al desmarcarla se apaga el aviso")
SlashCmdList.FRANTOOLS("aviso")
check(rawget(cb, "_checked") == true, "/fran aviso actualiza la casilla")
local before = #warnings
petBar[4] = { "Bramido", 2649, true }; instance = "party"
rawset(cb, "_checked", false); rawget(cb, "_OnClick")(cb)
rawset(cb, "_checked", true); rawget(cb, "_OnClick")(cb)
check(#warnings == before + 1, "al volver a marcarla comprueba enseguida")

-- munición baja
local function ammoBox() return _G.FranToolsAmmoNotice end
local function ammoText() return ammoBox() and rawget(ammoBox(), "_shown") and rawget(ammoBox().text, "_text") end
step("BAG_UPDATE_DELAYED")
check(ammoBox() == nil, "sin arma a distancia no hay recuadro (ni se crea)")
itemClass[2504], itemClass[2512], itemClass[2516], itemClass[2508], itemClass[5240] = { 2, 2 }, { 6, 2 }, { 6, 3 }, { 2, 3 }, { 2, 19 }
equip[18] = 2504
bagSlots = { [0] = { { itemID = 2512, stackCount = 150 }, { itemID = 2516, stackCount = 200 } }, [1] = { { itemID = 2512, stackCount = 40 } } }
step("BAG_UPDATE_DELAYED")
check(ammoText() == "Munición baja: 190", "arco con 190 flechas: recuadro (las balas no cuentan)")
bagSlots[0][1].stackCount = 10
step("BAG_UPDATE_DELAYED")
check(ammoText() == "Munición baja: 50", "con 50 todavía es aviso normal")
bagSlots[1][1].stackCount = 39
step("BAG_UPDATE_DELAYED")
check(ammoText() == "Munición muy baja: 49", "por debajo de 50: muy baja (rojo)")
bagSlots[0][1] = nil; bagSlots[1] = {}
bagSlots[0] = { { itemID = 2516, stackCount = 200 } }
step("BAG_UPDATE_DELAYED")
check(ammoText() == "Sin munición", "sin flechas: sin munición")
bagSlots[0] = { { itemID = 2512, stackCount = 200 }, { itemID = 2512, stackCount = 200 } }
step("BAG_UPDATE_DELAYED")
check(rawget(ammoBox(), "_shown") == false, "con 400 desaparece")
equip[18], equip[0], bags[2516] = 2508, 2516, 60
step("PLAYER_EQUIPMENT_CHANGED")
check(ammoText() == "Munición baja: 60", "arma de fuego con balas equipadas: cuenta las equipadas")
equip[18] = 5240
step("PLAYER_EQUIPMENT_CHANGED")
check(rawget(ammoBox(), "_shown") == false, "con varita no hay aviso")
equip[18] = 2508
local realClass = UnitClass
UnitClass = function() return "Guerrero", "WARRIOR" end
step("BAG_UPDATE_DELAYED")
check(rawget(ammoBox(), "_shown") == false, "un guerrero con arma de fuego no recibe el aviso")
UnitClass = realClass
step("BAG_UPDATE_DELAYED")
check(ammoText() == "Munición baja: 60", "un cazador sí")
local p = FranToolsChar.ammo.point
check(p == nil and rawget(ammoBox(), "_point")[1] == "CENTER" and rawget(ammoBox(), "_point")[5] == -160, "posición por defecto, sin guardar nada")
rawset(ammoBox(), "_point", { "TOPLEFT", UIParent, "TOPLEFT", 100, -50 })
rawget(ammoBox(), "_OnDragStop")(ammoBox())
p = FranToolsChar.ammo.point
check(p and p[1] == "TOPLEFT" and p[2] == "TOPLEFT" and p[3] == 100 and p[4] == -50, "al moverlo se guarda la posición")
openPage(3)
SlashCmdList.FRANTOOLS("municion")
check(rawget(ammoBox(), "_shown") == false and FranToolsChar.ammo.off == true, "/fran municion lo apaga y oculta el recuadro")
check(rawget(cbs[2], "_checked") == false, "y desmarca su casilla")
rawset(cbs[2], "_checked", true); rawget(cbs[2], "_OnClick")(cbs[2])
check(ammoText() == "Munición baja: 60" and FranToolsChar.ammo.off == nil, "al marcar la casilla vuelve a avisar")

-- umbrales por tipo en la pestaña Cazador
local nb = {}
for _, f in ipairs(frames) do if rawget(f, "_OnEditFocusLost") then nb[#nb+1] = f end end
local function typeIn(box, text) rawset(box, "_text", text) rawget(box, "_OnEditFocusLost")(box) end
local function textOf(box) return rawget(box, "_text") end
check(#nb == 4 and textOf(nb[1]) == "200" and textOf(nb[2]) == "50" and textOf(nb[3]) == "200" and textOf(nb[4]) == "50", "cuatro cajas con los valores por defecto (flechas y balas)")
check(FranToolsChar.ammo.thresholds == nil, "consultar los umbrales no guarda nada en el archivo")
typeIn(nb[3], "50")
check(rawget(ammoBox(), "_shown") == false and FranToolsChar.ammo.thresholds.bullet.low == 50, "balas: con aviso en 50, 60 balas ya no avisan")
check(textOf(nb[4]) == "50" and textOf(nb[1]) == "200", "las flechas no cambian")
typeIn(nb[3], "100")
check(ammoText() == "Munición baja: 60", "balas: con aviso en 100, sí")
typeIn(nb[4], "500")
check(textOf(nb[4]) == "100" and ns.Ammo.GetThreshold(3, "critical") == 100, "el rojo no puede pasar del ámbar: se ajusta")
check(ammoText() == "Munición muy baja: 60", "y entonces 60 es muy baja")
typeIn(nb[3], "40")
check(textOf(nb[3]) == "40" and textOf(nb[4]) == "40", "al bajar el ámbar por debajo del rojo, el rojo baja con él")
rawset(nb[3], "_text", "999"); rawget(nb[3], "_OnEscapePressed")(nb[3]); rawget(nb[3], "_OnEditFocusLost")(nb[3])
check(textOf(nb[3]) == "40" and ns.Ammo.GetThreshold(3, "low") == 40, "Escape descarta lo escrito")
typeIn(nb[3], "")
check(textOf(nb[3]) == "40", "caja vacía: se queda el valor que había")
typeIn(nb[3], "0")
bags[2516] = 0
step("BAG_UPDATE_DELAYED")
check(rawget(ammoBox(), "_shown") == false, "ámbar 0 apaga el aviso de ese tipo, aunque no quede ninguna")
typeIn(nb[3], "200"); typeIn(nb[4], "50")
check(FranToolsChar.ammo.thresholds.bullet.low == nil and FranToolsChar.ammo.thresholds.bullet.critical == nil, "volver al valor por defecto no lo guarda")
check(ammoText() == "Sin munición", "y con 0 balas: sin munición")
typeIn(nb[1], "300")
check(ns.Ammo.GetThreshold(2, "low") == 300 and FranToolsChar.ammo.thresholds.arrow.low == 300, "umbral de flechas guardado aparte")
-- aviso de aspecto
local function aspectBox() return _G.FranToolsAspectNotice end
local function aspectText() local b = aspectBox() return b and rawget(b, "_shown") and rawget(b.text, "_text") or nil end
known[13165], known[13163] = true, true
spellnames[13165], spellnames[13163] = "Aspecto del halcón", "Aspecto del mono"
step("UNIT_AURA", "player")
check(aspectText() == nil, "fuera de combate no avisa (por defecto, solo en combate)")
combat = true; step("PLAYER_REGEN_DISABLED")
check(aspectText() == "Sin aspecto", "en combate sin aspecto: aviso")
check(rawget(aspectBox().icon, "_tex") == 100000 + 13165, "con el icono del halcón, el que toca poner")
playerBuffs = { { name = "Aspecto del halcón", spellId = 14322 } }
step("UNIT_AURA", "player")
check(aspectText() == nil, "con el halcón (cualquier rango) desaparece")
playerBuffs = { { name = "Aspecto del guepardo", spellId = 5118 } }
timers = {}
fire("UNIT_AURA", "target")
check(#timers == 0, "las auras de otros no lo comprueban")
step("UNIT_AURA", "player")
check(aspectText() == "Aspecto: Guepardo", "con el guepardo en combate: aviso (rojo)")
playerBuffs = { { name = "Aspecto del mono" } }
step("UNIT_AURA", "player")
check(aspectText() == nil, "sin ID del aura lo reconoce por el nombre")
playerBuffs = {}
dead = true; step("PLAYER_DEAD")
check(aspectText() == nil, "muerto no avisa")
dead = false; step("PLAYER_ALIVE")
check(aspectText() == "Sin aspecto", "al revivir sí")
combat = false; step("PLAYER_REGEN_ENABLED")
check(aspectText() == nil, "al salir de combate desaparece")
-- casillas: 3 aviso, 4 solo en combate, 5..10 halcón, mono, salvaje, guepardo, manada, bestia
openPage(4)
local function click(cb, on) rawset(cb, "_checked", on); rawget(cb, "_OnClick")(cb) end
check(#cbs == 10 and rawget(cbs[3], "_checked") and rawget(cbs[4], "_checked"), "casillas del aviso de aspecto y de solo en combate, marcadas")
check(rawget(cbs[5], "_checked") and rawget(cbs[6], "_checked") and not rawget(cbs[8], "_checked"), "por defecto valen halcón y mono, no el guepardo")
local hawkLabel
for _, f in ipairs(frames) do local t = rawget(f, "_text") if type(t) == "string" and t:find("Halcón", 1, true) then hawkLabel = t end end
check(hawkLabel == "|T113165:16:16|t Halcón", "la casilla lleva el icono del aspecto")
check(FranToolsChar.aspect == nil or FranToolsChar.aspect.chosen == nil, "consultar no guarda nada")
click(cbs[4], false)
check(FranToolsChar.aspect.anytime == true and aspectText() == "Sin aspecto", "sin solo en combate avisa también fuera")
playerBuffs = { { name = "Aspecto del guepardo", spellId = 5118 } }
step("UNIT_AURA", "player")
check(aspectText() == "Aspecto: Guepardo", "viajando con el guepardo, si no vale: aviso")
click(cbs[8], true)
check(FranToolsChar.aspect.chosen.cheetah == true and aspectText() == nil, "al marcar el guepardo deja de avisar")
click(cbs[8], false)
check(FranToolsChar.aspect.chosen.cheetah == nil, "desmarcarlo vuelve al valor por defecto y no se guarda")
click(cbs[5], false); click(cbs[6], false)
check(FranToolsChar.aspect.chosen.hawk == false and FranToolsChar.aspect.chosen.monkey == false, "quitar uno que valía por defecto se guarda")
playerBuffs = {}
step("UNIT_AURA", "player")
check(aspectText() == nil, "sin ninguno marcado (que conozcas) no hay nada que avisar")
click(cbs[5], true); click(cbs[6], true); click(cbs[4], true)
check(FranToolsChar.aspect.chosen.hawk == nil and FranToolsChar.aspect.anytime == nil and aspectText() == nil, "todo como al principio")
SlashCmdList.FRANTOOLS("aspecto")
check(FranToolsChar.aspect.off == true and rawget(cbs[3], "_checked") == false, "/fran aspecto lo apaga y desmarca la casilla")
combat = true; step("PLAYER_REGEN_DISABLED")
check(aspectText() == nil, "apagado no avisa")
SlashCmdList.FRANTOOLS("aspecto")
check(aspectText() == "Sin aspecto", "al encenderlo comprueba enseguida")
combat = false; step("PLAYER_REGEN_ENABLED")
known[13165], known[13163] = false, false
-- vendedor: vender la basura y reparar
local function junk(id, count) return { itemID = id, stackCount = count or 1, quality = 0 } end
local function lastPrinted() return printed[#printed] end
printed = {}
bagSlots = { [0] = { junk(1001, 3), { itemID = 1002, stackCount = 1, quality = 1 }, { itemID = 1003, quality = 0, hasNoValue = true },
                     { itemID = 1004, quality = 0, isLocked = true } },
             [1] = { junk(1005) } }
prices[1001], prices[1005] = 10, 250
repairCost = 1234
fire("MERCHANT_SHOW")
check(#sold == 2 and sold[1] == 1001 and sold[2] == 1005, "vende solo la basura que se puede: ni blancos, ni sin valor, ni bloqueados")
check(hasPrinted("basura vendida: 2 objetos por 2p 80c."), "cuenta lo vendido (pilas incluidas) en el chat")
check(repaired == 1 and printed[#printed]:find("equipo reparado por 12p 34c.", 1, true), "y después repara")
fire("MERCHANT_CLOSED")

sold = {}; bagSlots = { [0] = {} }
for i = 1, 25 do bagSlots[0][i] = junk(2000 + i) end
timers = {}
fire("MERCHANT_SHOW")
check(#sold == 10 and #timers == 1, "vende en tandas de 10")
runTimers(); runTimers()
check(#sold == 25 and #timers == 0 and hasPrinted("basura vendida: 25 objetos por 0c."), "las tandas siguen hasta acabar")
fire("MERCHANT_CLOSED")

sold = {}; bagSlots = { [0] = {} }
for i = 1, 15 do bagSlots[0][i] = junk(3000 + i) end
fire("MERCHANT_SHOW"); fire("MERCHANT_CLOSED"); runTimers()
check(#sold == 10, "al cerrar el vendedor deja de vender")

sold = {}; bagSlots = { [0] = {} }
for i = 1, 11 do bagSlots[0][i] = junk(4000 + i) rejected[4000 + i] = true end
fire("MERCHANT_SHOW"); runTimers(); runTimers()
check(#sold == 11 and #timers == 0, "lo que el vendedor rechaza no se intenta otra vez")
fire("MERCHANT_CLOSED")

sold, printed = {}, {}
bagSlots = { [0] = { junk(1001) } }
repairCost, shift = 500, true
fire("MERCHANT_SHOW")
check(#sold == 0 and repaired == 1, "con Mayús pulsada no hace nada")
fire("MERCHANT_CLOSED"); shift = false

bagSlots, money, repairCost = { [0] = {} }, 100, 1234
fire("MERCHANT_SHOW")
check(repaired == 1 and hasPrinted("reparar cuesta 12p 34c y no te llega."), "sin dinero suficiente no repara y lo dice")
fire("MERCHANT_CLOSED")

money, canRepair = 5000, false
fire("MERCHANT_SHOW")
check(repaired == 1, "un vendedor que no repara: nada")
fire("MERCHANT_CLOSED"); canRepair = true

openPage(1)
check(#gcbs == 3 and rawget(gcbs[1], "_checked") == true and rawget(gcbs[2], "_checked") == true, "página General: reparar y vender, marcadas")
click(gcbs[1], false)
check(FranToolsChar.repair.off == true, "desmarcar reparar se guarda")
bagSlots = { [0] = { junk(1001) } }
sold = {}
fire("MERCHANT_SHOW")
check(#sold == 1 and repaired == 1, "sin reparar: vende pero no repara")
fire("MERCHANT_CLOSED")
click(gcbs[2], false)
SlashCmdList.FRANTOOLS("reparar")
check(FranToolsChar.junk.off == true and FranToolsChar.repair.off == nil and rawget(gcbs[1], "_checked") == true, "/fran reparar lo enciende y marca la casilla")
bagSlots = { [0] = { junk(1001) } }
sold = {}
fire("MERCHANT_SHOW")
check(#sold == 0 and repaired == 2, "sin vender: repara igual")
fire("MERCHANT_CLOSED")
SlashCmdList.FRANTOOLS("basura")
check(FranToolsChar.junk.off == nil and rawget(gcbs[2], "_checked") == true, "/fran basura lo enciende")
-- agro en las barras de nombre
local function plate(unit)
  local pl = newObj()
  local uf = newObj() rawset(uf, "healthBar", newObj()) rawset(pl, "UnitFrame", uf)
  plates[unit] = pl
  return pl
end
local function badge(pl) return ns.ThreatBadge.Get(pl) end
local function shownBadge(pl) local b = badge(pl) return b and rawget(b, "_shown") and b or nil end
local function badgeColor(pl) return rawget(shownBadge(pl).edges[1], "_ctex") end
local function sameColor(c, key) local w = ns.Const.THREAT.COLOR[key] return c[1] == w[1] and c[2] == w[2] and c[3] == w[3] end
local p1, p2 = plate("nameplate1"), plate("nameplate2")
fire("NAME_PLATE_UNIT_ADDED", "nameplate1")
check(badge(p1) == nil, "sin combate con el enemigo no lleva nada (ni se crea)")
pet = true
threat.pet.nameplate1 = { true, 3, 100 }
threat.player.nameplate1 = { false, 0, 42.4 }
step("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check(shownBadge(p1) and sameColor(badgeColor(p1), "pet") and rawget(badge(p1).text, "_text") == "42%", "lo tiene la mascota: verde y tu amenaza")
check(rawget(badge(p1), "_point")[2] == rawget(rawget(p1, "UnitFrame"), "healthBar"), "rodea la barra de vida")
threat.player.nameplate1 = { false, 0, 85 }
step("UNIT_THREAT_LIST_UPDATE", "target")
check(sameColor(badgeColor(p1), "warning") and rawget(badge(p1).text, "_text") == "85%", "cerca de quitárselo a la mascota: ámbar, aunque llegue con otro token")
threat.player.nameplate1 = { false, 1, 60 }
step("UNIT_THREAT_SITUATION_UPDATE", "player")
check(sameColor(badgeColor(p1), "warning"), "con más amenaza que quien tanquea (situación 1): ámbar")
threat.player.nameplate1 = { true, 3, 100 }; threat.pet.nameplate1 = { false, 0, 70 }
step("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check(sameColor(badgeColor(p1), "player") and rawget(badge(p1).text, "_text") == "100%", "va a por ti: rojo")
threat.player.nameplate2 = { false, 0, 20 }
step("NAME_PLATE_UNIT_ADDED", "nameplate2")
check(shownBadge(p2) and sameColor(badgeColor(p2), "other"), "lo tiene otro: gris")
threat.player.nameplate2 = nil
step("UNIT_THREAT_LIST_UPDATE", "nameplate2")
check(shownBadge(p2) == nil, "al salir de su lista de amenaza se quita")
threat.player.nameplate1, threat.pet.nameplate1 = nil, { true, 3, 100 }
step("UNIT_THREAT_LIST_UPDATE", "nameplate1")
check(sameColor(badgeColor(p1), "pet") and rawget(badge(p1).text, "_text") == "", "solo la mascota en combate: verde sin porcentaje")
fire("NAME_PLATE_UNIT_REMOVED", "nameplate1")
check(shownBadge(p1) == nil, "la barra que se va se limpia")
plates.nameplate3 = newObj()
rawset(plates.nameplate3, "IsForbidden", function() return true end)
threat.player.nameplate3 = { true, 3, 100 }
step("NAME_PLATE_UNIT_ADDED", "nameplate3")
check(badge(plates.nameplate3) == nil, "las barras protegidas no se tocan")
plates.nameplate3 = nil
fire("NAME_PLATE_UNIT_ADDED", "nameplate1")
check(shownBadge(p1), "al volver, se pinta enseguida")
openPage(1)
check(rawget(gcbs[3], "_checked") == true, "casilla del agro marcada")
click(gcbs[3], false)
check(FranToolsChar.threat.off == true and shownBadge(p1) == nil, "al desmarcarla se quitan los marcos")
SlashCmdList.FRANTOOLS("agro")
check(FranToolsChar.threat.off == nil and shownBadge(p1) and rawget(gcbs[3], "_checked") == true, "/fran agro lo enciende y vuelve a pintar")
-- barra de nombre del cliente moderno: la unidad en el UnitFrame y la barra
-- de vida dentro de HealthBarsContainer
local p4 = newObj()
local uf4, hb4 = newObj(), newObj()
rawset(hb4, "_level", 7)
rawset(uf4, "unit", "nameplate4"); rawset(uf4, "HealthBarsContainer", { healthBar = hb4 })
rawset(p4, "UnitFrame", uf4); rawset(p4, "_modern", true)
plates.nameplate4 = p4
threat.player.nameplate4 = { true, 3, 100 }
step("UNIT_THREAT_LIST_UPDATE", "nameplate4")
check(shownBadge(p4) and rawget(badge(p4), "_point")[2] == hb4, "cliente moderno: encuentra la unidad y la barra de vida")
check(rawget(badge(p4), "_level") == 7 + ns.Const.THREAT.LEVEL_ABOVE, "el marco va por encima de la barra de vida")
check(rawget(badge(p1), "_level") == 1 + ns.Const.THREAT.LEVEL_ABOVE, "también en las clásicas")
-- /fran agro estado
printed = {}
SlashCmdList.FRANTOOLS("agro estado")
check(hasPrinted("selecciona un enemigo") and FranToolsChar.threat.off == nil, "agro estado sin objetivo: lo pide y no apaga nada")
unitNames.target = "Lobo"; plates.target = p4; threat.player.target = { true, 3, 100 }
printed = {}
SlashCmdList.FRANTOOLS("agro estado")
check(hasPrinted("objetivo: Lobo") and hasPrinted("barra de nombre: sí") and hasPrinted("barra de vida dentro: sí")
      and hasPrinted("el juego da la amenaza: sí") and hasPrinted("tanqueando sí, situación 3, 100%") and hasPrinted("marco de agro: visible"),
      "agro estado: repasa cada paso con el objetivo")
check(FranToolsChar.threat.off == nil, "y no cambia el interruptor")
unitNames.target, plates.target, threat.player.target, plates.nameplate4, threat.player.nameplate4 = nil, nil, nil, nil, nil
pet = false; threat.pet.nameplate1 = nil
-- ayudas de otras clases
local realUnitClass = UnitClass
local function asClass(class) UnitClass = function() return class, class end end
local function boxText(name) local b = _G[name] return b and rawget(b, "_shown") and rawget(b.text, "_text") or nil end
local function boxLevel(name) local c = rawget(_G[name].text, "_color") return c[2] == 0.25 and "critical" or "warning" end
local function boxY(name) return rawget(_G[name], "_point")[5] end
combat = true

-- guerrero: Grito de guerra
asClass("WARRIOR")
known[6673] = true; spellnames[6673] = "Grito de guerra"
playerBuffs = {}
step("PLAYER_REGEN_DISABLED")
check(boxText("FranToolsBattleShoutNotice") == "Sin Grito de guerra", "guerrero en combate sin Grito de guerra: aviso ámbar")
check(boxText("FranToolsAspectNotice") == nil, "a un guerrero no le sale el aviso de aspecto")
playerBuffs = { { name = "Grito de guerra", spellId = 25289 } }
step("UNIT_AURA", "player")
check(boxText("FranToolsBattleShoutNotice") == nil, "con el grito (cualquier rango, también el de otro guerrero) desaparece")
playerBuffs = {}
SlashCmdList.FRANTOOLS("grito")
step("UNIT_AURA", "player")
check(FranToolsChar.battleShout.off == true and boxText("FranToolsBattleShoutNotice") == nil, "/fran grito lo apaga")
SlashCmdList.FRANTOOLS("grito")
check(boxText("FranToolsBattleShoutNotice") == "Sin Grito de guerra", "y lo enciende")
ns.BattleShout.SetCombatOnly(false); combat = false; step("PLAYER_REGEN_ENABLED")
check(boxText("FranToolsBattleShoutNotice") == "Sin Grito de guerra", "sin solo en combate avisa también fuera")
ns.BattleShout.SetCombatOnly(true)
check(boxText("FranToolsBattleShoutNotice") == nil and FranToolsChar.battleShout.anytime == nil, "con solo en combate, fuera no avisa")
combat = true

-- brujo: fragmentos, piedra de salud y armadura
asClass("WARLOCK")
step("PLAYER_REGEN_DISABLED")
check(boxText("FranToolsBattleShoutNotice") == nil, "al cambiar de clase se quitan los avisos de la otra")
bags[6265] = 0
step("BAG_UPDATE_DELAYED")
check(boxText("FranToolsShardsNotice") == nil, "brujo de nivel bajo (sin Drenar alma): no avisa de fragmentos")
known[687], known[6201], known[1120] = true, true, true
spellnames[687] = "Piel de demonio"
bags[6265] = 3
step("SPELLS_CHANGED")
check(boxText("FranToolsShardsNotice") == "Fragmentos de alma: 3" and boxLevel("FranToolsShardsNotice") == "warning", "3 fragmentos: ámbar")
bags[6265] = 1; step("BAG_UPDATE_DELAYED")
check(boxText("FranToolsShardsNotice") == "Fragmentos de alma: 1" and boxLevel("FranToolsShardsNotice") == "critical", "1 fragmento: rojo")
bags[6265] = 0; step("BAG_UPDATE_DELAYED")
check(boxText("FranToolsShardsNotice") == "Sin fragmentos de alma", "sin fragmentos")
check(boxText("FranToolsHealthstoneNotice") == "Sin piedra de salud" and boxLevel("FranToolsHealthstoneNotice") == "warning", "sin piedra de salud: ámbar")
check(boxText("FranToolsDemonArmorNotice") == "Sin armadura" and rawget(_G.FranToolsDemonArmorNotice.icon, "_tex") == 100000 + 687,
      "sin armadura, con el icono de la que sabes (Piel de demonio)")
local ys = { boxY("FranToolsShardsNotice"), boxY("FranToolsHealthstoneNotice"), boxY("FranToolsDemonArmorNotice") }
check(ys[1] == -160 and ys[2] == -200 and ys[3] == -240, "tres avisos a la vez: apilados, sin taparse")
bags[5509] = 1; step("BAG_UPDATE_DELAYED")
check(boxText("FranToolsHealthstoneNotice") == nil and boxY("FranToolsDemonArmorNotice") == -200, "al quitarse uno, los de debajo suben")
bags[5509] = 0; known[6201] = false; step("BAG_UPDATE_DELAYED")
check(boxText("FranToolsHealthstoneNotice") == nil, "sin saber crear la piedra no avisa")
playerBuffs = { { name = "Piel de demonio", spellId = 696 } }
step("UNIT_AURA", "player")
check(boxText("FranToolsDemonArmorNotice") == nil, "con Piel de demonio desaparece el de armadura")
playerBuffs = {}; combat = false; step("PLAYER_REGEN_ENABLED")
check(boxText("FranToolsDemonArmorNotice") == "Sin armadura", "la armadura avisa también fuera de combate de entrada")
check(ns.DemonArmor.IsCombatOnly() == false and FranToolsChar.demonArmor.anytime == nil, "sin guardar nada")
ns.DemonArmor.SetCombatOnly(true)
check(boxText("FranToolsDemonArmorNotice") == nil and FranToolsChar.demonArmor.anytime == false, "marcando solo en combate deja de avisar fuera, y se guarda")
ns.DemonArmor.SetCombatOnly(false)
check(FranToolsChar.demonArmor.anytime == nil and boxText("FranToolsDemonArmorNotice") == "Sin armadura", "volver a lo de entrada no guarda nada")
playerBuffs = { { name = "Piel de demonio", spellId = 696 } }; combat = true; step("PLAYER_REGEN_DISABLED")
ns.Shards.SetThreshold("low", 0)
check(boxText("FranToolsShardsNotice") == nil and FranToolsChar.shards.thresholds.count.low == 0, "ámbar 0 apaga el aviso de fragmentos")
ns.Shards.SetThreshold("critical", 9)
check(ns.Shards.GetThreshold("critical") == 0, "el rojo no pasa del ámbar")
ns.Shards.SetThreshold("low", 5)
check(FranToolsChar.shards.thresholds.count.low == nil and boxText("FranToolsShardsNotice") == "Sin fragmentos de alma", "volver al valor por defecto no lo guarda")
SlashCmdList.FRANTOOLS("fragmentos")
check(FranToolsChar.shards.off == true and boxText("FranToolsShardsNotice") == nil, "/fran fragmentos lo apaga")
SlashCmdList.FRANTOOLS("fragmentos")
-- Tormento del abisario
local before = #warnings
pet, instance = true, "party"
spellnames[3716] = "Tormento"
petBar = { { "Atacar" }, [5] = { "Tormento", 3716, true } }
step("PET_BAR_UPDATE")
check(#warnings == before + 1 and warnings[#warnings]:find("Tormento de la mascota ACTIVADO", 1, true), "Tormento del abisario activado en mazmorra: aviso")
petBar[5] = { "Tormento", nil, false }
step("PET_BAR_UPDATE")
check(hasPrinted("Tormento de la mascota desactivado: correcto"), "sin ID lo reconoce por el nombre")
pet, instance, petBar = false, "none", {}

-- paladín: aura, bendición y Furia justa
asClass("PALADIN")
known[465], known[7294], known[19740], known[25780] = true, true, true, true
spellnames[465], spellnames[19740], spellnames[25780] = "Aura de devoción", "Bendición del poderío", "Furia justa"
playerBuffs = {}
step("PLAYER_ENTERING_WORLD")   -- cambiar de personaje es una pantalla de carga
check(boxText("FranToolsDemonArmorNotice") == nil and boxText("FranToolsShardsNotice") == nil, "al pasar a paladín se quitan los del brujo")
check(boxText("FranToolsAuraNotice") == "Sin aura" and boxText("FranToolsBlessingNotice") == "Sin bendición", "en combate sin aura ni bendición: avisos")
playerBuffs = { { name = "Aura de devoción", spellId = 10293 }, { name = "Bendición superior de reyes", spellId = 25898 } }
step("UNIT_AURA", "player")
check(boxText("FranToolsAuraNotice") == nil and boxText("FranToolsBlessingNotice") == nil, "con aura y una bendición de otro paladín, nada")
ns.Aura.SetChosen(ns.Const.PALADIN.AURAS[1], false)
check(boxText("FranToolsAuraNotice") == "Aura: Devoción" and boxLevel("FranToolsAuraNotice") == "critical", "con un aura sin marcar: rojo")
check(rawget(_G.FranToolsAuraNotice.icon, "_tex") == 100000 + 7294, "con el icono de la que vale (Castigo)")
ns.Aura.SetChosen(ns.Const.PALADIN.AURAS[1], true)
check(FranToolsChar.aura.chosen.devotion == nil and boxText("FranToolsAuraNotice") == nil, "marcarla otra vez vuelve al valor por defecto")
playerBuffs[3] = { name = "Furia justa", spellId = 25780 }
step("UNIT_AURA", "player")
check(boxText("FranToolsRighteousFuryNotice") == nil, "solo, Furia justa no avisa")
inGroup = true; step("GROUP_ROSTER_UPDATE")
check(boxText("FranToolsRighteousFuryNotice") == "Furia justa: quítala" and boxLevel("FranToolsRighteousFuryNotice") == "critical", "en grupo sin tanquear y con Furia justa: rojo")
ns.RighteousFury.SetManualTank(true)
check(FranToolsChar.righteousFury.tank == true and boxText("FranToolsRighteousFuryNotice") == nil, "con Tanqueo yo, llevarla es lo correcto")
playerBuffs[3] = nil; step("UNIT_AURA", "player")
check(boxText("FranToolsRighteousFuryNotice") == "Sin Furia justa" and boxLevel("FranToolsRighteousFuryNotice") == "warning", "tanqueando sin ella: ámbar")
groupRole = "DAMAGER"; step("PLAYER_ROLES_ASSIGNED")
check(boxText("FranToolsRighteousFuryNotice") == nil, "el rol del grupo manda sobre la casilla")
groupRole = "TANK"; ns.RighteousFury.SetManualTank(false); step("PLAYER_ROLES_ASSIGNED")
check(boxText("FranToolsRighteousFuryNotice") == "Sin Furia justa" and FranToolsChar.righteousFury.tank == nil, "con rol de tanque, sin la casilla, también")
inGroup, groupRole = false, "NONE"; step("GROUP_ROSTER_UPDATE")
check(boxText("FranToolsRighteousFuryNotice") == nil, "al dejar el grupo se quita")

-- páginas de las clases nuevas: se dibujan y leen sin errores
local titles = {}
for _, class in ipairs({ "WARRIOR", "WARLOCK", "PALADIN" }) do
  for _, page in ipairs(ns.ClassPages.For(class).pages) do
    ns.OptionsPage.Build(CreateFrame("Frame"), page.rows)()
    titles[#titles + 1] = page.title
  end
end
check(table.concat(titles, ",") == "Gritos,Mascota,Reactivos,Armadura,Aura,Bendición,Furia justa", "páginas de guerrero, brujo y paladín")
printed = {}
SlashCmdList.FRANTOOLS("ayuda")
check(hasPrinted("/fran furia") and hasPrinted("/fran fragmentos") and hasPrinted("/fran grito"), "la ayuda lista los comandos nuevos")

-- valores secretos: el cliente oculta auras y amenaza en combate
local logged = #ns.ErrorLog.Entries()
asClass("WARLOCK")
known[687] = true; spellnames[687] = "Piel de demonio"
local function armorText() return boxText("FranToolsDemonArmorNotice") end
combat = false; playerBuffs = { { name = "Piel de demonio", spellId = 696 } }
step("UNIT_AURA", "player")
check(armorText() == nil, "fuera de combate con armadura: nada")
combat, aurasSecret, aurasByIdSecret = true, true, true
step("PLAYER_REGEN_DISABLED")
check(armorText() == nil, "en combate con las auras ocultas vale la de antes de empezar")
aurasSecret, aurasByIdSecret, combat, playerBuffs = false, false, false, {}
step("PLAYER_REGEN_ENABLED")
check(armorText() == "Sin armadura", "fuera de combate sin armadura: aviso")
combat, aurasSecret, aurasByIdSecret = true, true, true
step("PLAYER_REGEN_DISABLED")
check(armorText() == "Sin armadura", "sin armadura antes de empezar, en combate sigue avisando")
aurasByIdSecret = false
playerBuffs = { { name = "Piel de demonio", spellId = 696 } }
step("UNIT_AURA", "player")
check(armorText() == nil, "si el juego deja preguntar hechizo a hechizo, se entera en combate")
aurasSecret, combat = false, false
step("PLAYER_REGEN_ENABLED")
-- lo que pasaba en el juego: preguntar por ID dice "no" aunque lo lleves
combat, aurasSecret, aurasByIdSecret = true, true, "nil"
step("PLAYER_REGEN_DISABLED")
check(armorText() == nil, "en combate, un 'no' al preguntar por ID no hace saltar el aviso si la llevabas")
step("UNIT_AURA", "player")
check(armorText() == nil, "ni al cambiar las auras durante la pelea")
aurasSecret, aurasByIdSecret, combat, playerBuffs = false, false, false, {}
step("PLAYER_REGEN_ENABLED")
check(armorText() == "Sin armadura", "fuera de combate se vuelve a leer: sin armadura, aviso")
-- guerrero que grita en mitad de la pelea, con todo oculto
asClass("WARRIOR")
known[6673] = true; spellnames[6673] = "Grito de guerra"
combat, aurasSecret, aurasByIdSecret = true, true, "nil"
step("PLAYER_REGEN_DISABLED")
check(boxText("FranToolsBattleShoutNotice") == "Sin Grito de guerra", "guerrero sin grito al empezar: aviso")
step("UNIT_SPELLCAST_SUCCEEDED", "player", "cast-1", 11551)
check(boxText("FranToolsBattleShoutNotice") == nil, "al lanzar el grito en combate se quita, aunque las auras estén ocultas")
step("UNIT_SPELLCAST_SUCCEEDED", "player", "cast-2", SECRET)
check(boxText("FranToolsBattleShoutNotice") == nil, "un hechizo lanzado con el ID oculto no rompe nada")
step("UNIT_SPELLCAST_SUCCEEDED", "party1", "cast-3", 6673)
aurasSecret, aurasByIdSecret, combat = false, false, false
step("PLAYER_REGEN_ENABLED")
asClass("WARLOCK")
local p5 = plate("nameplate5")
threat.player.nameplate5 = { SECRET, SECRET, SECRET }
printed = {}
step("UNIT_THREAT_LIST_UPDATE", "nameplate5")
check(shownBadge(p5) == nil and hasPrinted("no deja a los addons leer la amenaza"), "amenaza secreta: sin marco y lo explica en el chat")
printed = {}
step("UNIT_THREAT_LIST_UPDATE", "nameplate5")
check(not hasPrinted("no deja a los addons"), "la explicación sale una vez por sesión")
unitNames.target, plates.target, threat.player.target = "Lobo", p5, threat.player.nameplate5
printed = {}
SlashCmdList.FRANTOOLS("agro estado")
check(hasPrinted("tu amenaza: oculta por el juego"), "agro estado dice que la amenaza está oculta")
check(#ns.ErrorLog.Entries() == logged, "auras y amenaza ocultas no dan errores de Lua")
unitNames.target, plates.target, threat.player.target, plates.nameplate5, threat.player.nameplate5 = nil, nil, nil, nil, nil

-- registro de errores
local Log = ns.ErrorLog
local function ownErrors() local n = 0 for _, l in ipairs(printed) do if l:find("prueba de error", 1, true) then n = n + 1 end end return n end
check(Log.Entries()[1].message:find("prueba de error temprana", 1, true), "un error antes de cargar la variable se guarda al cargarla")
local base = #Log.Entries()
check(FranToolsLog.entries[1].count == 1 and FranToolsLog.entries[1].version == "0.1.0", "con cuántas veces y la versión")
local after = false
ns.Util.On("PRUEBA_ERROR", function() error("prueba de error en un evento") end)
ns.Util.On("PRUEBA_ERROR", function() after = true end)
printed = {}
fire("PRUEBA_ERROR")
check(after, "un error en una función de un evento no impide las demás")
check(ownErrors() == 1, "el error sigue llegando al manejador de antes")
local heard = false
check(ns.Util.OnIfExists("TRADE_SKILL_UPDATE", function() heard = true end) == false, "un evento que el cliente no tiene no se registra, sin error")
check(ns.Util.OnIfExists("PRUEBA_EXISTE", function() heard = true end) == true, "uno que sí tiene, se registra")
fire("PRUEBA_EXISTE")
check(heard, "y se escucha")
check(#Log.Entries() == base + 1 and Log.Entries()[base + 1].stack:find("Prueba.lua:7", 1, true), "se apunta con su pila")
check(not Log.Entries()[base + 1].stack:find("ErrorLog.lua", 1, true), "sin las líneas del propio registro")
fire("PRUEBA_ERROR")
check(#Log.Entries() == base + 1 and Log.Entries()[base + 1].count == 2, "el mismo error otra vez suma, no se repite")
local notices = 0 for _, l in ipairs(printed) do if l:find("/fran errores para verlo", 1, true) then notices = notices + 1 end end
check(notices == 0, "el aviso del chat solo sale una vez por sesión (ya salió con el primero)")
fakeStack = "Interface/AddOns/OtroAddon/Main.lua:3: in function <y>"
geterrorhandler()("Interface/AddOns/OtroAddon/Main.lua:3: prueba de error ajena")
check(#Log.Entries() == base + 1 and ownErrors() == 3, "los errores de otros addons no se apuntan, pero siguen su camino")
fakeStack = string.rep("Interface/AddOns/FranTools/Core/Larga.lua:1: in function <z>\n", 100)
geterrorhandler()("prueba de error larga")
check(#Log.Entries()[base + 2].stack <= ns.Const.ERROR_LOG.MAX_STACK_CHARS, "la pila se recorta")
fakeStack = nil
printed = {}
SlashCmdList.FRANTOOLS("errores")
check(hasPrinted((base + 2) .. " errores apuntados") and hasPrinted("x2  ") and hasPrinted("prueba de error en un evento"), "/fran errores: la lista")
printed = {}
SlashCmdList.FRANTOOLS("errores " .. (base + 1))
check(hasPrinted("error " .. (base + 1) .. ", versión 0.1.0, 2 veces") and hasPrinted("Core/Prueba.lua:7"), "/fran errores <n>: uno con su pila, sin la ruta del addon")
printed = {}
SlashCmdList.FRANTOOLS("errores 9")
check(hasPrinted("no hay ningún error con el número 9"), "un número que no está")
for i = 1, 60 do geterrorhandler()("prueba de error número " .. i) end
check(#Log.Entries() == ns.Const.ERROR_LOG.MAX_ENTRIES and Log.Entries()[1].message == "prueba de error número 11", "como mucho 50: se van los más antiguos")
SlashCmdList.FRANTOOLS("errores borrar")
check(#Log.Entries() == 0 and #FranToolsLog.entries == 0, "/fran errores borrar vacía la lista")
local kept = {} for _, l in ipairs(printed) do if not l:find("prueba de error", 1, true) then kept[#kept + 1] = l end end
printed = kept

UnitClass = realUnitClass
combat, playerBuffs = false, {}
step("PLAYER_REGEN_ENABLED")
check(not hasPrinted("ERROR"), "sin errores de Lua")

__SV = dumpSV()
