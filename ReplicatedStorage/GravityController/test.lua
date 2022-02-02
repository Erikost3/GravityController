local Test = _G.GravityController.Object:subclass{}

local function newPart(props)
    local p = props["Part"] or Instance.new("Part", workspace)
    p.CanCollide = false
    p.Anchored = true

    for i,v in pairs(props) do
        pcall(function()
            p[i] = v
        end)
    end

    return p
end

function Test.initializeTesting(parent: Instance)
    
    Test.Folder = Test.Folder or Instance.new("Folder", workspace)
    Test.Folder.Name = string.format("GravityControllerTest:%s", tick())

end


function Test.gravity()

    Test.initializeTesting()

    local GravityTestFolder = Instance.new("Folder", Test.Folder)
    GravityTestFolder.Name = string.format("GravityTestFolder:%s", tick())

    local Part1 = newPart {Position = Vector3.new(0, 50, 0), CanCollide = true, Anchored = false, Parent = GravityTestFolder} 
    local Part2 = newPart {Position = Vector3.new(0, 60, 0), CanCollide = true, Anchored = false, Parent = GravityTestFolder}

    local GravitySimulation = _G.GravityController.Gravity {}

    GravitySimulation:AddPhysicsObject(Part1)
    GravitySimulation:AddPhysicsObject(Part2)
    
end

function Test.character()
    
    local Dummy = script:FindFirstChild("Dummy")

    if not Dummy then warn("GravityController.Test.character: Expected a character 'Dummy' inside script") end

    assert(
        Dummy:IsA("Model") and Dummy.PrimaryPart ~= nil,
        string.format(
            "GravityController.Test.character: Expected Dummy to be a Model with a PrimaryPart, got '%s, PrimaryPart==%s'", 
            Dummy.ClassName, 
            tostring(Dummy.PrimaryPart))
    )

    Test.initializeTesting()

    local CharacterTestFolder = Instance.new("Folder", Test.Folder)
    CharacterTestFolder.Name = string.format("CharacterTestFolder:%s", tick())

    Dummy = Dummy:Clone(); Dummy.Parent = CharacterTestFolder

    local Humanoid = Dummy:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
    end

    _G.GravityController.CharacterController {Character = Dummy, Debug = true}

    local Part1 = newPart {Position = Vector3.new(0, 50, 0), Size = Vector3.new(100, 100, 100), CanCollide = true, Anchored = false, Parent = CharacterTestFolder}

    Part1.CustomPhysicalProperties = PhysicalProperties.new(
        .2,
        .1,
        1
    )

    _G.GravityController.CharacterController.Gravity:AddPhysicsObject(Part1)

    local Part2 = newPart {Position = Vector3.new(0, 0, 5000), Size = Vector3.new(1000, 1000, 1000), CanCollide = true, Anchored = false, Parent = CharacterTestFolder}

    Part2.CustomPhysicalProperties = PhysicalProperties.new(
        .1,
        .3,
        5
    )

    _G.GravityController.CharacterController.Gravity:AddPhysicsObject(Part2)

    --Dummy.PrimaryPart.Anchored = false

end

function Test.testall()
    Test.gravity()
    Test.character()
end

return Test