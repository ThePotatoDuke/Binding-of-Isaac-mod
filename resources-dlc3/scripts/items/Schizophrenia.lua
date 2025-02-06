local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears

-- Disable enemy collisions with a random chance
function Schizophrenia:GetTearParent()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            local proj = entity:ToProjectile()
            local spawner = proj.SpawnerEntity



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
        Schizophrenia:FadeOut(hallucinations)
        -- for _, entity in ipairs(hallucinations) do
        --     -- entity:Kill() -- Kill the enemy

        -- end
    end

    -- Print the count of hallucinations and vulnerable enemies
    print(#hallucinations, #vulnerableEnemies)
end

function Schizophrenia:FadeOut(entities)
    for _, entity in ipairs(entities) do
        local currentAlpha = entity.Color.A
        if currentAlpha <= 0 then
            entity:Remove()
        end
        entity.Color = Color(entity.Color.R, entity.Color.G, entity.Color.B, currentAlpha - 0.1)
    end
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
