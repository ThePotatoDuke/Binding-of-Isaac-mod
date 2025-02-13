-- Register the mod at the start
local ClockMod = RegisterMod("Grandfather's Clock", 1)
-- Use include instead of require to force reload every time
ClockMod.Items = {
    Clock = include("resources-dlc3.scripts.items.Clock"),
    Key = include("resources-dlc3.scripts.items.Key"),
    Critical = include("resources-dlc3.scripts.items.Critical"),
    Schizophrenia = include("resources-dlc3.scripts.items.Schizophrenia"),
    FixedModem = include("resources-dlc3.scripts.items.FixedModem"),
    Malediction = include("resources-dlc3.scripts.items.Malediction")
}

-- Add callbacks
ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    ClockMod.Items.Schizophrenia:OnUpdate()
    ClockMod.Items.Malediction:OnUpdate()
    ClockMod.Items.Clock:OnUpdate()
    ClockMod.Items.Critical:scaleTear()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    ClockMod.Items.Clock:removeDeadBirds()
    ClockMod.Items.FixedModem:SelectRandomPos()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    ClockMod.Items.Key:CheckShootingInputs()
    ClockMod.Items.FixedModem:OnRender()
end)

ClockMod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider, low)
    ClockMod.Items.Critical:OnEnemyHit(tear, collider, low)
    ClockMod.Items.Malediction:OnEnemyHit(tear, collider, low)
end)

ClockMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    ClockMod.Items.Critical:OnCache(player, cacheFlag)
    ClockMod.Items.FixedModem:EvaluateCache(player, cacheFlag)
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, entity)
    ClockMod.Items.Schizophrenia:OnNpcInit(entity)
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, function(_, entity)
    ClockMod.Items.Schizophrenia:OnProjectileInit(entity)
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, entity)
    ClockMod.Items.Schizophrenia:OnEntityKill(entity)
end)

ClockMod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, function(_, _, _)
    ClockMod.Items.Schizophrenia:OnNewRoom()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
    ClockMod.Items.Critical:OnTearInit(tear)
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function(_, tear)
    ClockMod.Items.Critical:OnTearInit(tear)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
    if player then
        ClockMod.Items.Malediction:OnTearInit(tear, player)
    end
end)

ClockMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, tear)
    ClockMod.Items.Critical:OnEnemyHit(tear)
end, EntityType.ENTITY_TEAR)

local malediction = Isaac.GetItemIdByName("Malediction")
ClockMod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectibleType, rng, player)
    ClockMod.Items.Malediction:OnItemUse(player)
end, malediction)

return ClockMod
