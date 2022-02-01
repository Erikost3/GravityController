local Object = require(script.object)
local GravityController = Object:subclass{}-- Globals

_G.GravityController = GravityController

-- References
_G.GravityController.Object = Object

_G.GravityController.DebugPart = require(script.debugPart)
_G.GravityController.Character = require(script.character)
_G.GravityController.Gravity = require(script.gravity)

return GravityController