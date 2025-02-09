local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears
local vulnerableEnemies = {}
local player = Isaac.GetPlayer(0)

-- -- Disable enemy collisions with a random chance
-- function Schizophrenia:GetTearParent(entity)
--     local activeEnemyCtr = 0
--     for _, entity in ipairs(Isaac.GetRoomEntities()) do
--         if entity:IsActiveEnemy(false) then
--             activeEnemyCtr = activeEnemyCtr + 1
--         end
--     end
--     for _, entity in ipairs(Isaac.GetRoomEntities()) do
--         if entity.Type == EntityType.ENTITY_PROJECTILE then
--             local proj = entity:ToProjectile()
--             local spawner = proj.SpawnerEntity



--             if spawner then
--                 for _, value in ipairs(hallucinations) do
--                     if GetPtrHash(spawner) == GetPtrHash(value) then
--                         print("hello")
--                         proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)

--                         break
--                     end
--                 end
--             end
--         elseif entity:IsActiveEnemy(false) and entity.SpawnerEntity ~= nil then
--             local exists = false
--             for _, value in ipairs(hallucinations) do
--                 if GetPtrHash(entity) == GetPtrHash(value) then
--                     exists = true

--                     break
--                 end
--             end
--             local parentIsHallucination = false

--             for _, value in ipairs(hallucinations) do
--                 if GetPtrHash(entity.SpawnerEntity) == GetPtrHash(value) then
--                     parentIsHallucination = true

--                     break
--                 end
--             end
--             if not exists and parentIsHallucination then
--                 invinciCtr = invinciCtr + 1
--                 table.insert(hallucinations, entity)
--             end
--         end
--     end
--     local roomEntities = Isaac.GetRoomEntities()

--     -- Filter to get only vulnerable enemies
--     local vulnerableEnemies = {}
--     for _, entity in ipairs(roomEntities) do
--         if entity:IsVulnerableEnemy() then
--             table.insert(vulnerableEnemies, entity)
--         end
--     end

--     -- If all vulnerable enemies in the room are hallucinations, remove all enemies
--     if activeEnemyCtr <= #hallucinations + invinciCtr then
--         Schizophrenia:FadeOut(hallucinations)
--         -- for _, entity in ipairs(hallucinations) do
--         --     -- entity:Kill() -- Kill the enemy

--         -- end
--     end

--     -- Print the count of hallucinations and vulnerable enemies
--     print(activeEnemyCtr, #hallucinations, invinciCtr)
-- end

-- Reset enemy and tear collisions when transitioning to a new room
function Schizophrenia:OnNpcInit(entity)
    if player:HasCollectible(Schizophrenia.ID) then
        if entity:IsVulnerableEnemy() and entity.Type ~= EntityType.ENTITY_FIREPLACE and entity.Type ~= EntityType.ENTITY_BOMB then
            if entity.SpawnerEntity then
                local parentIsHallucination = false
                for _, hallucination in ipairs(hallucinations) do
                    if GetPtrHash(hallucination) == GetPtrHash(entity.SpawnerEntity) then
                        parentIsHallucination = true
                        break
                    end
                end
                if parentIsHallucination then
                    table.insert(hallucinations, entity)
                    entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                end
            else
                local rng = player:GetCollectibleRNG(Schizophrenia.ID)
                local roll = rng:RandomFloat()
                if roll < 0.20 then
                    if entity:IsBoss() then
                        local roll = rng:RandomFloat()
                        if roll < 0.5 then
                            table.insert(hallucinations, entity)
                            entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                            entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                        end
                    else
                        table.insert(hallucinations, entity)
                        entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                    end
                else
                    table.insert(vulnerableEnemies, entity)
                end
            end
        end
    end
end

function Schizophrenia:OnProjectileInit(entity)
    local parentIsHallucination = false
    for _, hallucination in ipairs(hallucinations) do
        if GetPtrHash(hallucination) == GetPtrHash(entity.SpawnerEntity) then
            parentIsHallucination = true
            break
        end
    end
    if parentIsHallucination then
        if entity.Type == EntityType.ENTITY_PROJECTILE then
            local projectile = entity:ToProjectile()
            projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
        elseif entity.Type == EntityType.ENTITY_EFFECT then
            if entity.Variant == EffectVariant.CREEP_GREEN then
                entity:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)
            end
        end
    end
end

local fading = false -- Flag to track whether fade-out is active

function Schizophrenia:FadeOut(entities)
    local allFaded = true -- Track if all entities are fully faded

    for _, entity in ipairs(entities) do
        local currentAlpha = entity.Color.A

        if currentAlpha > 0 then
            allFaded = false -- At least one entity is still fading
            entity.Color = Color(entity.Color.R, entity.Color.G, entity.Color.B, math.max(0, currentAlpha - 0.05))
        end

        if currentAlpha <= 0 then
            entity:Remove()
        end
    end

    -- Stop updating if all hallucinations are gone
    if allFaded then
        fading = false -- Disable the fade-out loop
    end
end

function Schizophrenia:OnEntityKill(entity)
    -- Remove entity from vulnerableEnemies
    for i, v in ipairs(vulnerableEnemies) do
        if GetPtrHash(v) == GetPtrHash(entity) then
            table.remove(vulnerableEnemies, i)
            break
        end
    end

    -- Start fading hallucinations if no vulnerable enemies remain
end

function Schizophrenia:OnUpdate()
    if #vulnerableEnemies == 0 and not fading then
        fading = true
    end

    if fading then
        Schizophrenia:FadeOut(hallucinations)
    end
    print(#vulnerableEnemies)
end

function Schizophrenia:OnNewRoom()
    vulnerableEnemies = {}
    fading = false
end

return Schizophrenia
