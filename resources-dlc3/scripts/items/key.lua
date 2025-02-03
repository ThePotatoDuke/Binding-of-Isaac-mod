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
local inactivityTimer = 0 -- Timer for inactivity

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

local autoShootTimer = 0 -- Timer for controlling shot intervals
local shootCooldown = 10 -- Number of frames between each shot
local isAutoShooting = false

local function handleAutoShoot()
    isAutoShooting = true
    if #inputHistory > 0 then
        if autoShootTimer >= shootCooldown then
            autoShootTimer = 0                           -- Reset timer
            local lastInput = table.remove(inputHistory) -- Pops the last element
            print("Auto-shooting in direction: " .. lastInput)
            -- Example shooting logic:
            -- shootBullet(lastInput)
        end
    end
end

-- Function to check shooting inputs and handle timer reset
function KeyItem:CheckShootingInputs()
    local player = Isaac.GetPlayer(0)

    local inputDetected = false

    -- Loop through input directions
    for button, direction in pairs(SHOOT_DIRECTIONS) do
        if Input.IsActionTriggered(button, player.ControllerIndex) then
            table.insert(inputHistory, direction)
            inputDetected = true
            print(isCircling())
            local redTintFactor = 0.1 * isCircling()              -- Adjust the red tint intensity
            local greenBlueFactor = 0.7765 - (0.1 * isCircling()) -- Decrease green and blue values to enhance red

            -- Cap the red, green, and blue components
            local red = math.min(0.8902 + redTintFactor, 1) -- Cap red to a maximum of 1
            local green = math.max(greenBlueFactor, 0.2)    -- Ensure green is at least 0
            local blue = math.max(greenBlueFactor, 0.2)     -- Ensure blue is at least 0

            -- Set the color with the capped values
            player:SetColor(Color(red, green, blue, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)

            -- Reset inactivity timer on input
            inactivityTimer = 0
            isAutoShooting = false -- Disable auto-shoot since a key was pressed
        end
    end

    -- If no input was detected, update the inactivity timer
    if not inputDetected then
        inactivityTimer = inactivityTimer + 1
    end

    -- If inactivity timer has expired and auto-shoot is not already running, start auto-shooting
    if inactivityTimer >= 30 then -- Set duration for inactivity (30 frames = 0.5 second)
        handleAutoShoot()
    end

    -- Increment auto-shoot timer every frame
    autoShootTimer = autoShootTimer + 1
end

return KeyItem
