local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears

-- Disable enemy collisions with a random chance
function Schizophrenia:GetTearParent()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            local proj = entity:ToProjectile()
            local spawner = proj.SpawnerEntity

            print(#hallucinations)

            if spawner then
                for _, value in ipairs(hallucinations) do
                    if GetPtrHash(spawner) == GetPtrHash(value) then
                        print("hello")
                        proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.EFFECT_POOF, 0, entity.Position, Vector(0, 0),
                            nil)

                        break
                    end
                end
            end
        end
    end
    local roomEntities = Isaac.GetRoomEntities()

    -- Filter to get only vulnerable enemies
    local vulnerableEnemies = {}
    for _, entity in ipairs(roomEntities) do
        if entity:IsVulnerableEnemy() then
            table.insert(vulnerableEnemies, entity)
        end
    end

    -- If all vulnerable enemies in the room are hallucinations, remove all enemies
    if #vulnerableEnemies == 0 then
        for _, entity in ipairs(hallucinations) do
            entity:Kill() -- Kill the enemy
        end
    end

    -- Print the count of hallucinations and vulnerable enemies
    print(#hallucinations, #vulnerableEnemies)
end

-- Reset enemy and tear collisions when transitioning to a new room
function Schizophrenia:OnNewRoom()
    hallucinations = {}
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Schizophrenia.ID) then
        -- Iterate over all room entities
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() then
                -- Random chance to disable enemy collision (50% chance in this case)
                if math.random() < 0.5 then
                    local exists = false
                    for _, hallucination in ipairs(hallucinations) do
                        if GetPtrHash(hallucination) == GetPtrHash(entity) then
                            exists = true
                            break
                        end
                    end
                    if not exists then
                        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        entity.GridCollisionClass = EntityGridCollisionClass
                            .GRIDCOLL_NONE
                        table.insert(hallucinations, entity)
                    end
                end
            end
        end
    end
end

return Schizophrenia
