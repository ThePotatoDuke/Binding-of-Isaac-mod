local FixedModemItem = {}
local selectedPosition
FixedModemItem.ID = Isaac.GetItemIdByName("Fixed Modem")
local sprite = Sprite()
sprite:Load("gfx/ui/ConnectionBars.anm2", true)
function FixedModemItem:OnRender()
    for i = 0, Game():GetNumPlayers() - 1 do
        local player = Isaac.GetPlayer(i)
        if player:HasCollectible(FixedModemItem.ID) then
            local pos = Isaac.WorldToScreen(player.Position)
            if selectedPosition ~= nil then
                local distance = player.Position:Distance(selectedPosition)
                local frame
                if distance < 60 then
                    frame = 0
                elseif distance < 110 then
                    frame = 1
                elseif distance < 180 then
                    frame = 2
                else
                    frame = 3
                end
                sprite:SetFrame("Connection", frame)
                sprite:Render(pos - Vector(0, 25), Vector.Zero, Vector.Zero)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
            end
        end
    end
end

function FixedModemItem:EvaluateCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_DAMAGE and player:HasCollectible(FixedModemItem.ID) then
        local distance = player.Position:Distance(selectedPosition or Vector.Zero)
        if distance < 50 then
            player.Damage = player.Damage * 1.7
        elseif distance < 100 then
            player.Damage = player.Damage * 1.3
        elseif distance < 170 then
            player.Damage = player.Damage * 1.2
        end
    end
end

function FixedModemItem:GetGridDistance()
    selectedPosition = Isaac.GetRandomPosition()
end

return FixedModemItem
