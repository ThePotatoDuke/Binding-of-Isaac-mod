local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears

-- Disable enemy collisions with a random chance
function Schizophrenia:GetTearParent()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            -- print(entity:ToProjectile().SpawnerEntity:GetData())
            print(#hallucinations)
            for _, value in ipairs(hallucinations) do
                if entity:ToProjectile().SpawnerEntity:GetData() == value:GetData() then
                    print("hoowww")
                    entity:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    break
                end
            end
        end
    end
end

-- Reset enemy and tear collisions when transitioning to a new room
function Schizophrenia:OnNewRoom()
    local player = Isaac.GetPlayer(0)
    if player:HasCollectible(Schizophrenia.ID) then
        -- Iterate over all room entities
        for _, entity in ipairs(Isaac.GetRoomEntities()) do
            if entity:IsVulnerableEnemy() then
                -- Random chance to disable enemy collision (50% chance in this case)
                if math.random() < 0.5 then
                    -- Disable enemy collision
                    entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE -- Correct grid collision class
                    table.insert(hallucinations, entity)                               -- Track hallucinated enemy
                end
            end
        end
    end
end

return Schizophrenia
