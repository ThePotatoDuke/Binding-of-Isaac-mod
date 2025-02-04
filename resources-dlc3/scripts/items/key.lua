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

-- Variables to handle color reset over time
local colorResetTimer = 0     -- Timer for color reset
local colorResetDuration = 30 -- Duration (frames) for color to reset to normal

local function getWrappedIndex(index)
    local minIndex = 1
    local maxIndex = #CIRCLE_SEQUENCE

    -- Wrap index if it's lower than the min index or higher than the max index
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

local function shootBullet(direction)
    local player = Isaac.GetPlayer(0)
    local position = player.Position -- Get player's current position
    local velocity = Vector(0, 0)    -- Default velocity

    -- Set the player's rotation based on direction
    if direction == "LEFT" then
        velocity = Vector(-10, 0)
        player:SetHeadDirection(Direction.LEFT, 5, true)
    elseif direction == "UP" then
        velocity = Vector(0, -10)
        player:SetHeadDirection(Direction.UP, 5, true)
    elseif direction == "RIGHT" then
        velocity = Vector(10, 0)
        player:SetHeadDirection(Direction.RIGHT, 5, true)
    elseif direction == "DOWN" then
        velocity = Vector(0, 10)
        player:SetHeadDirection(Direction.DOWN, 5, true)
    end

    -- Spawn a tear in the chosen direction
    player:FireTear(position, velocity, false, false, false)


    -- Trigger color reset (gradual)
    colorResetTimer = colorResetDuration
end

local function handleAutoShoot()
    if #inputHistory > 0 then
        if autoShootTimer >= shootCooldown then
            autoShootTimer = 0                           -- Reset timer
            local lastInput = table.remove(inputHistory) -- Remove last input
            shootBullet(lastInput)                       -- Actually shoot the projectile
        end
    else
        isAutoShooting = false
    end
end


local redTintFactor
local greenFactor
local blueFactor

-- Function to check shooting inputs and handle timer reset
function KeyItem:CheckShootingInputs()
    local player = Isaac.GetPlayer(0)

    local inputDetected = false
    local red
    local green
    local blue
    -- Loop through input directions
    for button, direction in pairs(SHOOT_DIRECTIONS) do
        if Input.IsActionTriggered(button, player.ControllerIndex) then
            table.insert(inputHistory, direction)
            inputDetected = true
            inactivityTimer = 0
            isAutoShooting = false -- Disable auto-shoot since a key was pressed
        end
    end
    -- Update color values based on circling
    redTintFactor = 0.1 * #inputHistory          -- Adjust the red tint intensity
    greenFactor = 0.7765 - (0.1 * #inputHistory) -- Decrease green and blue values to enhance red
    blueFactor = 0.7725 - (0.1 * #inputHistory)
    print(#inputHistory)
    -- Cap the red, green, and blue components
    red = math.min(0.8902 + redTintFactor, 1) -- Cap red to a maximum of 1
    green = math.max(greenFactor, 0.2)        -- Ensure green is at least 0.2
    blue = math.max(blueFactor, 0.2)          -- Ensure blue is at least 0.2


    -- If no input was detected, update the inactivity timer
    if not inputDetected then
        inactivityTimer = inactivityTimer + 1
    end

    if inactivityTimer >= 30 then
        if #inputHistory <= 3 then
            red = 0.8902
            green = 0.7765
            blue = 0.7725
        elseif not isAutoShooting then
            isAutoShooting = true
        end
    end

    player:SetColor(Color(red, green, blue, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)

    if isAutoShooting then
        handleAutoShoot()
    end


    -- Increment auto-shoot timer every frame
    autoShootTimer = autoShootTimer + 1
end

return KeyItem
