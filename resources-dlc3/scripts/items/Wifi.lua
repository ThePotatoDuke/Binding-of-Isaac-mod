local WifiItem = {}
local selectedPosition

local sprite = Sprite()
sprite:Load("gfx/ui/ConnectionBars.anm2", true)
function WifiItem:OnRender()
    local player = Isaac.GetPlayer(0)
    local pos = Isaac.WorldToScreen(player.Position)
    if selectedPosition ~= nil then
        local distance = player.Position:Distance(selectedPosition)
        local frame


        if distance < 40 then
            frame = 0
        elseif distance < 90 then
            frame = 1
        else
            frame = 2
        end

        -- Set the sprite frame and render
        sprite:SetFrame("Connection", frame)
        sprite:Render(pos - Vector(0, 25), Vector.Zero, Vector.Zero)
    end
end

function WifiItem:GetGridDistance()
    selectedPosition = Isaac.GetRandomPosition()
end

return WifiItem
