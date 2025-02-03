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

    -- Save the initial index
    local startSequenceIndex = sequenceCtr
    local startHistoryIndex = historyCtr

    -- Check for CW direction first
    local isCW = true
    historyCtr = startHistoryIndex
    sequenceCtr = startSequenceIndex

    while historyCtr <= #inputHistory do
        if inputHistory[historyCtr] ~= CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] then
            isCW = false
            break
        end
        sequenceCtr = sequenceCtr + 1
        historyCtr = historyCtr + 1
        ctr = ctr + 1
    end

    -- If CW was not detected, check CCW direction
    if not isCW then
        ctr = 1
        historyCtr = startHistoryIndex
        sequenceCtr = startSequenceIndex
        local isCCW = true

        while historyCtr <= #inputHistory do
            if inputHistory[historyCtr] ~= CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] then
                isCCW = false
                break
            end
            sequenceCtr = sequenceCtr - 1
            historyCtr = historyCtr + 1
            ctr = ctr + 1
        end

        if isCCW then
            return ctr
        end
    else
        return ctr
    end

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
    isAutoShooting = true
    if #inputHistory > 0 then
        if autoShootTimer >= shootCooldown then
            autoShootTimer = 0                           -- Reset timer
            local lastInput = table.remove(inputHistory) -- Remove last input
            print(#inputHistory)
            shootBullet(lastInput)                       -- Actually shoot the projectile
        end
    end
    isAutoShooting = false
end


local redTintFactor = 0.1 * isCircling()         -- Adjust the red tint intensity
local greenBlueFactor = 1 - (0.1 * isCircling()) -- Decrease green and blue values to enhance red

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
            print(isCircling()) -- Debugging circle check


            -- Set the color with the capped values


            -- Reset inactivity timer on input
            inactivityTimer = 0
            isAutoShooting = false -- Disable auto-shoot since a key was pressed
        end
    end
    -- Update color values based on circling
    redTintFactor = 0.1 * #inputHistory         -- Adjust the red tint intensity
    greenBlueFactor = 1 - (0.1 * #inputHistory) -- Decrease green and blue values to enhance red

    -- Cap the red, green, and blue components
    red = math.min(0.8902 + redTintFactor, 1) -- Cap red to a maximum of 1
    green = math.max(greenBlueFactor, 0.2)    -- Ensure green is at least 0.2
    blue = math.max(greenBlueFactor, 0.2)     -- Ensure blue is at least 0.2

    player:SetColor(Color(red, green, blue, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)

    -- -- Gradually reset the color back to normal when no input is detected
    -- if colorResetTimer > 0 then
    --     -- Gradually reduce red tint from 1 to 0.8902
    --     local red = math.max(0.8902, redTintFactor * (colorResetTimer / colorResetDuration))

    --     -- Gradually increase green and blue from 0.2 to 0.7765
    --     local green = math.max(1, (colorResetTimer / colorResetDuration) * (0.7765 - 0.2) + 0.2)
    --     local blue = math.max(1, (colorResetTimer / colorResetDuration) * (0.7765 - 0.2) + 0.2)

    --     -- Set the color with the updated values
    --     player:SetColor(Color(red, green, blue, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)

    --     -- Decrease the timer over time
    --     colorResetTimer = colorResetTimer - 1
    -- end

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
