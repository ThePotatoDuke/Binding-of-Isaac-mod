local CricticalItem = {}
CricticalItem.ID = Isaac.GetItemIdByName("Critical Hit")

local tears = {} -- Table to track tears

-- Add tears to the table when they spawn
function CricticalItem:OnTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(CricticalItem.ID) then
        table.insert(tears, { tear = tear, isBoosted = false })
    end
end

-- Scale tears that have fallen enough
function CricticalItem:scaleTear()
    for i, storedTear in ipairs(tears) do
        local tear = storedTear.tear
        if tear and tear:Exists() then
            if tear.Height > -10 and not storedTear.isBoosted then
                storedTear.isBoosted = true
                tear.CollisionDamage = tear.CollisionDamage * 1.5
                tear.Scale = tear.Scale * 1.4
            end
        else
            -- Remove invalid tears
            table.remove(tears, i)
        end
    end
end

-- Damage marked enemies when hit by boosted tears
function CricticalItem:OnEnemyHit(e, c, l)
    for _, storedTear in ipairs(tears) do
        if storedTear.tear and GetPtrHash(storedTear.tear) == GetPtrHash(e) then
            if storedTear.isBoosted and c:IsVulnerableEnemy() then
                Game():MakeShockwave(e.Position, 0.024, 0.015, 10)
                break
            end
        end
    end
end

function CricticalItem:OnCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_RANGE ~= 0 then
        local stats = player:GetData().CriticalStats or {}
        stats.RangeMult = (stats.RangeMult or 1) * 0.8
        player:GetData().CriticalStats = stats
        player.TearRange = player.TearRange * stats.RangeMult
        player.TearFallingSpeed = player.TearFallingSpeed + 1
    end
end

return CricticalItem
