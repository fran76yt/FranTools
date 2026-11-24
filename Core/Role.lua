--[[
Quién tanquea
=============

Varias ayudas cambian si eres el tanque: la Furia justa del paladín, los
colores del agro en las barras de nombre... Aquí se decide una vez:

  * el rol del grupo, si el juego lo sabe (el del buscador de grupo);
  * si no, la casilla "Tanqueo yo" de /fran config, que es la misma en las
    páginas de todas las clases que tanquean.

  ns.Role.IsTank()
  ns.Role.IsManualTank() / SetManualTank(on)

Al cambiar la casilla se avisa con SETTINGS_CHANGED, y quien dependa de ella
se pone al día como con cualquier otra opción.
]]

local _, ns = ...
local Const, Util, Api, Storage = ns.Const, ns.Util, ns.Api, ns.Storage

local Role = {}
ns.Role = Role

-- La casilla estuvo antes en las preferencias de la Furia justa: si sigue
-- ahí, se trae la primera vez (las SavedVariables aún no existen al cargar
-- el archivo, por eso no se hace antes).
local function settings()
    local role = Storage.Get("role")
    local fury = Storage.Get("righteousFury")
    if fury.tank then
        role.tank = true
        fury.tank = nil
    end
    return role
end

function Role.IsManualTank()
    return settings().tank == true
end

function Role.SetManualTank(on)
    settings().tank = on or nil
    Util.Fire(Const.MSG.SETTINGS_CHANGED)
end

-- El rol del grupo manda; sin rol, la casilla.
function Role.IsTank()
    local role = Api.GroupRole()
    if role then return role == Const.TANK_ROLE end
    return Role.IsManualTank()
end
