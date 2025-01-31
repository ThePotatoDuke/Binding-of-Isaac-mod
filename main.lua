local ClockMod = RegisterMod("Grandfather's Clock", 1)
local game = Game()
local CLOCK = Isaac.GetItemIdByName("Grandfather's Clock")
local sfx = SFXManager()
local SOUND_EXPLOSION = Isaac.GetSoundIdByName("explosion_bell")
local SOUND_FREEZE = Isaac.GetSoundIdByName("petrifying_bell")
local SOUND_BIRD = Isaac.GetSoundIdByName("cuckoo_bell")

local timers = {}
local function startTimer(duration, callback)
    table.insert(timers, { framesLeft = duration, callback = callback })
end

local function spawnDeadBird(player)
    local position = player.Position
    local deadBird = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.DEAD_BIRD, 0, position, Vector(0, 0), player)
    deadBird:ToFamiliar():AddToFollowers()
end
-- Function to start the sequence
local function startDeadBirdSequence()
    local player = Isaac.GetPlayer(0)

    -- Spawn the first Dead Bird instantly
    spawnDeadBird(player)
    sfx:Play(SOUND_BIRD, 3.0)
    -- First delay: 40 frames
    startTimer(40, function()
        if math.random() < 0.5 then -- 50% chance
            spawnDeadBird(player)
            sfx:Play(SOUND_BIRD, 3.0, 2, false, 0.7)
            -- Second delay: 40 frames
            startTimer(40, function()
                if math.random() < 0.5 then -- 50% chance
                    spawnDeadBird(player)
                    sfx:Play(SOUND_BIRD, 3.0, 2, false, 0.5)
                end
            end)
        end
    end)
end

function ClockMod:OnUpdate()
    local numPlayers = game:GetNumPlayers()

    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(CLOCK) then
            if game:GetFrameCount() % 1800 == 0 then
                ClockMod:OnBellChime(player)
            end
        end
    end

    for i = #timers, 1, -1 do
        timers[i].framesLeft = timers[i].framesLeft - 1
        if timers[i].framesLeft <= 0 then
            timers[i].callback()
            table.remove(timers, i)
        end
    end
end

ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, ClockMod.OnUpdate)

function ClockMod:OnBellChime(player)
    local rng = player:GetCollectibleRNG(CLOCK)
    local room = game:GetRoom()
    local roll = rng:RandomInt(100)
    if roll < 33 then
        room:MamaMegaExplosion(Vector.Zero)
        sfx:Play(SOUND_EXPLOSION, 3.6)
    elseif roll < 66 then
        for _, entity in pairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() then
                entity:AddFreeze(EntityRef(player), 120)
            end
        end
        sfx:Play(SOUND_FREEZE, 4.0)
    else
        startDeadBirdSequence()
    end
end

-- Spawn items at game start
function ClockMod:onGameStart(isContinued)
    if not isContinued then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CLOCK, Vector(300, 300),
            Vector(0, 0), nil)
    end
end

ClockMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, ClockMod.onGameStart)
