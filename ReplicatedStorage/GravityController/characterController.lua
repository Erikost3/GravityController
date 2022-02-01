local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CharacterController = _G.GravityController.Object:subclass{}

CharacterController.Characters = {}
CharacterController.Gravity = _G.GravityController.Gravity {}

function CharacterController.init(self: table)

    assert(
        typeof(self.Character) == "Instance",
        string.format(
            "GravityController.Character.init: Expected self.Character to be Instance, got '%s'",
            typeof(self.Player)
        )
    )

    self.IgnoreInstances = {}

    self.RaycastDistance = 1000

    self.Debug = self.Debug or true

    self.RaycastParams = RaycastParams.new()
    self.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    self.RaycastParams.FilterDescendantsInstances = self.IgnoreInstances


    table.insert(CharacterController.Characters, self)

    CharacterController.Gravity:AddPhysicsObject(self.Character)

    return self
end

function CharacterController.playerAdded(player: Player)
    player.CharacterAppearanceLoaded:Connect(function(char: Model)
        CharacterController {Character = char}
         
    end)
end

CharacterController.PlayerAddedConnection = Players.PlayerAdded:Connect(CharacterController.playerAdded)

return CharacterController