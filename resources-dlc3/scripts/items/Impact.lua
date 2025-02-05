local ImpactItem = {}
ImpactItem.ID = Isaac.GetItemIdByName("Sudden Impact")

-- Table to track tears by their unique identifier
local tears = {}
local lastPosition

function ImpactItem:scaleTear()
    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if entity.Type == EntityType.ENTITY_TEAR then
            local tear = entity:ToTear()
            if tear ~= nil then
                local tearData = tear:GetData()
                local tearExists = false

                -- Check if the tear already exists in the table
                for _, storedTear in ipairs(tears) do
                    if storedTear.tearData == tearData then
                        tearExists = true
                        break
                    end
                end

                -- Insert the tear only if it's new
                if not tearExists then
                    table.insert(tears, { tearData = tearData, isBoosted = false })
                end

                -- Find the stored tear in the list and boost it if conditions are met
                for _, storedTear in ipairs(tears) do
                    if storedTear.tearData == tearData then
                        if tear.Height > -12 and not storedTear.isBoosted then
                            storedTear.isBoosted = true
                            tear.CollisionDamage = tear.CollisionDamage * 1.5
                            tear.Scale = tear.Scale * 1.4
                        end
                        break
                    end
                end
            end
        end
    end
end

function ImpactItem:tearDeath(tear) -- Now it's part of `ImpactItem`
    for _, storedTear in ipairs(tears) do
        if storedTear.tearData == tear:GetData() then
            if storedTear.isBoosted then
                Game():MakeShockwave(tear.Position, 0.035, 0.025, 10)
                break
            end
        end
    end
end

return ImpactItem
