-- Malediction item logic

local Malediction = {}

-- Item ID (make sure to set the correct name)
Malediction.ID = Isaac.GetItemIdByName("Malediction")

-- Track the number of tears shot
Malediction.TearCount = {}

-- Function to handle tear firing
function Malediction:OnTearInit(tear, player)
    if player and player:GetActiveItem() == Malediction.ID then
        local playerIndex = GetPlayerIndex(player) -- Function to track multiple players

        if not Malediction.TearCount[playerIndex] then
            Malediction.TearCount[playerIndex] = 0
        end

        Malediction.TearCount[playerIndex] = Malediction.TearCount[playerIndex] + 1
        print(Malediction.TearCount[playerIndex])

        -- Every 3rd tear, apply a special effect
        if Malediction.TearCount[playerIndex] >= 3 then
            print("inside")
            Malediction.TearCount[playerIndex] = 0 -- Reset counter
            Malediction:ApplySpecialTearEffect(tear)
        end
    end
end

function Malediction:ApplySpecialTearEffect(tear)
    tear.Scale = 1.6
    tear.Color = Color(0.5, 0, 0.5, 1, 0, 0, 0) -- Dark purple color

    print("Old tear flags:", tear.TearFlags)
    tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING | TearFlags.TEAR_SPECTRAL
    print("New tear flags:", tear.TearFlags)
end

-- Helper function to track players separately
function GetPlayerIndex(player)
    local id = player.ControllerIndex or 1
    return id
end

return Malediction
