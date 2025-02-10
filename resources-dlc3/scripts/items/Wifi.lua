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


        if distance < 50 then
            frame = 0
        elseif distance < 100 then
            frame = 1
        elseif distance < 180 then
            frame = 2
        else
            frame = 3
        end

        -- Set the sprite frame and render
        sprite:SetFrame("Connection", frame)
        sprite:Render(pos - Vector(0, 25), Vector.Zero, Vector.Zero)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

function WifiItem:EvaluateCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE then
        local distance = player.Position:Distance(selectedPosition or Vector.Zero)
        if distance < 50 then
            player.Damage = player.Damage * 1.5
        elseif distance < 100 then
            player.Damage = player.Damage * 1.3
        elseif distance < 180 then
            player.Damage = player.Damage * 1.2
        end
    end
end

function WifiItem:GetGridDistance()
    selectedPosition = Isaac.GetRandomPosition()
end

return WifiItem
