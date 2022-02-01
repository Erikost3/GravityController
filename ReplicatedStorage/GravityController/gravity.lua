local RunService = game:GetService("RunService")
local Gravity = _G.GravityController.Object:subclass{}

Gravity.PhysicsObject = _G.GravityController.Object:subclass{}

function Gravity.PhysicsObject:Destroy(self: table)
    return self.Force and self.Force:Destroy()
end

function Gravity.PhysicsObject.init(self: table)
    
    assert(
        typeof(self.Instance) == "Instance",
        string.format(
            "GravityController.Gravity.PhysicsObject.init: Expected self.Part to be Instance, got '%s'",
            typeof(self.Instance)
        )
    )

    self.Force = not self.NoPhysics or Instance.new("BodyForce", self.Instance)

    return self
end

function Gravity.getInstanceMass(instance: Instance)
    
    local m = 0

    if instance:IsA("BasePart") then
        m += instance:GetMass()
    end

    for i,v in pairs(instance:GetDescendants()) do
        if v:IsA("BasePart") then
            m += v:GetMass()
        end
    end

    return m
end

function Gravity.getInstanceCenter(instance: Instance)

    local sum, parts = Vector3.zero, 0

    if instance:IsA("BasePart") then
        sum += instance.Position
    end

    for i,v in pairs(instance:GetDescendants()) do
        if v:IsA("BasePart") then
            sum += instance.Position
        end
    end

    return math.abs(parts) > 0 and sum/parts or nil
end


function Gravity.getInstanceGravityVelocity(self: table, instance: Instance)
    
    local velocity = Vector3.zero

    local m1, pos1 = Gravity.getInstanceMass(instance), Gravity.getInstanceMass(instance)

    assert(
        pos1 ~= nil,
        "GravityController.Gravity.getInstanceForce: Expected instance to have a position"
    )

    for i,v in pairs(self.PhysicsObjects) do
        if v.Instance ~= nil then
            local m2, pos2 = Gravity.getInstanceMass(instance), Gravity.getInstanceMass(v.Instance)

            if pos2 then

                local diff = (pos2 - pos1)
                local dir = diff.unit

                -- https://en.wikipedia.org/wiki/Newton%27s_law_of_universal_gravitation

                local r = diff.Magnitude
                local G = self.GravityConstant
                local force = G * ( (m1*m2) / (r*r) )
                
                velocity += dir * force
            end
        end
    end

    return velocity
end

function Gravity.counterGravity(instance: Instance)
    return Vector3.new(0, workspace.Gravity * Gravity.getInstanceMass(instance), 0)
end

function Gravity.physicsStep(self: table, time: any, deltaTime: any)
    for i,v in pairs(self.PhysicsObjects) do
        if v.Instance ~= nil then
            if v.Force then
                v.Force += Gravity.counterGravity(v.Instance)
                v.Force += Gravity.getInstanceGravityVelocity(self, v.Instance)
            end
        else
            v:Destroy()
        end
    end
end

function Gravity.findPhysicsObjectBy(self: table, identifyer: any)
    for i,v in pairs(self.PhysicsObjects) do
        for j, k in pairs(v) do
            if k == identifyer then
                return v
            elseif typeof(identifyer) == "table" then
                for ij, vk in pairs(identifyer) do
                    if ij == j and vk == k then
                        return v, i
                    end
                end
            end
        end
    end
end

function Gravity.addPhysicsObject(self: table, instance: Instance, customProps: table)
    
    assert(
        typeof(instance) == "Instance",
        string.format(
            "GravityController.Gravity.PhysicsObject.addPhysicsObject: Expected instance to be Instance, got '%s'",
            typeof(instance)
        )
    )

    assert(
        not self:FindPhysicsObjectBy(instance),
        "GravityController.Gravity.PhysicsObject.addPhysicsObject: Instance already added to self.PhysicsObjects"
    )

    assert(
        instance:IsA("Model") or instance:IsA("BasePart"),
        string.format(
            "GravityController.Gravity.PhysicsObject.addPhysicsObject: Expected instance to be of the type Model or BasePart, got '%s'",
            typeof(instance)
        )
    )

    customProps = typeof(customProps) == "table" and customProps or {}

    customProps.Instance = instance

    local newPhysicsObject = Gravity.PhysicsObject(customProps)

    table.insert(self.PhysicsObjects, newPhysicsObject)

    return newPhysicsObject
end

function Gravity.init(self: table)

    self.GravityConstant = self.GravityConstant or (6.674 ^ (10^-11)) -- https://en.wikipedia.org/wiki/Gravitational_constant
    self.PhysicsObjects = self.PhysicsObjects or {}

    function self:AddPhysicsObject(...)
        return Gravity.findPhysicsObjectBy(self, ...)
    end

    function self:FindPhysicsObjectBy(...)
        return Gravity.findPhysicsObjectBy(self, ...)
    end

    self.PhysicsConnection = RunService.Stepped:Connect(function(time, deltaTime)
        Gravity.PhysicsStep(time, deltaTime)
    end)

    return self
end

return Gravity