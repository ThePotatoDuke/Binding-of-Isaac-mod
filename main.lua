-- Register the mod at the start
local ClockMod = RegisterMod("Grandfather's Clock", 1)

-- Use include instead of require to force reload every time
ClockMod.Items = {}
ClockMod.Items.Clock = include("resources-dlc3.scripts.items.Clock")
ClockMod.Items.Key = include("resources-dlc3.scripts.items.Key")
ClockMod.Items.Impact = include("resources-dlc3.scripts.items.Impact")

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
    ClockMod.Items.Impact:scaleTear()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, function(_, tear) -- Fixed argument list
    ClockMod.Items.Impact:tearDeath(tear)                               -- Corrected function call using `:`
end)

return ClockMod
