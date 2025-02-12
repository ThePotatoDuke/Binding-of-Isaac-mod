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
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:GetEntityFlags() & ENEMY_FLAG_MALEDICTION ~= 0 then
            entity.Color = Color(1, 0, 0, 1)
        else
            entity.Color = Color(1, 1, 1, 1)
        end
    end
end

function Malediction:OnItemUse(player)
    local playerDamage = player.Damage
    local markedCtr = 0

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:GetEntityFlags() & ENEMY_FLAG_MALEDICTION ~= 0 then
            markedCtr = markedCtr + 1
        end
    end

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:GetEntityFlags() & ENEMY_FLAG_MALEDICTION ~= 0 then
            entity:TakeDamage(playerDamage * markedCtr, DamageFlag.DAMAGE_ACID, EntityRef(player), 0)
            local effect
            if markedCtr == 1 then
                effect = EffectVariant.BLUE_FLAME
            else
            end
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, entity.Position,
                Vector(0, 0), player)
            effect.Color = Color(1, 1, 1, 1)
            entity:ClearEntityFlags(ENEMY_FLAG_MALEDICTION)
        end
    end
end

return Malediction
