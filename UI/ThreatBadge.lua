--[[
Indicador de agro en una barra de nombre
========================================

Un marco fino de color alrededor de la barra de vida de una barra de nombre
de Blizzard y un texto a su derecha (el porcentaje de amenaza). No cambia la
barra en sí: si se tocara su color, el juego lo volvería a pintar con el suyo
en cada actualización.

  ns.ThreatBadge.Show(plate, { r, g, b }, "85%")
  ns.ThreatBadge.ShowSecret(plate, { tanking, petTanking, percent, hasPercent }, scheme)
  ns.ThreatBadge.Hide(plate)
  ns.ThreatBadge.Get(plate)   -- el indicador de esa barra, o nil

Show pinta lo que el addon ya ha decidido. ShowSecret es para cuando el
juego oculta la amenaza (valores secretos, en combate): el addon no puede
mirarla, pero sí dársela a la interfaz para que la pinte. scheme dice los
colores { player, pet, other, warning }: los de siempre o los del tanque
(Features/Threat.lua). Se monta en dos capas:

  * el marco: player si va a por ti; si no, pet si va a por tu mascota; si
    no, other. Lo decide el juego con SetVertexColorFromBoolean, que acepta
    un "sí o no" secreto.
  * encima, si scheme trae warning ("estás a punto"): una barra en cada
    lado, que va de WARN_PERCENT - WARN_RAMP a WARN_PERCENT. Por debajo
    queda vacía y por encima se llena entera: hace de umbral sin que el
    addon compare nada. Si va a por ti, se pinta del color player, que manda.
  * el porcentaje se escribe con SetFormattedText, que también lo acepta.

El juego reutiliza las barras de nombre de unas unidades para otras: cada una
tiene su indicador, creado la primera vez que hace falta, y quien lo usa lo
pone al día cuando la barra cambia de unidad. Se guardan en una tabla propia
en lugar de en un campo del marco de Blizzard, para no mezclar nada nuestro
con sus marcos.
]]

local _, ns = ...
local Api = ns.Api
local T = ns.Const.THREAT

local ThreatBadge = {}
ns.ThreatBadge = ThreatBadge

local badges = {}   -- barra de nombre -> indicador
local WHITE = { 1, 1, 1 }

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

-- Los cuatro lados del marco: { punto 1, punto 2, es horizontal }.
local EDGES = {
    { "TOPLEFT", "TOPRIGHT", true },
    { "BOTTOMLEFT", "BOTTOMRIGHT", true },
    { "TOPLEFT", "BOTTOMLEFT", false },
    { "TOPRIGHT", "BOTTOMRIGHT", false },
}

-- Coloca una pieza a lo largo de un lado, con el grosor del marco.
local function alongEdge(piece, edge)
    piece:SetPoint(edge[1])
    piece:SetPoint(edge[2])
    if edge[3] then piece:SetHeight(T.BORDER) else piece:SetWidth(T.BORDER) end
end

local function createEdges(f)
    f.edges = {}
    for i, edge in ipairs(EDGES) do
        local t = f:CreateTexture(nil, "OVERLAY")
        alongEdge(t, edge)
        f.edges[i] = t
    end
end

-- La capa ámbar del modo secreto: una barra por lado que solo se llena al
-- pasar del umbral. Los lados verticales se llenan de abajo arriba.
local function createWarnBars(f)
    f.warnBars = {}
    for i, edge in ipairs(EDGES) do
        local bar = CreateFrame("StatusBar", nil, f)
        alongEdge(bar, edge)
        if not edge[3] then bar:SetOrientation("VERTICAL") end
        bar:SetStatusBarTexture(T.BAR_TEXTURE)
        bar:SetMinMaxValues(T.WARN_PERCENT - T.WARN_RAMP, T.WARN_PERCENT)
        bar:Hide()
        f.warnBars[i] = bar
    end
end

-- Va colgado de la barra de nombre (se oculta con ella) y rodea su barra de
-- vida, o la barra entera si su diseño no tiene una donde se espera. Se pone
-- por encima de esa barra: si no, su propio borde tapa el nuestro.
local function create(plate)
    local around = Api.NamePlateHealthBar(plate) or plate
    local f = CreateFrame("Frame", nil, plate)
    f:SetFrameLevel(around:GetFrameLevel() + T.LEVEL_ABOVE)
    f:SetPoint("TOPLEFT", around, "TOPLEFT", -T.BORDER, T.BORDER)
    f:SetPoint("BOTTOMRIGHT", around, "BOTTOMRIGHT", T.BORDER, -T.BORDER)
    createEdges(f)
    createWarnBars(f)
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.text:SetPoint("LEFT", f, "RIGHT", T.TEXT_GAP, 0)
    f:Hide()
    return f
end

local function badgeFor(plate)
    badges[plate] = badges[plate] or create(plate)
    return badges[plate]
end

--------------------------------------------------------------------------------
-- Colores del modo secreto
--------------------------------------------------------------------------------

-- Los ColorMixin se crean la primera vez que hacen falta (CreateColor es de
-- la interfaz de Blizzard) y se reutilizan, uno por color de Const.
local mixins = {}

local function mixin(rgb)
    mixins[rgb] = mixins[rgb] or Api.Color(rgb)
    return mixins[rgb]
end

local function setWarnBarsShown(f, shown)
    for _, bar in ipairs(f.warnBars) do bar:SetShown(shown) end
end

--------------------------------------------------------------------------------
-- API del componente
--------------------------------------------------------------------------------

function ThreatBadge.Get(plate)
    return badges[plate]
end

function ThreatBadge.Show(plate, color, text)
    local f = badgeFor(plate)
    for _, edge in ipairs(f.edges) do
        edge:SetVertexColor(unpack(WHITE))   -- por si antes se pintó en modo secreto
        edge:SetColorTexture(color[1], color[2], color[3])
    end
    setWarnBarsShown(f, false)
    f.text:SetText(text)
    f.text:SetTextColor(color[1], color[2], color[3])
    f:Show()
end

-- look: { tanking, petTanking, percent, hasPercent }. Los tres primeros,
-- secretos o no, no se miran aquí: solo se pasan a funciones del juego que
-- los aceptan. hasPercent (normal) dice si hay porcentaje tuyo que enseñar:
-- si solo la mascota está en combate, percent es 0 y el texto va vacío.
function ThreatBadge.ShowSecret(plate, look, scheme)
    local f = badgeFor(plate)
    local mine = mixin(scheme.player)
    local notMine = Api.ColorFromBoolean(look.petTanking, mixin(scheme.pet), mixin(scheme.other))
    for _, edge in ipairs(f.edges) do
        edge:SetColorTexture(unpack(WHITE))
        edge:SetVertexColorFromBoolean(look.tanking, mine, notMine)
    end
    if scheme.warning then
        for _, bar in ipairs(f.warnBars) do
            bar:SetValue(look.percent)
            bar:GetStatusBarTexture():SetVertexColorFromBoolean(look.tanking, mine, mixin(scheme.warning))
        end
    end
    setWarnBarsShown(f, scheme.warning ~= nil)
    f.text:SetTextColor(unpack(WHITE))
    if look.hasPercent then
        f.text:SetFormattedText(T.PERCENT_FORMAT, look.percent)
    else
        f.text:SetText("")
    end
    f:Show()
end

function ThreatBadge.Hide(plate)
    if badges[plate] then badges[plate]:Hide() end
end
