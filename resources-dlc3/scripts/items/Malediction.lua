-- Malediction item logic

local Malediction = {}
local TEAR_FLAG_MALEDICTION = 1 << 63
local ENEMY_FLAG_MALEDICTION = 1 << 63




-- Item ID (make sure to set the correct name)
Malediction.ID = Isaac.GetItemIdByName("Malediction")

-- Track the number of tears shot
Malediction.TearCount = {}

-- Function to handle tear firing
function Malediction:OnTearInit(tear, player)
    if player and player:GetActiveItem() == Malediction.ID then
        local playerIndex = GetPlayerIndex(player) -- Function to track multiple players

        if not Malediction.TearCount[playerIndex] then
            Malediction.TearCount[playerIndex] = 0
        end

        Malediction.TearCount[playerIndex] = Malediction.TearCount[playerIndex] + 1
        print(Malediction.TearCount[playerIndex])

        -- Every 3rd tear, apply a special effect
        if Malediction.TearCount[playerIndex] >= 3 then
            print("inside")
            Malediction.TearCount[playerIndex] = 0 -- Reset counter
            Malediction:ApplySpecialTearEffect(tear)
        end
    end
end

function Malediction:ApplySpecialTearEffect(tear)
    tear.Scale = 1.6
    tear.Color = Color(0.5, 0, 0.5, 1, 0, 0, 0) -- Dark purple color

    print("Old tear flags:", tear.TearFlags)
    tear:AddEntityFlags(TEAR_FLAG_MALEDICTION)
    print("New tear flags:", tear.TearFlags)
end

-- Helper function to track players separately
function GetPlayerIndex(player)
    local id = player.ControllerIndex or 1
    return id
end

function Malediction:OnEnemyHit(t, c, l)
    -- Check if the tear has the Malediction flag set
    if (t:GetEntityFlags() & TEAR_FLAG_MALEDICTION ~= 0) and not (c:GetEntityFlags() & ENEMY_FLAG_MALEDICTION ~= 0) then
        print("pre collision flag " .. c:GetEntityFlags())

        -- Add the Malediction enemy flag to the enemy
        c:AddEntityFlags(ENEMY_FLAG_MALEDICTION)


        print("post collision flag " .. c:GetEntityFlags())
    end
end

function Malediction:OnUpdate()
    print("Malediction OnUpdate running")
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:HasEntityFlags(ENEMY_FLAG_MALEDICTION) then
            if entity.Color.R ~= 1 or entity.Color.G ~= 0 or entity.Color.B ~= 0 then
                entity.Color = Color(1, 0, 0, 1) -- Only change color if needed
            end
        else
            if entity.Color.R ~= 1 or entity.Color.G ~= 1 or entity.Color.B ~= 1 then
                entity.Color = Color(1, 1, 1, 1)
            end
        end
    end
end

function Malediction:OnItemUse(player)
    local playerDamage = player.Damage
    local markedEnemies = {}

    -- Collect all marked enemies
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:GetEntityFlags() & ENEMY_FLAG_MALEDICTION) ~= 0 then
            table.insert(markedEnemies, entity)
        end
    end

    local markedCtr = #markedEnemies -- Get total count of marked enemies

    -- Apply damage all at once
    if markedCtr > 0 then
        for _, entity in ipairs(markedEnemies) do
            entity:TakeDamage(playerDamage * markedCtr, DamageFlag.DAMAGE_ACID, EntityRef(player), 0)

            -- Choose effect
            local effect = EffectVariant.BLUE_FLAME -- Default effect
            if markedCtr > 1 then
                effect = EffectVariant.LARGE_BLOOD_EXPLOSION
            end

            -- Spawn effect
            local spawnedEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, entity.Position, Vector(0, 0), player)
            spawnedEffect.Color = Color(1, 1, 1, 1)

            -- Clear mark
            entity:ClearEntityFlags(ENEMY_FLAG_MALEDICTION)
        end
    end
end

return Malediction
