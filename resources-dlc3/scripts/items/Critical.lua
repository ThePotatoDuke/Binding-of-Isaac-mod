local Critical = {}
Critical.ID = Isaac.GetItemIdByName("Critical Hit")

local tears = {} -- Table to track tears

-- Add tears to the table when they spawn
function Critical:OnTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(Critical.ID) then
        table.insert(tears, { tear = tear, isBoosted = false })
    end
end

-- Scale tears that have fallen enough
function Critical:scaleTear()
    for i, storedTear in ipairs(tears) do
        local tear = storedTear.tear
        if tear and tear:Exists() then
            if tear.Height > -10 and not storedTear.isBoosted then
                storedTear.isBoosted = true
                tear.CollisionDamage = tear.CollisionDamage * 1.8
                tear.Scale = tear.Scale * 1.3
            end
            if tear.Height < -14 and storedTear.isBoosted then
                storedTear.isBoosted = false
                tear.CollisionDamage = tear.CollisionDamage / 1.8
                tear.Scale = tear.Scale / 1.3
            end
        else
            -- Remove invalid tears
            table.remove(tears, i)
        end
    end
end

-- Damage marked enemies when hit by boosted tears
function Critical:OnEnemyHit(e, c, l)
    for _, storedTear in ipairs(tears) do
        if storedTear.tear and GetPtrHash(storedTear.tear) == GetPtrHash(e) then
            if storedTear.isBoosted and c:IsVulnerableEnemy() then
                Game():MakeShockwave(e.Position, 0.024, 0.015, 10)
                break
            end
        end
    end
end

local game = Game()
function Critical:OnCache(player, cacheFlags)
    if cacheFlags & CacheFlag.CACHE_RANGE ~= 0 then
        local numPlayers = game:GetNumPlayers()
        for i = 0, numPlayers - 1 do
            local player = Isaac.GetPlayer(i)
            if player:HasCollectible(Critical.ID) then
                player.TearRange = player.TearRange * 0.6
                player.TearFallingSpeed = player.TearFallingSpeed + 1
                break
            end
        end
    end
end

return Critical
