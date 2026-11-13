--[[
Indicador de agro en una barra de nombre
========================================

Un marco fino de color alrededor de la barra de vida de una barra de nombre
de Blizzard y un texto a su derecha (el porcentaje de amenaza). No cambia la
barra en sí: si se tocara su color, el juego lo volvería a pintar con el suyo
en cada actualización.

  ns.ThreatBadge.Show(plate, { r, g, b }, "85%")
  ns.ThreatBadge.Hide(plate)
  ns.ThreatBadge.Get(plate)   -- el indicador de esa barra, o nil

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

local function createEdges(f)
    f.edges = {}
    for i, e in ipairs(EDGES) do
        local t = f:CreateTexture(nil, "OVERLAY")
        t:SetPoint(e[1])
        t:SetPoint(e[2])
        if e[3] then t:SetHeight(T.BORDER) else t:SetWidth(T.BORDER) end
        f.edges[i] = t
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
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.text:SetPoint("LEFT", f, "RIGHT", T.TEXT_GAP, 0)
    f:Hide()
    return f
end

--------------------------------------------------------------------------------
-- API del componente
--------------------------------------------------------------------------------

function ThreatBadge.Get(plate)
    return badges[plate]
end

function ThreatBadge.Show(plate, color, text)
    badges[plate] = badges[plate] or create(plate)
    local f = badges[plate]
    for _, edge in ipairs(f.edges) do edge:SetColorTexture(color[1], color[2], color[3]) end
    f.text:SetText(text)
    f.text:SetTextColor(color[1], color[2], color[3])
    f:Show()
end

function ThreatBadge.Hide(plate)
    if badges[plate] then badges[plate]:Hide() end
end
