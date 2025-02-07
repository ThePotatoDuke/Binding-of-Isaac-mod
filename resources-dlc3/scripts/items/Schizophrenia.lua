local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears
local invinciCtr = 0


-- Disable enemy collisions with a random chance
function Schizophrenia:GetTearParent()
    local activeEnemyCtr = 0
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity:IsActiveEnemy(false) then
            activeEnemyCtr = activeEnemyCtr + 1
        end
    end
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            local proj = entity:ToProjectile()
            local spawner = proj.SpawnerEntity



            if spawner then
                for _, value in ipairs(hallucinations) do
                    if GetPtrHash(spawner) == GetPtrHash(value) then
                        print("hello")
                        proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)

                        break
                    end
                end
            end
        elseif entity:IsActiveEnemy(false) and entity.SpawnerEntity ~= nil then
            local exists = false
            for _, value in ipairs(hallucinations) do
                if GetPtrHash(entity) == GetPtrHash(value) then
                    exists = true

                    break
                end
            end
            local parentIsHallucination = false

            for _, value in ipairs(hallucinations) do
                if GetPtrHash(entity.SpawnerEntity) == GetPtrHash(value) then
                    parentIsHallucination = true

                    break
                end
            end
            if not exists and parentIsHallucination then
                invinciCtr = invinciCtr + 1
                table.insert(hallucinations, entity)
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
    if activeEnemyCtr == #hallucinations + invinciCtr then
        Schizophrenia:FadeOut(hallucinations)
        -- for _, entity in ipairs(hallucinations) do
        --     -- entity:Kill() -- Kill the enemy

        -- end
    end

    -- Print the count of hallucinations and vulnerable enemies
    print(activeEnemyCtr, #hallucinations, invinciCtr)
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
    local player = Isaac.GetPlayer(0)
    hallucinations = {}
    invinciCtr = 0


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
            elseif entity:IsEnemy() and not entity:IsVulnerableEnemy() then
                invinciCtr = invinciCtr + 1
            end
        end
    end
end

return Schizophrenia
