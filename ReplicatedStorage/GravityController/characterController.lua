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
            typeof(self.Character)
        )
    )

    self.IgnoreInstances = {self.Character}

    self.DirectionDebugPart = self.Debug and _G.GravityController.DebugPart {}

    self.RaycastParams = RaycastParams.new()
    self.RaycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    self.RaycastParams.FilterDescendantsInstances = self.IgnoreInstances

    table.insert(CharacterController.Characters, self)

    local CharacterPhysicsObject = CharacterController.Gravity:AddPhysicsObject(self.Character)

    self.BodyGyro = self.Character.PrimaryPart:FindFirstChildOfClass("BodyGyro") or Instance.new("BodyGyro", self.Character.PrimaryPart)
    self.BodyGyro.MaxTorque = Vector3.new(math.huge, 0, math.huge)
    self.BodyGyro.CFrame = self.Character.PrimaryPart.CFrame

    local function OnStepped()
        local Humanoid = self.Character:FindFirstChildOfClass("Humanoid")
        
        if Humanoid and Humanoid.Health > 0 then

            local rs = workspace:Raycast(
                self.Character.PrimaryPart.Position, 
                CharacterPhysicsObject.Force.Force,
                self.RaycastParams
            )
            
            if rs and rs.Normal and rs.Instance and rs.Position then
                Humanoid:ChangeState("Physics")
                
                local CharacterFrame = self.BodyGyro.CFrame
                
                local Up = rs.Normal
                local Right = Up:Cross(CharacterFrame.LookVector)
                local Look = Right:Cross(Up)
        
                self.BodyGyro.CFrame = CFrame.fromMatrix(Vector3.zero, Right, Up, Look)
            end

            if self.DirectionDebugPart then
                self.DirectionDebugPart:Draw(self.Character.PrimaryPart.Position, rs and rs.Position or self.Character.PrimaryPart.Position + CharacterPhysicsObject.Force.Force)
            end   
        end
    end

    self.GyroCorrectionConnection = RunService.Stepped:Connect(OnStepped)

    return self
end

function CharacterController.playerAdded(player: Player)
    player.CharacterAppearanceLoaded:Connect(function(char: Model)
        CharacterController {Character = char}
    end)
end

CharacterController.PlayerAddedConnection = Players.PlayerAdded:Connect(CharacterController.playerAdded)

return CharacterController