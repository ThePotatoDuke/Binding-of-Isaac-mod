-- Register the mod at the start
local DukeMod = RegisterMod("Grandfather's Clock", 1)
-- Use include instead of require to force reload every time
include("resources-dlc3.scripts.eid_itemdescriptions.lua")

DukeMod.Items = {
    Clock = include("resources-dlc3.scripts.items.Clock"),
    Key = include("resources-dlc3.scripts.items.Key"),
    Critical = include("resources-dlc3.scripts.items.Critical"),
    Schizophrenia = include("resources-dlc3.scripts.items.Schizophrenia"),
    FixedModem = include("resources-dlc3.scripts.items.FixedModem"),
    Malediction = include("resources-dlc3.scripts.items.Malediction"),
    Dyslexia = include("resources-dlc3.scripts.items.Dyslexia")
}

-- Add callbacks
DukeMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    DukeMod.Items.Schizophrenia:OnUpdate()
    -- ClockMod.Items.Malediction:OnUpdate()
    DukeMod.Items.Clock:OnUpdate()
    DukeMod.Items.Critical:scaleTear()
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    DukeMod.Items.Clock:removeDeadBirds()
    DukeMod.Items.FixedModem:GetGridDistance()
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    DukeMod.Items.Key:CheckShootingInputs()
    DukeMod.Items.FixedModem:OnRender()
    DukeMod.Items.Malediction:OnRender()
end)

DukeMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider, low)
    DukeMod.Items.Critical:OnEnemyHit(tear, collider, low)
    DukeMod.Items.Malediction:OnEnemyHit(tear, collider, low)
end)

DukeMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    print("item taken in main")
    DukeMod.Items.Critical:OnCache(player, cacheFlag)
    DukeMod.Items.FixedModem:EvaluateCache(player, cacheFlag)
    DukeMod.Items.Dyslexia:EvaluateCache(player, cacheFlag)
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, entity)
    DukeMod.Items.Schizophrenia:OnNpcInit(entity)
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, entity)
    DukeMod.Items.Schizophrenia:OnProjectileInit(entity)
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
    DukeMod.Items.Schizophrenia:OnEntityKill(entity)
end)

DukeMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, function(_, _, _)
    DukeMod.Items.Schizophrenia:OnNewRoom()
    DukeMod.Items.Key:OnNewRoom()
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
    DukeMod.Items.Critical:OnTearInit(tear)
end)

DukeMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
    DukeMod.Items.Critical:OnTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player then
        DukeMod.Items.Malediction:OnTearInit(tear, player)
    end
end)

DukeMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, tear)
    DukeMod.Items.Critical:OnEnemyHit(tear)
end, EntityType.ENTITY_TEAR)

local malediction = Isaac.GetItemIdByName("Malediction")
DukeMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectibleType, rng, player)
    DukeMod.Items.Malediction:OnItemUse(player)
end, malediction)


return DukeMod
