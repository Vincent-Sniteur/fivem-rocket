local rockets = {}
local rocketActive = false

-- Command to start the Rocket
RegisterCommand("rocket", function(source)
    print("Rocket command received")
    print("Setting rocketActive to true")
    rocketActive = true
    print("rocketActive is now", rocketActive)

    while rocketActive do
        rocketCreation()
        Citizen.Wait(3000) -- wait 3 seconds before spawning the next rocket
        cleanUpRockets()
    end
end)

function rocketCreation()
    -- Get player coordinates
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    -- Load rocket model
    local rocketModel = GetHashKey('w_arena_airmissile_01a')
    RequestModel(rocketModel)
    while not HasModelLoaded(rocketModel) do
        Citizen.Wait(0)
    end

    -- Create rocket object
    local rocketX = coords.x + math.random(-75, 75)
    local rocketY = coords.y + math.random(-75, 75)
    local rocketZ = coords.z + 50
    local rocketObj = CreateObject(rocketModel, rocketX, rocketY, rocketZ, true, true, true)

    -- Set rocket physics
    SetEntityDynamic(rocketObj, true)
    SetObjectPhysicsParams(rocketObj, 9999.0, 0.0, 0.0, 0.0, 0.0, 700.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    SetEntityVelocity(rocketObj, 0.0, 0.0, math.random() + math.random(-10, -5))

    -- Add rocket to table for cleanup
    table.insert(rockets, {obj = rocketObj})
end

function cleanUpRockets()
    for i, rocket in ipairs(rockets) do
        local height = GetEntityHeightAboveGround(rocket.obj)
        if height < 2.0 then
            local coords = GetEntityCoords(rocket.obj)
            AddExplosion(coords.x, coords.y, coords.z, -1, 1.0, true, false, 0.0)
            DeleteEntity(rocket.obj)
            table.remove(rockets, i)
        end
    end
end