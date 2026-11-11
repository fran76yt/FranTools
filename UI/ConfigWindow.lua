--[[
Ventana de opciones (/fran config)
==================================

Una barra lateral a la izquierda (UI/Sidebar.lua) para elegir la página y el
contenido a la derecha:
  General    opciones para cualquier clase (UI/GeneralPage.lua).
  <Clase>    grupo de páginas con las opciones propias de la clase del
             personaje (UI/ClassPages), si su clase las tiene.

Todas las páginas se describen como filas (UI/OptionsPage.lua).

Se crea la primera vez que se abre: si el jugador nunca la usa, no consume nada.
Se redibuja sola cuando cambia una opción, aunque sea con un comando.
]]

local _, ns = ...
local Const, Util, Api = ns.Const, ns.Util, ns.Api
local UI = Const.UI

local ConfigWindow = {}
ns.ConfigWindow = ConfigWindow

local frame          -- la ventana (nil hasta que se abre)
local pages = {}     -- pages[i] = { frame, update } de la página i

--------------------------------------------------------------------------------
-- Páginas
--------------------------------------------------------------------------------
-- Cada entrada es { title, group?, groupColor?, rows }: group es el título
-- bajo el que se agrupa en la barra lateral.

local function entry(p, group, groupColor)
    return { title = p.title, group = group, groupColor = groupColor, rows = p.rows }
end

-- Páginas de la clase del personaje, agrupadas bajo el nombre de la clase en
-- su color.
local function classPages()
    local class = Api.PlayerClass()
    local section = ns.ClassPages.For(class)
    local list = {}
    if not section then return list end
    for i, p in ipairs(section.pages) do
        list[i] = entry(p, section.title, Api.ClassColor(class))
    end
    return list
end

local function pageList()
    local list = { entry(ns.GeneralPage) }
    for _, p in ipairs(classPages()) do list[#list + 1] = p end
    return list
end

--------------------------------------------------------------------------------
-- Dibujado
--------------------------------------------------------------------------------

-- Vuelve a leer las páginas visibles. Las ocultas se leen al mostrarlas.
local function refresh()
    if not frame or not frame:IsShown() then return end
    for _, p in ipairs(pages) do
        if p.frame:IsShown() then p.update() end
    end
end

local function showPage(index)
    for i, p in ipairs(pages) do p.frame:SetShown(i == index) end
    refresh()
end

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

-- Marco de la ventana: plantilla de Blizzard con título y botón de cerrar,
-- arrastrable y que se cierra con Escape.
local function createFrame(width)
    local f = CreateFrame("Frame", UI.FRAME_NAME, UIParent, "BasicFrameTemplateWithInset")
    f:SetSize(width, UI.HEIGHT)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetScript("OnShow", refresh)
    -- Los frames de esta lista se cierran al pulsar Escape (por su nombre global).
    table.insert(UISpecialFrames, UI.FRAME_NAME)
    -- CreateFrame devuelve el frame ya visible. Lo ocultamos para que quien lo
    -- crea decida cuándo mostrarlo (y para que OnShow salte al hacerlo).
    f:Hide()
    return f
end

-- Título con el icono del addon a la izquierda y la versión. La plantilla trae
-- TitleText en el cliente moderno; si no, creamos uno propio.
local function createTitle(f)
    local title = f.TitleText
    if not title then
        title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        title:SetPoint("TOP", 0, -5)
    end
    title:SetText(("%s  %s"):format(UI.TITLE, Util.Colorize(Const.COLOR.DIM, Api.AddOnVersion())))
    local icon = f:CreateTexture(nil, "OVERLAY")
    icon:SetSize(UI.TITLE_ICON_SIZE, UI.TITLE_ICON_SIZE)
    icon:SetPoint("RIGHT", title, "LEFT", -UI.TITLE_ICON_GAP, 0)
    icon:SetTexture(Const.ICON)
end

-- Una página por entrada, a la derecha de la barra lateral (left es su ancho).
local function createPages(f, list, left)
    for i, e in ipairs(list) do
        local page = CreateFrame("Frame", nil, f)
        page:SetPoint("TOPLEFT", left, 0)
        page:SetPoint("BOTTOMRIGHT")
        pages[i] = { frame = page, update = ns.OptionsPage.Build(page, e.rows) }
    end
end

local function create()
    local list = pageList()
    local left = ns.Sidebar.Width()
    frame = createFrame(left + UI.CONTENT_WIDTH)
    createTitle(frame)
    createPages(frame, list, left)
    ns.Sidebar.Create(frame, list, showPage):Select(1)
end

--------------------------------------------------------------------------------
-- API del módulo
--------------------------------------------------------------------------------

function ConfigWindow.Toggle()
    if not frame then create() end
    frame:SetShown(not frame:IsShown())
end

-- Una opción cambiada con un comando (/fran aviso...) se ve en su casilla.
Util.Listen(Const.MSG.SETTINGS_CHANGED, refresh)
