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

return Test