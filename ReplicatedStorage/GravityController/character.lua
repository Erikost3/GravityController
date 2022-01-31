local RunService = game:GetService("RunService")
local Character = _G.GravityController.Object:subclass{}

Character.Characters = {}
Character.FixCharacterStates = true

function Character.GetMass(ob: Instance)
    
    local m = 0
    
    for i, v in pairs(ob:GetDescendants()) do
        if v:IsA("BasePart") then
            m += v:GetMass()
        end
    end

    return m
end

function Character.fixStates(self: table, char: Model)

end

function Character.Physics(self: table, dt)
    
end

function Character.added(self: table, char: Model)

    self.Humanoid = char:WaitForChild("Humanoid")
    self.RootPart = char:WaitForChild("HumanoidRootPart")

    self.BF = self.RootPart:FindFirstChildOfClass("BodyForce") or Instance.new("BodyForce", self.RootPart)
    self.BG = self.RootPart:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro", self.RootPart)

    self.BG.MaxTorque = Vector3.one * Character.GetMass(char)

    if Character.FixCharacterStates then
       Character.fixStates(self, char)
    end

    if self.PhysicsConnection then
        self.PhysicsConnection:Disconnect()
    end

    self.PhysicsConnection = RunService.Stepped:Connect(function(t, dt)
        Character.Physics(self, dt)
    end)
end

function Character.new(player: Player)
    
    local newCharacter = Character {
        Player = player
    }
    
    return newCharacter
end

function Character.init(self: table)
    
    assert(
        typeof(self.Player) == "Instance",
        string.format(
            "GravityController.character.init: Expected Player to be Instance, got '%s'",
            typeof(self.Player)
        )
    )

    self.ChartacterAddedConnection = self.Player.CharacterAppearanceLoaded:Connect(function(char: Model)  Character.added(self, char) end)

    return self
end

Character.PlayerAddedConnection = game.Players.PlayerAdded:Connect(Character.new)

return Character