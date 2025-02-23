local KeyItem = {}
KeyItem.ID = Isaac.GetItemIdByName("Wind-Up Key")
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
    local wrappedIndex = ((index - minIndex) % (maxIndex - minIndex + 1)) + minIndex

    -- Fix for negative indices, ensuring that the result stays within bounds
    if wrappedIndex < minIndex then
        wrappedIndex = wrappedIndex + (maxIndex - minIndex + 1)
    end

    return wrappedIndex
end
local circleDirection

local function circlingCounter()
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
        if inputHistory[historyCtr] == CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] and circleDirection ~= "CCW" then
            ctr = ctr + 1
            sequenceCtr = sequenceCtr + 1
            -- If we're moving clockwise and history has more than one input, set direction to CW
            if #inputHistory > 1 then
                circleDirection = "CW"
            end
            matched = true
        end

        -- If not matched in CW, check CCW sequence
        if inputHistory[historyCtr] == CIRCLE_SEQUENCE[getWrappedIndex(sequenceCtr)] and circleDirection ~= "CW" then
            ctr = ctr + 1
            sequenceCtr = sequenceCtr - 1


            -- If we're moving counter-clockwise and history has more than one input, set direction to CCW
            if #inputHistory > 1 then
                circleDirection = "CCW"
            end
            matched = true
        end

        -- If no match in either sequence, reset everything
        if not matched then
            if circleDirection == "CW" then
                circleDirection = "CCW"
            else
                circleDirection = "CW"
            end
            ctr = 1
            sequenceCtr = 1
            historyCtr = 1    -- Restart history check from the beginning
            inputHistory = {} -- Optional: Clear the history if you want to discard previous inputs
        end

        historyCtr = historyCtr + 1 -- Move to the next input in history
    end
end

local autoShootTimer = 0 -- Timer for controlling shot intervals
local shootCooldown = 3  -- Number of frames between each shot
local isAutoShooting = false



local spiralIndex = 1  -- Track the current step in the spiral
local spiralSpeed = 10 -- Speed of each tear
local numSteps = 8     -- Total steps before resetting (controls how many tears make a full loop)


local function shootBullet(shootDirection)
    local player = Isaac.GetPlayer(0)
    local position = player.Position
    local maxFireDelay = player.MaxFireDelay -- Get player's Tears stat

    -- Set head direction based on shootDirection
    if shootDirection == "LEFT" then
        player:SetHeadDirection(Direction.LEFT, 5, true)
    elseif shootDirection == "UP" then
        player:SetHeadDirection(Direction.UP, 5, true)
    elseif shootDirection == "RIGHT" then
        player:SetHeadDirection(Direction.RIGHT, 5, true)
    elseif shootDirection == "DOWN" then
        player:SetHeadDirection(Direction.DOWN, 5, true)
    end

    local directionMultiplier = 1
    if circleDirection == "CW" then
        directionMultiplier = -directionMultiplier
    end

    -- Spiral logic: Calculate offset angle
    local angle = math.rad(spiralIndex * (directionMultiplier * 360 / numSteps))
    local spiralOffset = Vector(math.cos(angle) * spiralSpeed, math.sin(angle) * spiralSpeed)

    -- Combine base direction with spiral movement
    local finalVelocity = spiralOffset
    local baseVelocity = finalVelocity
    local spreadAngle = 30 -- Spread angle in degrees


    -- Determine the number of tears based on the player's Tears stat

    local tearCount = 1
    if maxFireDelay <= 6 then
        tearCount = 3
    elseif maxFireDelay <= 8 then
        tearCount = 2
    elseif maxFireDelay <= 10 then
        tearCount = 1
    end

    print(tearCount)

    -- Adjust shooting pattern based on tear count
    local startOffset = (tearCount - 1) / 2         -- Ensures correct offsets
    for i = -startOffset, startOffset do
        if tearCount == 1 and i ~= 0 then break end -- Only shoot 1 tear if tearCount is 1

        -- Rotate the base velocity slightly for each tear
        local angleOffset = i * spreadAngle
        local newVelocity = Vector.FromAngle(baseVelocity:GetAngleDegrees() + angleOffset) * baseVelocity:Length()

        if player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
            player:FireTechXLaser(player.Position, newVelocity, 15, player, 0.5)
            -- adjust size and other properties as needed
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            player:FireBrimstone(newVelocity, player, 0.5)
        else
            -- Fire the tear
            local tear = player:FireTear(position, newVelocity, false, false, false)
            -- Customize tear behavior
            tear.CollisionDamage = player.Damage * 0.8
            tear.FallingSpeed = -3
            tear.FallingAcceleration = 0.5
        end
    end

    -- Increment spiral index for the next shot
    spiralIndex = spiralIndex + 1
    if spiralIndex > numSteps then
        spiralIndex = 1
    end
end

function KeyItem:OnNewRoom()
    inputHistory = {}
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

    if player:HasCollectible(KeyItem.ID) then
        local inputDetected = false
        local red
        local green
        local blue

        -- Loop through input directions
        for button, direction in pairs(SHOOT_DIRECTIONS) do
            if Input.IsActionTriggered(button, player.ControllerIndex) and not Game():IsPauseMenuOpen() then
                table.insert(inputHistory, direction)
                circlingCounter()
                inputDetected = true
                inactivityTimer = 0
                isAutoShooting = false -- Disable auto-shoot since a key was pressed
            end
        end
        -- Update color values based on circling
        redTintFactor = 0.1 * #inputHistory     -- Adjust the red tint intensity
        greenFactor = 1 - (0.1 * #inputHistory) -- Decrease green and blue values to enhance red
        blueFactor = 1 - (0.1 * #inputHistory)
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
                inputHistory = {}
                red = 1
                green = 1
                blue = 1
            elseif not isAutoShooting then
                if not (Input.IsActionPressed(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_RIGHT, player.ControllerIndex) or Input.IsActionPressed(ButtonAction.ACTION_UP, player.ControllerIndex)) then
                    isAutoShooting = true
                end
            end
        end

        player:SetColor(Color(red, green, blue, 1.0, 0.0, 0.0, 0.0), 0, 0, false, false)

        if isAutoShooting then
            handleAutoShoot()
            player.FireDelay = player.MaxFireDelay
        end

        -- Increment auto-shoot timer every frame
        autoShootTimer = autoShootTimer + 1
    end
end

return KeyItem
