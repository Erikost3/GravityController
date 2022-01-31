local Object = require(script.object)
local GravityController = Object:subclass{}-- Globals

_G.GravityController = GravityController

-- Properties
_G.GravityController.ForceOfGravity = 196.2

-- References
_G.GravityController.Object = Object

_G.GravityController.DebugPart = require(script.debugPart)
_G.GravityController.Character = require(script.character)

return GravityController