local Schizophrenia = {}
Schizophrenia.ID = Isaac.GetItemIdByName("Schizophrenia")
local hallucinations = {} -- Table to track affected tears
local vulnerableEnemies = {}


function Schizophrenia:OnNpcInit(entity)
    local player = Isaac.GetPlayer(0)

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
                if roll < 0.50 then
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
    print("Schizophrenia OnUpdate running")
    if #vulnerableEnemies == 0 and not fading then
        fading = true
    end

    if fading then
        Schizophrenia:FadeOut(hallucinations)
    end
end

function Schizophrenia:OnNewRoom()
    vulnerableEnemies = {}
    fading = false
end

return Schizophrenia
