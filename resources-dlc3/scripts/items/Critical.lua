local criticalItem = {}
criticalItem.ID = Isaac.GetItemIdByName("Critical Hit")
local player = Isaac.GetPlayer(0)

local tears = {} -- Table to track tears

function criticalItem:scaleTear()
    if player:HasCollectible(criticalItem.ID) then
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity.Type == EntityType.ENTITY_TEAR then
                local tear = entity:ToTear()
                if tear then
                    -- tear.FallingSpeed = tear.FallingSpeed + 2 -- Controlled change
                    print("Tear FallingSpeed:", tear.FallingSpeed)

                    local tearExists = false
                    for _, storedTear in ipairs(tears) do
                        if storedTear.index == tear.Index then
                            tearExists = true
                            break
                        end
                    end

                    if not tearExists then
                        table.insert(tears, { index = tear.Index, isBoosted = false })
                    end

                    for _, storedTear in ipairs(tears) do
                        if storedTear.index == tear.Index then
                            if tear.Height > -12 and not storedTear.isBoosted then
                                storedTear.isBoosted = true
                                tear.CollisionDamage = tear.CollisionDamage * 1.5
                                tear.Scale = tear.Scale * 1.4
                            end
                            break
                        end
                    end
                end
            end
        end
    end
end

function criticalItem:onCache(player, cacheFlag)
    if player:HasCollectible(criticalItem.ID) then
        if cacheFlag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * 0.8
            player.TearFallingAcceleration = player.TearFallingAcceleration
        end
    end
end

function criticalItem:OnEnemyHit(e, c, l)
    for _, storedTear in ipairs(tears) do
        if storedTear.index == c.Index and then
            if storedTear.isBoosted and e:IsVulnerableEnemy() then
                Game():MakeShockwave(c.Position, 0.035, 0.025, 10)
                break
            end
        end
    end
end

return criticalItem
