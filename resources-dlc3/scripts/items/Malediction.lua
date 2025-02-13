local Malediction = {}

local sfx = SFXManager()
local SOUND_MALEDICTION = Isaac.GetSoundIdByName("malediction")

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

    local data = tear:GetData()
    data.MaledictionTear = true
end

-- Helper function to track players separately
function GetPlayerIndex(player)
    local id = player.ControllerIndex or 1
    return id
end

function Malediction:OnEnemyHit(t, c, l)
    local tearData = t:GetData()
    local enemyData = c:GetData()

    if tearData.MaledictionTear and not enemyData.MaledictionMarked then
        print("pre collision mark")

        -- Mark the enemy
        enemyData.MaledictionMarked = true
        print("post collision mark")
    end
end

function Malediction:OnUpdate()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        if data.MaledictionMarked then
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
    sfx:Play(SOUND_MALEDICTION, 3)
    local playerDamage = player.Damage
    local markedEnemies = {}

    -- Collect all marked enemies
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        if data.MaledictionMarked then
            table.insert(markedEnemies, entity)
        end
    end

    local markedCtr = #markedEnemies -- Get total count of marked enemies

    -- Apply damage all at once
    if markedCtr > 0 then
        print(markedCtr)
        for _, entity in ipairs(markedEnemies) do
            entity:TakeDamage(playerDamage * 1.5 * markedCtr, DamageFlag.DAMAGE_ACID, EntityRef(player), 0)

            -- Choose effect
            local effect

            effect = EffectVariant.POOF02
            local spawnedEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, entity.Position, Vector(0, 0),
                player)
            spawnedEffect.SpriteScale = Vector(0.5 * markedCtr, 0.5 * markedCtr)



            -- Clear mark
            entity:GetData().MaledictionMarked = nil
        end
    end
end

return Malediction
