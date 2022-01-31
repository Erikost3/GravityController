local RunService = game:GetService("RunService")
local Character = _G.GravityController.Object:subclass{}

Character.Characters = {}
Character.FixCharacterStates = true

function Character.getMass(ob: Instance)
    
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

function Character.calculateForce(force: table)
    


end

function Character.physics(self: table, dt)
    for i,v in pairs(self.Forces) do
        if v.Force ~= nil and v.inheritPart and v.Part then
            v.Force.Force = Character.calculateForce(v)
        end
    end
end

function Character.addPhysics(self: table, part: BasePart, inheritPart: BasePart)
    
    assert(
        typeof(part) == "Instance",
        string.format(
            "GravityController.Character.addPhysics: Expected self.part to be Instance, got '%s'",
            typeof(part)
        )
    )

    inheritPart = inheritPart ~= nil and inheritPart:IsA("BasePart") and inheritPart or part

    local BF = {}
    BF.Force = part:FindFirstChildOfClass("BodyForce") or Instance.new("BodyForce", part)
    BF.Force.Force = Vector3.zero

    BF.Part = part
    BF.InheritPart = inheritPart

    -- when part is destroyed, remove physics
    part.Destroying:Connect(function()
        local fIndex = table.find(self.Forces, BF)
        if fIndex then
            table.remove(self.Forces, fIndex)
            BF.Force:Destroy()
        end
    end)

    -- if the inheritPart is destroyed, inherit from part
    inheritPart.Destroying:Connect(function()
        if BF.InheritPart ~= BF.Part then
            BF.InheritPart = BF.Part
        end
    end)

    table.insert(self.Forces, BF)

    return BF
end

function Character.added(self: table, char: Model)

    self.Humanoid = char:WaitForChild("Humanoid")
    self.RootPart = char:WaitForChild("HumanoidRootPart")

    for i,v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") then
            
            if v.Name == "HumanoidRootPart" then
                self.BG = self.RootPart:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro", v)
                self.BG.MaxTorque = Vector3.one * Character.getMass(char) * math.pi * 100
            end

            Character.addPhysics(self, v, self.RootPart)
        end
    end

    if Character.FixCharacterStates then
       Character.fixStates(self, char)
    end

    if self.PhysicsConnection then
        self.PhysicsConnection:Disconnect()
    end

    self.PhysicsConnection = RunService.Stepped:Connect(function(t, dt)
        Character.physics(self, dt)
    end)

    table.insert(self.IgnoreInstances, char)
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
            "GravityController.Character.init: Expected self.Player to be Instance, got '%s'",
            typeof(self.Player)
        )
    )

    self.Forces = {}
    self.IgnoreInstances = {}

    self.RaycastParams = RaycastParams.new()
    self.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    self.RaycastParams.FilterDescendantsInstances = self.IgnoreInstances

    self.ChartacterAddedConnection = self.Player.CharacterAppearanceLoaded:Connect(function(char: Model)  Character.added(self, char) end)

    return self
end

Character.PlayerAddedConnection = game.Players.PlayerAdded:Connect(Character.new)

return Character