--[[
Página de opciones
==================

Construye una página de opciones a partir de una lista de filas descritas
como datos, de arriba abajo. Así una sección de clase (UI/ClassPages) solo
dice qué opciones tiene, no cómo se dibujan.

Tipos de fila:
  { kind = "check", label, icon, tooltip, get, set }
        casilla (UI/Checkbox.lua)
  { kind = "checks", items = { { label, icon, tooltip, get, set }, ... } }
        varias casillas en la misma fila, en columnas
  { kind = "header", label }
        título de un grupo de filas
  { kind = "columns", label, columns = { "Título 1", "Título 2" } }
        texto a la izquierda y títulos centrados sobre las columnas de cajas
  { kind = "numbers", label, tooltip, fields = { { get, set, tooltip }, ... } }
        texto a la izquierda y una caja numérica (UI/NumberBox.lua) por columna
  { kind = "note", text }
        texto de ayuda en gris, a lo ancho; ocupa las líneas que necesite y
        lo que va debajo baja con él

Las filas van una debajo de otra. Cada una ocupa ROW_HEIGHT salvo las notas,
que miden lo que su texto, y los títulos llevan un poco de aire encima.

  local update = ns.OptionsPage.Build(page, rows)
  update()   -- vuelve a leer todos los valores
]]

local _, ns = ...
local UI = ns.Const.UI

local OptionsPage = {}
ns.OptionsPage = OptionsPage

--------------------------------------------------------------------------------
-- Piezas comunes
--------------------------------------------------------------------------------

-- Texto a la izquierda de la fila, centrado en su alto.
local function leftLabel(page, y, text, font)
    local label = page:CreateFontString(nil, "OVERLAY", font or "GameFontHighlightSmall")
    label:SetPoint("LEFT", page, "TOPLEFT", UI.PADDING, y - UI.ROW_HEIGHT / 2)
    label:SetText(text)
    return label
end

-- Centro horizontal de la columna i de cajas numéricas.
local function columnCenter(i)
    return UI.NUMBER_COLUMNS[i] + UI.NUMBER_BOX_WIDTH / 2
end

--------------------------------------------------------------------------------
-- Constructores por tipo de fila
--------------------------------------------------------------------------------
-- Cada uno dibuja la fila con su parte de arriba en y y devuelve los controles
-- que hay que actualizar (los que tienen :Update()), o nada, y el alto que
-- ocupa si no es ROW_HEIGHT.

-- Espacio extra encima de algunos tipos de fila (cuando no son la primera).
local GAP_BEFORE = { header = UI.SECTION_GAP }

local builders = {}

function builders.checks(page, row, y)
    local controls = {}
    for i, item in ipairs(row.items) do
        local cb = ns.Checkbox.Create(page, item)
        cb:SetPoint("LEFT", page, "TOPLEFT", UI.PADDING + (i - 1) * UI.CHECK_COLUMN_WIDTH, y - UI.ROW_HEIGHT / 2)
        controls[i] = cb
    end
    return controls
end

function builders.check(page, row, y)
    return builders.checks(page, { items = { row } }, y)
end

function builders.header(page, row, y)
    leftLabel(page, y, row.label, "GameFontNormalSmall")
end

function builders.columns(page, row, y)
    builders.header(page, row, y)
    for i, title in ipairs(row.columns) do
        local text = page:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("CENTER", page, "TOPLEFT", columnCenter(i), y - UI.ROW_HEIGHT / 2)
        text:SetText(title)
    end
end

-- Los textos (FontString) no reciben el ratón y no pueden tener tooltip: el de
-- la fila va en cada caja que no traiga uno propio.
function builders.numbers(page, row, y)
    leftLabel(page, y, row.label)
    local controls = {}
    for i, field in ipairs(row.fields) do
        -- Copia para no tocar la descripción de la fila, que es de la sección.
        local opts = { get = field.get, set = field.set, tooltip = field.tooltip or row.tooltip }
        local box = ns.NumberBox.Create(page, opts)
        box:SetPoint("LEFT", page, "TOPLEFT", UI.NUMBER_COLUMNS[i], y - UI.ROW_HEIGHT / 2)
        controls[#controls + 1] = box
    end
    return controls
end

-- El ancho se fija con SetWidth y no con anclas a los dos lados: así el juego
-- sabe ya dónde parte las líneas y GetStringHeight da el alto del texto
-- aunque la ventana aún no se haya mostrado.
function builders.note(page, row, y)
    local note = page:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    note:SetPoint("TOPLEFT", page, "TOPLEFT", UI.PADDING, y - UI.NOTE_MARGIN)
    note:SetWidth(UI.CONTENT_WIDTH - 2 * UI.PADDING)
    note:SetJustifyH("LEFT")
    note:SetText(row.text)
    local textHeight = note:GetStringHeight() or 0
    return nil, math.max(UI.ROW_HEIGHT, textHeight + 2 * UI.NOTE_MARGIN)
end

--------------------------------------------------------------------------------
-- API del componente
--------------------------------------------------------------------------------

function OptionsPage.Build(page, rows)
    local controls, y = {}, UI.PAGE_TOP
    for i, row in ipairs(rows) do
        if i > 1 then y = y - (GAP_BEFORE[row.kind] or 0) end
        local made, height = builders[row.kind](page, row, y)
        for _, c in ipairs(made or {}) do controls[#controls + 1] = c end
        y = y - (height or UI.ROW_HEIGHT)
    end
    return function()
        for _, c in ipairs(controls) do c:Update() end
    end
end
