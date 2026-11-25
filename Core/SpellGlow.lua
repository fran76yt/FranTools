--[[
Hechizos iluminados
===================

El juego ilumina en las barras de acción los hechizos que se pueden usar por
algo que acaba de pasar (los "procs"), y avisa con dos eventos que no se
ocultan a los addons (documentación de C_SpellActivationOverlay en Forever):

  SPELL_ACTIVATION_OVERLAY_GLOW_SHOW (spellID)   se enciende
  SPELL_ACTIVATION_OVERLAY_GLOW_HIDE (spellID)   se apaga

Aquí se lleva la cuenta de cuáles están encendidos, para los avisos de "ya
puedes usarlo" (Features/ReadyWarning.lua), y se avisa con Const.MSG_SPELL_GLOW
al cambiar. También se apunta qué hechizos ha iluminado alguna vez: si el
juego ilumina uno, su luz es la señal buena para ese hechizo.

  ns.SpellGlow.IsGlowing(id)
  ns.SpellGlow.HasGlowed(id)   -- lo ha iluminado alguna vez en esta sesión
]]

local _, ns = ...
local Const, Util, Api = ns.Const, ns.Util, ns.Api

local SpellGlow = {}
ns.SpellGlow = SpellGlow

local glowing, glowed = {}, {}

function SpellGlow.IsGlowing(id)
    return glowing[id] == true
end

function SpellGlow.HasGlowed(id)
    return glowed[id] == true
end

-- El ID llega sin ocultar según la documentación; si algún día llegara
-- oculto, no se puede usar de índice y se ignora.
local function onGlow(spellID, on)
    if spellID == nil or Api.IsSecret(spellID) then return end
    glowing[spellID] = on or nil
    if on then glowed[spellID] = true end
    Util.Fire(Const.MSG_SPELL_GLOW, spellID, on)
end

Util.OnIfExists("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW", function(spellID) onGlow(spellID, true) end)
Util.OnIfExists("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE", function(spellID) onGlow(spellID, false) end)
