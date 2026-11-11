--[[
Constantes
==========

Todos los valores fijos del addon en un único sitio. Si algo puede cambiar
(tiempos, umbrales, IDs de hechizos, colores, medidas de la ventana), se
cambia aquí y el resto del código lo recoge.

Sobre "local _, ns = ...":
WoW ejecuta cada archivo del addon pasándole dos valores: el nombre del addon
y una tabla privada que comparten todos sus archivos. Usamos esa tabla (ns,
"namespace") para repartir el código en módulos sin crear variables globales,
que podrían chocar con otros addons.

Los archivos compartidos con StreamDeckWoW (ver tools/sync_shared.py) leen de
aquí ADDON_NAME, ICON, MSG.SETTINGS_CHANGED, CHAT_PREFIX, UI.TOOLTIP_HELP_COLOR
y MINIMAP: los dos addons tienen que definirlos.
]]

local addonName, ns = ...

-- Exponemos el namespace como global solo para poder inspeccionarlo en el
-- juego mientras se desarrolla: /dump FranTools.Const
_G.FranTools = ns

local Const = {}
ns.Const = Const

-- Nombre del addon (el de su carpeta) e icono: una llave inglesa del propio
-- juego, para no tener que dibujar y mantener uno.
Const.ADDON_NAME = addonName
Const.ICON = "Interface\\Icons\\INV_Misc_Wrench_01"

-- Mensajes internos entre módulos (no son eventos de WoW).
Const.MSG = {
    SETTINGS_CHANGED = "SETTINGS_CHANGED",   -- ha cambiado una opción (aviso del taunt...)
}

-- Chat: prefijo de los mensajes (icono + nombre).
-- |T ruta:alto:ancho|t inserta una imagen en el texto del chat.
Const.CHAT_PREFIX = "|T" .. Const.ICON .. ":14:14|t |cff33ff99FranTools|r"

-- Colores de texto (hexadecimal RRGGBB, para Util.Colorize).
Const.COLOR = {
    WARNING = "ff6060",   -- avisos en el chat (taunt de la mascota mal puesto)
    DIM = "888888",       -- texto secundario (versión en el título de la ventana)
}

-- Ventana de opciones (/fran config).
Const.UI = {
    FRAME_NAME = "FranToolsConfig",   -- nombre global (necesario para cerrar con Escape)
    TITLE = "FranTools",
    TITLE_ICON_SIZE = 16,
    TITLE_ICON_GAP = 4,     -- separación entre el icono y el texto del título
    HEIGHT = 250,
    CONTENT_WIDTH = 374,    -- ancho de las páginas, a la derecha de la barra lateral
    PADDING = 20,
    -- Páginas de opciones: filas de arriba abajo.
    PAGE_TOP = -36,                -- primera fila, bajo la barra de título
    ROW_HEIGHT = 26,
    SECTION_GAP = 8,               -- espacio extra sobre un título que no es el primero
    NOTE_MARGIN = 6,               -- espacio sobre y bajo una nota (las de varias líneas
                                   -- ocupan lo que mida su texto)
    CHECK_SIZE = 24,
    CHECK_LABEL_GAP = 2,           -- separación entre la casilla y su texto
    CHECK_COLUMN_WIDTH = 110,      -- ancho de cada casilla en las filas de varias
    CHECKS_PER_ROW = 3,
    CHECK_ICON_SIZE = 16,          -- icono delante del texto de una casilla
    -- Cajas numéricas, en columnas: x de la izquierda de cada columna.
    NUMBER_BOX_WIDTH = 44,
    NUMBER_BOX_HEIGHT = 20,
    NUMBER_MAX_DIGITS = 4,
    NUMBER_COLUMNS = { 190, 290 },
    -- Barra lateral de navegación (UI/Sidebar.lua), a la izquierda de la
    -- ventana, bajo la barra de título. Colores RGBA 0-1: el dorado es el de
    -- los textos de Blizzard, para que la selección no desentone.
    NAV = {
        WIDTH = 112,
        LEFT = 3,                  -- separación del borde izquierdo de la ventana
        TOP = -24,                 -- bajo la barra de título
        BOTTOM = 3,
        FIRST_GAP = 8,             -- espacio sobre la primera entrada
        ENTRY_HEIGHT = 20,
        ENTRY_GAP = 2,
        HEADER_GAP = 10,           -- espacio sobre el título de un grupo
        TEXT_LEFT = 10,            -- sangría del texto de las entradas sueltas
        INDENT = 18,               -- sangría de las entradas de un grupo
        ACCENT_WIDTH = 2,          -- raya a la izquierda de la entrada elegida
        DIVIDER_WIDTH = 1,         -- línea entre la barra y el contenido
        BACKGROUND_COLOR = { 0, 0, 0, 0.35 },
        DIVIDER_COLOR = { 1, 0.82, 0, 0.25 },
        HOVER_COLOR = { 1, 1, 1, 0.08 },
        SELECTED_COLOR = { 1, 0.82, 0, 0.12 },
        ACCENT_COLOR = { 1, 0.82, 0, 1 },
        TEXT_COLOR = { 0.85, 0.85, 0.85 },
        SELECTED_TEXT_COLOR = { 1, 0.82, 0 },
        -- Botón de plegar o desplegar un grupo, a la derecha de su título: los
        -- mismos más y menos de las listas plegables del juego.
        EXPANDED_TEXTURE = "Interface\\Buttons\\UI-MinusButton-Up",
        COLLAPSED_TEXTURE = "Interface\\Buttons\\UI-PlusButton-Up",
        TOGGLE_SIZE = 14,
        TOGGLE_RIGHT = -6,
    },
    -- Color de las líneas de ayuda del tooltip (RGB 0-1).
    TOOLTIP_HELP_COLOR = { 0.8, 0.8, 0.8 },
}

-- Aviso del taunt de la mascota (Features/PetTaunt.lua). En mazmorras y bandas
-- tanquea el tanque: si la mascota provoca, le quita los enemigos. Fuera, en
-- solitario, interesa lo contrario: que la mascota los aguante.
Const.PET_TAUNT = {
    -- Taunts de mascota, cada uno con todos sus rangos (según Wowhead
    -- Forever): Bramido del cazador y Tormento del abisario del brujo. Para
    -- otro, basta con añadir sus IDs.
    TAUNTS = {
        { 2649, 14916, 14917, 14918, 14919, 14920, 14921 },   -- Bramido
        { 3716, 7809, 7810, 7811, 11774, 11775 },             -- Tormento
    },
    -- Tipos de instancia (Api.InstanceType) donde debe estar desactivado.
    OFF_IN = { party = true, raid = true },
    -- Espera tras cambiar de zona o de mascota antes de comprobar: al salir de
    -- una pantalla de carga la barra de la mascota tarda un momento en estar lista.
    CHECK_DELAY = 1,
    -- Repetir el aviso al entrar en combate si sigue mal (el primero se puede
    -- perder durante la pantalla de carga o con el chat lleno).
    REMIND_ON_COMBAT = true,
}

-- Aviso de munición baja (Features/Ammo.lua). Usa los números de clase y
-- subclase de objeto del juego, que no dependen del idioma.
Const.AMMO = {
    CLASSES = { HUNTER = true },   -- solo para quien depende de la munición
    -- Tipos de munición, por su subclase de objeto: 2 flechas, 3 balas. Cada
    -- uno con sus umbrales por defecto, que el jugador cambia en la ventana:
    -- por debajo de "low", recuadro ámbar; por debajo de "critical", rojo.
    -- "key" es el nombre con el que se guardan sus umbrales.
    TYPES = {
        [2] = { key = "arrow", label = "Arco/ballesta", low = 200, critical = 50,
                icon = "Interface\\Icons\\INV_Ammo_Arrow_02" },
        [3] = { key = "bullet", label = "Arma de fuego", low = 200, critical = 50,
                icon = "Interface\\Icons\\INV_Ammo_Bullet_02" },
    },
    TYPE_ORDER = { 2, 3 },         -- orden en la ventana
    RANGED_SLOT = 18,              -- ranura del arma a distancia
    AMMO_SLOT = 0,                 -- ranura de la munición (en clientes que la tienen)
    WEAPON_CLASS = 2,              -- clase de objeto "arma"
    PROJECTILE_CLASS = 6,          -- clase de objeto "proyectil"
    -- Subclase del arma -> subclase de la munición que dispara: arco (2) y
    -- ballesta (18) usan flechas (2); armas de fuego (3), balas (3). Las
    -- arrojadizas y las varitas no gastan munición y no aparecen.
    WEAPON_AMMO = { [2] = 2, [18] = 2, [3] = 3 },
    CHECK_DELAY = 0.5,             -- agrupa las ráfagas de BAG_UPDATE al disparar o lootear
}

-- Los mismos tipos por su nombre ("arrow", "bullet"), que es como se guardan
-- sus umbrales.
Const.AMMO.TYPE_BY_KEY = {}
for _, info in pairs(Const.AMMO.TYPES) do Const.AMMO.TYPE_BY_KEY[info.key] = info end

-- Aviso de aspecto (Features/Aspect.lua). IDs según Wowhead Forever; todos
-- los rangos de un aspecto se llaman igual, así que con el nombre del primero
-- se reconocen los demás. "label" es el nombre corto de la ventana y
-- "default" si cuenta como aspecto válido mientras el jugador no lo cambie:
-- los de combate sí; los de viaje y de grupo no, para que avise si entras en
-- combate con ellos (el guepardo y la manada te dejan aturdido al recibir golpes).
Const.ASPECT = {
    CLASSES = { HUNTER = true },
    LIST = {   -- en el orden de la ventana
        { key = "hawk", label = "Halcón", default = true,
          spells = { 13165, 14318, 14319, 14320, 14321, 14322, 25296 } },
        { key = "monkey", label = "Mono", default = true, spells = { 13163 } },
        { key = "wild", label = "Salvaje", default = false, spells = { 20043, 20190 } },
        { key = "cheetah", label = "Guepardo", default = false, spells = { 5118 } },
        { key = "pack", label = "Manada", default = false, spells = { 13159 } },
        { key = "beast", label = "Bestia", default = false, spells = { 13161 } },
    },
}

-- En combate UNIT_AURA llega sin parar (cualquier beneficio o perjuicio): los
-- avisos de beneficios (Features/BuffWarning.lua) lo agrupan para no repasar
-- las auras con cada uno.
Const.BUFF_CHECK_DELAY = 0.2

-- Avisos por cantidad de objetos (Features/CountWarning.lua): las ráfagas de
-- BAG_UPDATE al lootear o gastar se agrupan.
Const.COUNT_CHECK_DELAY = 0.5

-- Guerrero (Features/Warrior.lua). IDs según Wowhead Forever; en español el
-- Grito de batalla se llama "Grito de guerra".
Const.WARRIOR = {
    BATTLE_SHOUT = { 6673, 5242, 6192, 11549, 11550, 11551, 25289 },
}

-- Brujo (Features/Warlock.lua). IDs según Wowhead Forever.
Const.WARLOCK = {
    SOUL_SHARD = 6265,
    SHARDS_LOW = 5,          -- por defecto: ámbar con menos de 5, rojo con menos de 2
    SHARDS_CRITICAL = 2,
    -- Piedras de salud de todos los tamaños, con y sin el talento que las mejora.
    HEALTHSTONES = { 5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009,
                     5510, 19010, 19011, 9421, 19012, 19013 },
    CREATE_HEALTHSTONE = { 6201, 6202, 5699, 11729, 11730 },
    DEMON_SKIN = { 687, 696 },
    DEMON_ARMOR = { 706, 1086, 11733, 11734, 11735 },
}

-- Paladín (Features/Paladin.lua y Features/RighteousFury.lua). IDs según
-- Wowhead Forever. Las auras, como los aspectos: "default" es si vale
-- mientras el jugador no lo cambie (todas). De las bendiciones vale
-- cualquiera, la tuya o la de otro paladín, normal o superior.
Const.PALADIN = {
    AURAS = {
        { key = "devotion", label = "Devoción", default = true,
          spells = { 465, 10290, 643, 10291, 1032, 10292, 10293 } },
        { key = "retribution", label = "Castigo", default = true,
          spells = { 7294, 10298, 10299, 10300, 10301 } },
        { key = "concentration", label = "Concentración", default = true, spells = { 19746 } },
        { key = "shadow", label = "Sombras", default = true, spells = { 19876, 19895, 19896 } },
        { key = "frost", label = "Escarcha", default = true, spells = { 19888, 19897, 19898 } },
        { key = "fire", label = "Fuego", default = true, spells = { 19891, 19899, 19900 } },
        { key = "sanctity", label = "Santidad", default = true, spells = { 20218 } },
    },
    -- Salvación, Luz y Santuario no salen en Wowhead Forever; si el juego no
    -- las tiene, sus IDs no estorban.
    BLESSINGS = {
        { key = "might", label = "Poderío",
          spells = { 19740, 19834, 19835, 19836, 19837, 19838, 25291, 25782, 25916 } },
        { key = "wisdom", label = "Sabiduría",
          spells = { 19742, 19850, 19852, 19853, 19854, 25290, 25894, 25918 } },
        { key = "kings", label = "Reyes", spells = { 20217, 25898 } },
        { key = "salvation", label = "Salvación", spells = { 1038, 25895 } },
        { key = "light", label = "Luz", spells = { 19977, 19978, 19979, 25890 } },
        { key = "sanctuary", label = "Santuario", spells = { 20911, 20912, 20913, 20914, 25899 } },
    },
    -- Furia justa (Righteous Fury): más amenaza con el daño sagrado. La lleva
    -- el tanque; el resto se la quita para no robarle los enemigos.
    RIGHTEOUS_FURY = 25780,
    TANK_ROLE = "TANK",      -- rol del buscador de grupo (UnitGroupRolesAssigned)
    CHECK_DELAY = 0.5,
}

-- Vendedor (Features/Merchant.lua): reparar y vender la basura al hablar con
-- uno. La basura es la calidad pobre (los objetos grises). Se vende en tandas,
-- con una pausa entre ellas: el servidor descarta ventas si llegan demasiadas
-- de golpe, y así cada tanda ya ve las anteriores hechas.
Const.MERCHANT = {
    JUNK_QUALITY = 0,
    SELL_BATCH = 10,
    SELL_INTERVAL = 0.2,
}

-- Agro en las barras de nombre de los enemigos (Features/Threat.lua y
-- UI/ThreatBadge.lua): un marco de color alrededor de la barra de vida y tu
-- porcentaje de amenaza al lado. Colores RGB 0-1 por situación:
--   player   va a por ti
--   warning  aún no, pero estás a punto de quitárselo a quien lo tiene
--   pet      lo tiene tu mascota
--   other    lo tiene otro (el tanque del grupo)
Const.THREAT = {
    WARN_PERCENT = 80,
    COLOR = {
        player = { 1, 0.25, 0.25 },
        warning = { 1, 0.75, 0 },
        pet = { 0.3, 0.9, 0.3 },
        other = { 0.6, 0.6, 0.6 },
    },
    BORDER = 2,        -- grosor del marco
    TEXT_GAP = 3,      -- separación del porcentaje a la derecha de la barra
    -- En combate la amenaza cambia sin parar y llega un evento por cada
    -- cambio: se agrupan y se repasan todas las barras a la vez.
    UPDATE_DELAY = 0.1,
}

-- Recuadro de aviso discreto (UI/NoticeBox.lua): un marco pequeño con icono y
-- texto, que el jugador puede mover. Colores del borde (RGB 0-1) por nivel.
Const.NOTICE = {
    WIDTH = 190,
    HEIGHT = 36,
    ICON_SIZE = 24,
    PADDING = 6,
    DEFAULT_POINT = { "CENTER", 0, -160 },   -- algo por debajo del centro de la pantalla
    -- Los recuadros que el jugador no ha movido se apilan desde DEFAULT_POINT
    -- hacia abajo, con esta separación, para no taparse unos a otros.
    STACK_GAP = 4,
    BACKGROUND = "Interface\\Tooltips\\UI-Tooltip-Background",
    BORDER = "Interface\\Tooltips\\UI-Tooltip-Border",
    BORDER_SIZE = 12,
    INSET = 3,
    BACKGROUND_COLOR = { 0, 0, 0, 0.7 },
    LEVEL_COLOR = {
        warning = { 1, 0.75, 0 },
        critical = { 1, 0.25, 0.25 },
    },
}

-- Botón del minimapa. Las medidas y texturas son las del aro estándar que usan
-- los botones de minimapa de casi todos los addons, para que no desentone.
-- Las posiciones son píxeles desde la esquina superior izquierda del botón.
Const.MINIMAP = {
    BUTTON_NAME = "FranToolsMinimapButton",   -- nombre global (otros addons de minimapa lo reconocen)
    DEFAULT_ANGLE = 225,     -- grados desde la derecha, en sentido antihorario: abajo a la izquierda
    EDGE_OFFSET = 5,         -- cuánto sobresale el botón del borde del minimapa
    FRAME_LEVEL = 8,         -- por encima de los iconos del propio minimapa
    SIZE = 31,
    BORDER_SIZE = 53,
    BORDER_TEXTURE = "Interface\\Minimap\\MiniMap-TrackingBorder",
    BACKGROUND_SIZE = 20,
    BACKGROUND_OFFSET = { 7, -5 },
    BACKGROUND_TEXTURE = "Interface\\Minimap\\UI-Minimap-Background",
    ICON_SIZE = 17,
    ICON_OFFSET = { 7, -6 },
    -- Máscara circular para que el icono (cuadrado) encaje en el aro.
    ICON_MASK = "Interface\\CharacterFrame\\TempPortraitAlphaMask",
    HIGHLIGHT_TEXTURE = "Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight",
}
