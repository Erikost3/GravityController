local Object = require(script.object)

local GravityController = Object:subclass{}
_G.GravityController = GravityController

-- References
GravityController.Object = Object

GravityController.DebugPart = require(script.debugPart); _G.GravityController.DebugPart = GravityController.DebugPart
GravityController.Gravity = require(script.gravity); _G.GravityController.Gravity = GravityController.Gravity
GravityController.CharacterController = require(script.characterController); _G.GravityController.CharacterController = GravityController.CharacterController
GravityController.Test = require(script.test); _G.GravityController.Test = GravityController.Test

return GravityController