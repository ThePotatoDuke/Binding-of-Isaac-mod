local game = Game()
local KeyItem = {}

-- Constants for shoot directions
local SHOOT_DIRECTIONS = {
    [ButtonAction.ACTION_SHOOTLEFT] = "LEFT",
    [ButtonAction.ACTION_SHOOTUP] = "UP",
    [ButtonAction.ACTION_SHOOTRIGHT] = "RIGHT",
    [ButtonAction.ACTION_SHOOTDOWN] = "DOWN"
}

-- Store the last few inputs
local inputHistory = {}

local CIRCLE_SEQUENCE = { "LEFT", "UP", "RIGHT", "DOWN" }

local function getWrappedIndex(index)
    local minIndex = 1
    local maxIndex = #CIRCLE_SEQUENCE

    -- Wrap index if it's lower than the min index or higher than the max index
    -- Ensure positive modulus behavior for negative values
    local wrappedIndex = ((index - minIndex) % (maxIndex - minIndex + 1)) + minIndex

    -- Fix for negative indices, ensuring that the result stays within bounds
    if wrappedIndex < minIndex then
        wrappedIndex = wrappedIndex + (maxIndex - minIndex + 1)
    end

    return wrappedIndex
end

local direction

-- Function to check if input matches a circle pattern (either clockwise or counter-clockwise)
local function isCircling()
    local ctr = 1
    local historyCtr = 1
    local sequenceCtr = 1

    -- Try to align the first input with the start of the circle sequence (CW)
    while historyCtr <= #inputHistory and inputHistory[historyCtr] ~= CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] do
        sequenceCtr = sequenceCtr + 1
        if sequenceCtr > #CIRCLE_SEQUENCE then
            sequenceCtr = 1 -- Wrap back to the start of the CW sequence
        end
    end

    -- Now that the first match is found for both CW and CCW, check the rest of the inputs
    while historyCtr <= #inputHistory do
        local matched = false

        -- Check CW sequence first
        if inputHistory[historyCtr] == CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] and direction ~= "CCW" then
            ctr = ctr + 1
            sequenceCtr = sequenceCtr + 1



            -- If we're moving clockwise and history has more than one input, set direction to CW
            if #inputHistory > 1 then
                direction = "CW"
            end
            matched = true
        end

        -- If not matched in CW, check CCW sequence
        if inputHistory[historyCtr] == CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] and direction ~= "CW" then
            ctr = ctr + 1
            sequenceCtr = sequenceCtr - 1


            -- If we're moving counter-clockwise and history has more than one input, set direction to CCW
            if #inputHistory > 1 then
                direction = "CCW"
            end
            matched = true
        end

        -- If no match in either sequence, reset everything
        if not matched then
            if direction == "CW" then
                direction = "CCW"
            else
                direction = "CW"
            end
            ctr = 1
            sequenceCtr = 1
            historyCtr = 1    -- Restart history check from the beginning
            inputHistory = {} -- Optional: Clear the history if you want to discard previous inputs
            return ctr
        end

        historyCtr = historyCtr + 1 -- Move to the next input in history
    end

    -- Return the greater of the two counters
    return ctr
end



function KeyItem:CheckShootingInputs()
    local player = Isaac.GetPlayer(0)

    for button, direction in pairs(SHOOT_DIRECTIONS) do
        if Input.IsActionTriggered(button, player.ControllerIndex) then
            table.insert(inputHistory, direction)
            print(isCircling())
        end
    end
end

return KeyItem
