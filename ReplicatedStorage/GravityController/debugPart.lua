local DebugPart = _G.GravityController.Object:subclass{}

function DebugPart.draw(self: table, origin: Vector3, target: Vector3)

    self.Part.Color = self.Color or Color3.new(1, 0.211764, 0.211764)
    self.Part.Material = self.Material or Enum.Material.SmoothPlastic

    local dif = target - origin
    local dir = dif.Unit
    local dist = dif.Magnitude

    self.Part.Size = Vector3.new(dist, self.Thickness,  self.Thickness)
    self.Part.CFrame = CFrame.lookAt(origin, origin+dir) * CFrame.new(0,0,-dist/2)
end

function DebugPart.init(self: table)
    
    self.Part = self.Part or Instance.new("Part", self.Parent or workspace)
    
    self.Part.Name = self.Name or string.format("DebugPart:&s", tick())

    self.Part.Anchored = true
    self.Part.CanCollide = false

    self.Thickness = self.Thickness or .1

    return self
end

return DebugPart