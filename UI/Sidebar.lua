--[[
Barra lateral de navegación
===========================

Una columna a la izquierda de una ventana con una entrada por página, como
las listas de categorías de las opciones del juego. Las entradas seguidas con
el mismo "group" se agrupan bajo un título con ese nombre (y su color, si lo
trae), con sangría. La entrada elegida se marca con fondo y raya dorados.

Los grupos se pliegan y despliegan con un clic en su título (con un más o un
menos a la derecha, como las listas plegables del juego). Si se le pasa una
tabla "collapsed", los grupos plegados se apuntan en ella (collapsed[grupo] =
true) y la barra los respeta al crearse: quien la usa decide si se guardan.

  local nav = ns.Sidebar.Create(window, {
      { title = "General" },
      { title = "Mascota", group = "Cazador", groupColor = { r, g, b } },
      { title = "Munición", group = "Cazador", groupColor = { r, g, b } },
  }, function(i) ... end, collapsed)   -- se llama al elegir la entrada i
  nav:Select(1)

Todo se dibuja con texturas de color liso, sin plantillas de Blizzard, que
cambian de nombre y de aspecto según el cliente.
]]

local _, ns = ...
local NAV = ns.Const.UI.NAV

local Sidebar = {}
ns.Sidebar = Sidebar

--------------------------------------------------------------------------------
-- Piezas
--------------------------------------------------------------------------------

-- Textura de color liso. Sin puntos de anclaje ocupa todo el marco.
local function colorTexture(parent, layer, color)
    local t = parent:CreateTexture(nil, layer)
    t:SetColorTexture(unpack(color))
    return t
end

-- Fondo oscuro y una línea fina a la derecha que separa del contenido.
local function createBackground(bar)
    colorTexture(bar, "BACKGROUND", NAV.BACKGROUND_COLOR):SetAllPoints()
    local line = colorTexture(bar, "BORDER", NAV.DIVIDER_COLOR)
    line:SetWidth(NAV.DIVIDER_WIDTH)
    line:SetPoint("TOPRIGHT")
    line:SetPoint("BOTTOMRIGHT")
end

-- Con nombre global si la ventana lo tiene (<Ventana>Nav1, <Ventana>Group1...):
-- así lo encuentran otros addons y las pruebas.
local function childName(bar, kind, index)
    local parentName = bar:GetParent():GetName()
    return parentName and (parentName .. kind .. index) or nil
end

-- Fila pulsable de la barra, con fondo al pasar el ratón (capa HIGHLIGHT, que
-- el juego muestra sola). Su posición la pone Layout.
local function createRow(bar, name)
    local b = CreateFrame("Button", name, bar)
    b:SetHeight(NAV.ENTRY_HEIGHT)
    colorTexture(b, "HIGHLIGHT", NAV.HOVER_COLOR):SetAllPoints()
    return b
end

-- Título de un grupo: su nombre (en su color) y el más o el menos de plegar.
local function createHeader(bar, entry, index)
    local h = createRow(bar, childName(bar, "Group", index))
    h.label = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h.label:SetPoint("LEFT", NAV.TEXT_LEFT, 0)
    h.label:SetText(entry.group)
    if entry.groupColor then h.label:SetTextColor(unpack(entry.groupColor)) end
    h.toggle = h:CreateTexture(nil, "ARTWORK")
    h.toggle:SetSize(NAV.TOGGLE_SIZE, NAV.TOGGLE_SIZE)
    h.toggle:SetPoint("RIGHT", NAV.TOGGLE_RIGHT, 0)
    h:SetScript("OnClick", function() bar:ToggleGroup(entry.group) end)
    return h
end

-- Entrada de una página: fondo y raya que se encienden al elegirla.
local function createEntry(bar, entry, index)
    local b = createRow(bar, childName(bar, "Nav", index))
    b.selection = colorTexture(b, "BACKGROUND", NAV.SELECTED_COLOR)
    b.selection:SetAllPoints()
    b.accent = colorTexture(b, "ARTWORK", NAV.ACCENT_COLOR)
    b.accent:SetWidth(NAV.ACCENT_WIDTH)
    b.accent:SetPoint("TOPLEFT")
    b.accent:SetPoint("BOTTOMLEFT")
    b.label = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.label:SetPoint("LEFT", entry.group and NAV.INDENT or NAV.TEXT_LEFT, 0)
    b.label:SetText(entry.title)
    b:SetScript("OnClick", function() bar:Select(index) end)
    return b
end

local function setSelected(b, on)
    b.selection:SetShown(on)
    b.accent:SetShown(on)
    b.label:SetTextColor(unpack(on and NAV.SELECTED_TEXT_COLOR or NAV.TEXT_COLOR))
end

-- Filas de la barra en orden: el título de cada grupo justo antes de su
-- primera entrada. { frame, group, isHeader }.
local function createRows(bar, entries)
    local rows, group, headers = {}, nil, 0
    for i, entry in ipairs(entries) do
        if entry.group and entry.group ~= group then
            headers = headers + 1
            rows[#rows + 1] = { frame = createHeader(bar, entry, headers), group = entry.group, isHeader = true }
        end
        group = entry.group
        bar.entries[i] = createEntry(bar, entry, i)
        rows[#rows + 1] = { frame = bar.entries[i], group = entry.group }
    end
    return rows
end

--------------------------------------------------------------------------------
-- API del componente
--------------------------------------------------------------------------------

local methods = {}

function methods:Select(index)
    for i, b in ipairs(self.entries) do setSelected(b, i == index) end
    self.selected = index
    self.onSelect(index)
end

function methods:IsCollapsed(group)
    return self.collapsed[group] == true
end

-- Coloca las filas de arriba abajo, saltándose las de los grupos plegados.
function methods:Layout()
    local y = -NAV.FIRST_GAP
    for _, row in ipairs(self.rows) do
        local visible = row.isHeader or not (row.group and self:IsCollapsed(row.group))
        row.frame:SetShown(visible)
        if row.isHeader then
            row.frame.toggle:SetTexture(self:IsCollapsed(row.group) and NAV.COLLAPSED_TEXTURE or NAV.EXPANDED_TEXTURE)
        end
        if visible then
            if row.isHeader then y = y - NAV.HEADER_GAP end
            row.frame:ClearAllPoints()
            row.frame:SetPoint("TOPLEFT", 0, y)
            row.frame:SetPoint("TOPRIGHT", -NAV.DIVIDER_WIDTH, y)
            y = y - NAV.ENTRY_HEIGHT - NAV.ENTRY_GAP
        end
    end
end

-- Pliega o despliega un grupo. La página elegida sigue a la vista aunque su
-- entrada quede oculta. Se guarda nil en vez de false para que solo quede
-- apuntado lo que está plegado.
function methods:ToggleGroup(group)
    self.collapsed[group] = not self:IsCollapsed(group) or nil
    self:Layout()
end

-- Ancho total que ocupa la barra desde el borde de la ventana.
function Sidebar.Width()
    return NAV.LEFT + NAV.WIDTH
end

function Sidebar.Create(parent, entries, onSelect, collapsed)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetWidth(NAV.WIDTH)
    bar:SetPoint("TOPLEFT", NAV.LEFT, NAV.TOP)
    bar:SetPoint("BOTTOMLEFT", NAV.LEFT, NAV.BOTTOM)
    for name, fn in pairs(methods) do bar[name] = fn end
    bar.entries, bar.onSelect, bar.collapsed = {}, onSelect, collapsed or {}
    createBackground(bar)
    bar.rows = createRows(bar, entries)
    bar:Layout()
    return bar
end
