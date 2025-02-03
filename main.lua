-- Register the mod at the start
local ClockMod = RegisterMod("Grandfather's Clock", 1)

-- Load items
ClockMod.Items = {}
ClockMod.Items.Clock = require("resources-dlc3.scripts.items.clock")

ClockMod.Items.Key = require("resources-dlc3.scripts.items.key")

-- Add callbacks or logic below after ClockMod is defined
ClockMod:AddCallback(ModCallbacks.MC_POST_UPDATE, function()
    ClockMod.Items.Clock:OnUpdate()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    ClockMod.Items.Clock:removeDeadBirds()
end)

ClockMod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    ClockMod.Items.Key:CheckShootingInputs()
end)

return ClockMod
