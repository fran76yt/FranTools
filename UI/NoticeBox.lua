--[[
Recuadro de aviso
=================

Componente reutilizable para avisos discretos: un marco pequeño con un icono y
una línea de texto, con el borde del color del nivel del aviso ("warning"
ámbar, "critical" rojo). No hace ruido ni ocupa el centro de la pantalla: está
ahí mientras dure el problema y desaparece solo.

El jugador lo puede arrastrar a donde le moleste menos; la posición se guarda
en la tabla de preferencias que pasa quien lo crea. Los que no ha movido se
apilan por debajo del centro de la pantalla, en el orden en que se crearon y
solo los que están a la vista, para que varios avisos a la vez no se tapen.

  local box = ns.NoticeBox.Create({
      name = "NombreGlobal",                 -- opcional
      settings = function() return tabla end, -- donde guardar la posición (campo point)
      tooltip = { "Título", "Ayuda", ... },
  })
  box:ShowNotice(icono, "texto", "warning", { badge = "7", dim = true })
  box:ShowIf(icono, textoONil, nivel, extra)   -- muestra si hay texto; si no, oculta
  box:Hide()

extra es opcional: badge, una cifra encima del icono (los segundos que le
quedan a un enfriamiento); dim, el icono apagado (aún no se puede usar).

Para todos los recuadros a la vez, el jugador elige (/fran config, General):
  NoticeBox.IsIconOnly() / SetIconOnly(on) / ToggleIconOnly()
      solo el icono, en un cuadrado, sin texto (el tooltip lo explica)
  NoticeBox.IconSize() / SetIconSize(n)
      tamaño del icono, en los dos modos

Crearlo no toca la interfaz, así que se puede hacer al cargar el archivo.

El marco se crea al mostrar el primer aviso: si nunca hay nada que avisar, no
consume nada.
]]

local _, ns = ...
local Const, Util, Storage = ns.Const, ns.Util, ns.Storage
local N = Const.NOTICE

local NoticeBox = {}
ns.NoticeBox = NoticeBox

local boxes = {}   -- todos los recuadros, en el orden en que se crearon

--------------------------------------------------------------------------------
-- Preferencias de todos los recuadros
--------------------------------------------------------------------------------

local function prefs()
    return Storage.Get("notices")
end

function NoticeBox.IsIconOnly()
    return prefs().iconOnly == true
end

-- El que ha elegido el jugador o, si no, el de entrada del modo: sin texto
-- al lado, el icono es lo único que se ve y va más grande.
local function defaultIconSize()
    return NoticeBox.IsIconOnly() and N.ICON_ONLY_SIZE or N.ICON_SIZE
end

function NoticeBox.IconSize()
    return prefs().iconSize or defaultIconSize()
end

--------------------------------------------------------------------------------
-- Posición
--------------------------------------------------------------------------------

-- Posición de un recuadro movido por el jugador. Los demás los coloca restack.
local function restorePoint(f, settings)
    local p = settings.point
    if not p then return end
    f:ClearAllPoints()
    f:SetPoint(p[1], UIParent, p[2], p[3], p[4])
end

-- Coloca uno debajo de otro, desde DEFAULT_POINT, los recuadros visibles que
-- el jugador no ha movido. Se llama cada vez que uno aparece, desaparece o se
-- suelta tras moverlo, para que no queden huecos.
local function restack()
    local slot = 0
    for _, box in ipairs(boxes) do
        local f = box.frame
        if f and f:IsShown() and not box.opts.settings().point then
            f:ClearAllPoints()
            f:SetPoint(N.DEFAULT_POINT[1], UIParent, N.DEFAULT_POINT[1], N.DEFAULT_POINT[2], N.DEFAULT_POINT[3] - slot)
            slot = slot + f:GetHeight() + N.STACK_GAP
        end
    end
end

-- StopMovingOrSizing deja el marco anclado donde se soltó; se guarda ese
-- anclaje (sin el marco relativo, que siempre es UIParent).
local function savePoint(f, settings)
    local point, _, relPoint, x, y = f:GetPoint()
    settings.point = { point, relPoint, x, y }
end

--------------------------------------------------------------------------------
-- Construcción
--------------------------------------------------------------------------------

-- En el cliente moderno los fondos con borde (SetBackdrop) solo existen si el
-- marco hereda de BackdropTemplate; en los antiguos venían de serie.
local BACKDROP_TEMPLATE = BackdropTemplateMixin and "BackdropTemplate" or nil

local function applyBackdrop(f)
    if not f.SetBackdrop then return end
    f:SetBackdrop({
        bgFile = N.BACKGROUND,
        edgeFile = N.BORDER,
        edgeSize = N.BORDER_SIZE,
        insets = { left = N.INSET, right = N.INSET, top = N.INSET, bottom = N.INSET },
    })
    f:SetBackdropColor(unpack(N.BACKGROUND_COLOR))
end

local function makeMovable(f, opts)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        savePoint(self, opts.settings())
        restack()
    end)
end

local function createContent(f)
    f.icon = f:CreateTexture(nil, "ARTWORK")
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.text:SetJustifyH("LEFT")
    f.badge = f:CreateFontString(nil, "OVERLAY", N.BADGE_FONT)
    f.badge:SetPoint("CENTER", f.icon, "CENTER", 0, 0)
end

-- Medidas según el modo: con texto, el ancho fijo y el icono a la
-- izquierda; solo icono, un cuadrado justo alrededor de él.
local function applyLayout(f)
    local size = NoticeBox.IconSize()
    local square = size + 2 * N.PADDING
    f.icon:SetSize(size, size)
    f.icon:ClearAllPoints()
    f.text:ClearAllPoints()
    if NoticeBox.IsIconOnly() then
        f:SetSize(square, square)
        f.icon:SetPoint("CENTER", 0, 0)
        f.text:Hide()
    else
        f:SetSize(N.WIDTH, math.max(N.HEIGHT, square))
        f.icon:SetPoint("LEFT", N.PADDING, 0)
        f.text:SetPoint("LEFT", f.icon, "RIGHT", N.PADDING, 0)
        f.text:SetPoint("RIGHT", -N.PADDING, 0)
        f.text:Show()
    end
end

local function build(box)
    local opts = box.opts
    local f = CreateFrame("Frame", opts.name, UIParent, BACKDROP_TEMPLATE)
    f:SetFrameStrata("MEDIUM")
    f.opts = opts
    applyBackdrop(f)
    createContent(f)
    applyLayout(f)
    makeMovable(f, opts)
    ns.Tooltip.Attach(f, opts.tooltip, "ANCHOR_TOP")
    restorePoint(f, opts.settings())
    f:Hide()
    return f
end

--------------------------------------------------------------------------------
-- API del componente
--------------------------------------------------------------------------------

local methods = {}

function methods:ShowNotice(icon, text, level, extra)
    extra = extra or {}
    self.frame = self.frame or build(self)
    local f = self.frame
    f.icon:SetTexture(icon)
    f.icon:SetDesaturated(extra.dim == true)
    f.icon:SetAlpha(extra.dim and N.DIM_ALPHA or 1)
    f.badge:SetText(extra.badge or "")
    f.text:SetText(text)
    local color = N.LEVEL_COLOR[level] or N.LEVEL_COLOR.warning
    if f.SetBackdropBorderColor then f:SetBackdropBorderColor(unpack(color)) end
    f.text:SetTextColor(unpack(color))
    f:Show()
    restack()
end

-- Muestra el aviso si hay texto y, si no, lo oculta: así quien lo usa no
-- repite el "si hay aviso, mostrar; si no, ocultar".
function methods:ShowIf(icon, text, level, extra)
    if text then
        self:ShowNotice(icon, text, level, extra)
    else
        self:Hide()
    end
end

function methods:Hide()
    if self.frame and self.frame:IsShown() then
        self.frame:Hide()
        restack()
    end
end

function methods:IsShown()
    return self.frame ~= nil and self.frame:IsShown()
end

function NoticeBox.Create(opts)
    local box = { opts = opts }
    for name, fn in pairs(methods) do box[name] = fn end
    boxes[#boxes + 1] = box
    return box
end

--------------------------------------------------------------------------------
-- Cambiar el modo o el tamaño
--------------------------------------------------------------------------------

-- Los recuadros ya hechos se rehacen a la medida nueva y se vuelven a apilar.
local function relayoutAll()
    for _, box in ipairs(boxes) do
        if box.frame then applyLayout(box.frame) end
    end
    restack()
    Util.Fire(Util.SETTINGS_CHANGED)
end

function NoticeBox.SetIconOnly(on)
    prefs().iconOnly = on or nil
    relayoutAll()
end

-- Devuelve true si queda en modo solo icono.
function NoticeBox.ToggleIconOnly()
    NoticeBox.SetIconOnly(not NoticeBox.IsIconOnly())
    return NoticeBox.IsIconOnly()
end

-- Se ajusta a lo que cabe (ICON_SIZE_MIN..MAX); el de siempre no se guarda.
function NoticeBox.SetIconSize(size)
    size = math.max(N.ICON_SIZE_MIN, math.min(N.ICON_SIZE_MAX, math.floor(size)))
    Util.SetOverride(prefs(), "iconSize", size, defaultIconSize())
    relayoutAll()
end
