-- items/clock.lua

local game = Game()
local sfx = SFXManager()
local ClockItem = {}

ClockItem.ID = Isaac.GetItemIdByName("Grandfather's Clock")
local SOUND_EXPLOSION = Isaac.GetSoundIdByName("explosion_bell")
local SOUND_FREEZE = Isaac.GetSoundIdByName("petrifying_bell")
local SOUND_BIRD = Isaac.GetSoundIdByName("cuckoo_bell")

local timers = {}
local function startTimer(duration, callback)
    table.insert(timers, { framesLeft = duration, callback = callback })
end

local spawnedDeadBirds = {}

local function spawnDeadBird(player)
    local position = player.Position
    local deadBird = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DEAD_BIRD, 0, position, Vector(0, 0), player)
    deadBird:ToFamiliar():AddToFollowers()

    -- Store reference for removal later
    table.insert(spawnedDeadBirds, deadBird)
end

local function startDeadBirdSequence()
    local player = Isaac.GetPlayer(0)

    spawnDeadBird(player)
    sfx:Play(SOUND_BIRD, 4, 2, false, 1)

    startTimer(40, function()
        if math.random() < 0.5 then
            spawnDeadBird(player)
            sfx:Play(SOUND_BIRD, 4, 2, false, 0.8)

            startTimer(40, function()
                if math.random() < 0.5 then
                    spawnDeadBird(player)
                    sfx:Play(SOUND_BIRD, 4, 2, false, 0.6)
                end
            end)
        end
    end)
end


function ClockItem:removeDeadBirds()
    for _, bird in ipairs(spawnedDeadBirds) do
        if bird:Exists() then
            bird:Remove()
        end
    end
    spawnedDeadBirds = {} -- Reset the list
end

-- Hook into room change event


function ClockItem:OnBellChime(player)
    local rng = player:GetCollectibleRNG(ClockItem.ID)
    local room = game:GetRoom()
    local roll = rng:RandomInt(100)

    if roll < 33 then
        room:MamaMegaExplosion(player.Position)
        sfx:Play(SOUND_EXPLOSION, 3.6)
    elseif roll < 66 then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() then
                entity:AddFreeze(EntityRef(player), 150)
            end
        end
        MusicManager():Pause()
        sfx:Play(SOUND_FREEZE, 4)
        startTimer(150, function()
            MusicManager():Resume()
        end)
    else
        startDeadBirdSequence()
    end
end

function ClockItem:OnUpdate()
    local numPlayers = game:GetNumPlayers()
    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)

        if player:HasCollectible(ClockItem.ID) then
            if game:GetFrameCount() % 300 == 0 then -- Reduced to 300 frames (10 sec) for testing
                ClockItem:OnBellChime(player)
            end
        end
    end

    -- Timer logic
    for i = #timers, 1, -1 do
        timers[i].framesLeft = timers[i].framesLeft - 1
        if timers[i].framesLeft <= 0 then
            timers[i].callback()
            table.remove(timers, i)
        end
    end
end

return ClockItem
