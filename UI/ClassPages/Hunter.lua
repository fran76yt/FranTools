--[[
Sección del cazador
===================

Opciones propias del cazador en /fran config, en tres páginas:
  Mascota    aviso del taunt de la mascota
  Munición   aviso de munición baja y sus umbrales por tipo de arma
  Aspectos   aviso de aspecto y qué aspectos valen
Solo describe las filas (ver UI/OptionsPage.lua y UI/OptionRows.lua); el
estado lo guardan los módulos de Features/.
]]

local _, ns = ...
local AMMO = ns.Const.AMMO
local Rows = ns.OptionRows

--------------------------------------------------------------------------------
-- Mascota
--------------------------------------------------------------------------------

local petPage = {
    title = "Mascota",
    rows = {
        Rows.PetTaunt(),
        { kind = "note", text = "En mazmorra y banda el Bramido automático debe ir desactivado; fuera, activado, para que la mascota aguante a los enemigos. El aviso sale en el centro de la pantalla, con sonido." },
    },
}

--------------------------------------------------------------------------------
-- Munición
--------------------------------------------------------------------------------

-- Fila de umbrales de un tipo de munición: dos cajas, aviso y crítico.
local function ammoRow(ammoType)
    local info = AMMO.TYPES[ammoType]
    local function field(which)
        return {
            get = function() return ns.Ammo.GetThreshold(ammoType, which) end,
            set = function(value) ns.Ammo.SetThreshold(ammoType, which, value) end,
        }
    end
    return {
        kind = "numbers",
        label = info.label,
        tooltip = {
            info.label,
            "Ámbar: avisa con menos de esta cantidad.",
            "Rojo: casi sin munición (no puede ser mayor que el ámbar).",
            ("Por defecto %d y %d. Intro para aplicar; 0 en ámbar apaga el aviso de este tipo."):format(info.low, info.critical),
        },
        fields = { field("low"), field("critical") },
    }
end

local ammoRows = {
    Rows.Switch(ns.Ammo, "Avisar de munición baja", {
        "Aviso de munición baja",
        "Un recuadro discreto cuando quedan pocas flechas o balas,",
        "según los umbrales de abajo. Se puede mover arrastrándolo.",
        "También con /fran municion.",
    }),
    { kind = "columns", label = "Avisar con menos de", columns = { "Ámbar", "Rojo" } },
}
for _, ammoType in ipairs(AMMO.TYPE_ORDER) do
    ammoRows[#ammoRows + 1] = ammoRow(ammoType)
end
ammoRows[#ammoRows + 1] = { kind = "note", text = "Pulsa Intro o haz clic fuera para aplicar. 0 en ámbar apaga el aviso de ese tipo." }

--------------------------------------------------------------------------------
-- Aspectos
--------------------------------------------------------------------------------

local aspectRows = Rows.Concat(
    {
        Rows.Switch(ns.Aspect, "Avisar si no llevo un aspecto de los marcados", {
            "Aviso de aspecto",
            "Un recuadro discreto si no llevas aspecto (ámbar) o si llevas",
            "uno sin marcar, como el guepardo en combate (rojo).",
            "También con /fran aspecto.",
        }),
        Rows.CombatOnly(ns.Aspect),
    },
    Rows.Choices(ns.Aspect, "Aspectos que valen"),
    { { kind = "note", text = "Ámbar: no llevas aspecto. Rojo: llevas uno sin marcar. El recuadro se puede mover arrastrándolo." } }
)

--------------------------------------------------------------------------------
-- Registro
--------------------------------------------------------------------------------

ns.ClassPages.Register("HUNTER", {
    title = "Cazador",
    pages = {
        petPage,
        { title = "Munición", rows = ammoRows },
        { title = "Aspectos", rows = aspectRows },
    },
})
