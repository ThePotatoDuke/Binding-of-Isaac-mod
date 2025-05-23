local Malediction = {}
local Utils = require("utils") -- Require the utility module
local sfx = SFXManager()
local SOUND_MALEDICTION = Isaac.GetSoundIdByName("malediction")
local sprite = Sprite()
sprite:Load("gfx/ui/Mark.anm2", true)
local maxCharge = Isaac.GetItemConfig():GetCollectible(Isaac.GetItemIdByName("Malediction")).MaxCharges

-- Item ID (make sure to set the correct name)
Malediction.ID = Isaac.GetItemIdByName("Malediction")

-- Track the number of tears shot
Malediction.TearCount = {}

-- Function to handle tear firing
function Malediction:OnTearInit(tear, player)
    if player and player:GetActiveItem() == Malediction.ID then
        local playerIndex = GetPlayerIndex(player) -- Function to track multiple players


        local charge = player:GetActiveCharge()
        if charge == maxCharge then
            if not Malediction.TearCount[playerIndex] then
                Malediction.TearCount[playerIndex] = 0
            end

            Malediction.TearCount[playerIndex] = Malediction.TearCount[playerIndex] + 1


            -- Every 3rd tear, apply a special effect
            if Malediction.TearCount[playerIndex] >= 2 then
                Malediction.TearCount[playerIndex] = 0 -- Reset counter
                Malediction:ApplySpecialTearEffect(tear)
            end
        end
    end
end

function Malediction:ApplySpecialTearEffect(tear)
    tear.Scale = 1.2
    tear.Color = Color(1, 0, 0, 1, 0, 0, 0) -- Dark purple color

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

    if tearData.MaledictionTear and not enemyData.MaledictionMarked and not Utils:IsIgnoredEntity(c) then
        -- Mark the enemy
        enemyData.MaledictionMarked = true
    end
end

function Malediction:OnRender()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        local data = entity:GetData()
        if data.MaledictionMarked then
            sprite:SetFrame("mark", 0)
            sprite:Render(Isaac.WorldToScreen(entity.Position) - Vector(0, 40), Vector.Zero, Vector.Zero)
        end
    end
end

function Malediction:OnItemUse(player)
    sfx:Play(SOUND_MALEDICTION, 4)
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
        for _, entity in ipairs(markedEnemies) do
            entity:TakeDamage(playerDamage * 1.8 * markedCtr, DamageFlag.DAMAGE_ACID, EntityRef(player), 0)

            -- Choose effect
            local effect

            effect = EffectVariant.POOF02
            local spawnedEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, effect, 0, entity.Position, Vector(0, 0),
                player)
            spawnedEffect.SpriteScale = Vector(math.min(0.5 + 0.3 * markedCtr, 2), math.min(0.5 + 0.3 * markedCtr, 2))



            -- Clear mark
            entity:GetData().MaledictionMarked = nil
        end
    end
end

return Malediction
