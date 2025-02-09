-- Register the mod at the start
local ClockMod = RegisterMod("Grandfather's Clock", 1)

-- Use include instead of require to force reload every time
ClockMod.Items = {}
ClockMod.Items.Clock = include("resources-dlc3.scripts.items.Clock")
ClockMod.Items.Key = include("resources-dlc3.scripts.items.Key")
ClockMod.Items.Critical = include("resources-dlc3.scripts.items.Critical")
ClockMod.Items.Schizophrenia = include("resources-dlc3.scripts.items.Schizophrenia")




-- Add callbacks
ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    ClockMod.Items.Clock:OnUpdate()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    ClockMod.Items.Clock:removeDeadBirds()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    ClockMod.Items.Key:CheckShootingInputs()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    ClockMod.Items.Critical:scaleTear()
end)

ClockMod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, tear, collider, low)
    -- Fixed argument list
    ClockMod.Items.Critical:OnEnemyHit(tear, collider, low) -- Corrected function call using `:`
end)
ClockMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player, cacheFlag)
    ClockMod.Items.Critical:onCache(player, cacheFlag)
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
ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function(_, entity)
    ClockMod.Items.Schizophrenia:OnUpdate(entity)
end)
ClockMod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, function()
    ClockMod.Items.Schizophrenia:OnNewRoom()
end)

return ClockMod
