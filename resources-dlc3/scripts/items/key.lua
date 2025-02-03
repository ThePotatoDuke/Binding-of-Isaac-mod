local game             = Game()
local KeyItem          = {}

-- Constants for shoot directions
local SHOOT_DIRECTIONS = {
    [ButtonAction.ACTION_SHOOTLEFT] = "LEFT",
    [ButtonAction.ACTION_SHOOTUP] = "UP",
    [ButtonAction.ACTION_SHOOTRIGHT] = "RIGHT",
    [ButtonAction.ACTION_SHOOTDOWN] = "DOWN"
}

-- Store the last few inputs
local inputHistory     = {}



local CIRCLE_SEQUENCE_CW  = { "LEFT", "UP", "RIGHT", "DOWN" }
local CIRCLE_SEQUENCE_CCW = { "LEFT", "DOWN", "RIGHT", "UP" }

-- Function to check if input matches a circle pattern (either clockwise or counter-clockwise)
local function isCircling()
    local ctrCW = 0  -- Counter for clockwise sequence
    local ctrCCW = 0 -- Counter for counter-clockwise sequence

    local historyCtr = 1
    local sequenceCtrCW = 1
    local sequenceCtrCCW = 1

    -- Try to align the first input with the start of the circle sequence (CW)
    while historyCtr <= #inputHistory and inputHistory[historyCtr] ~= CIRCLE_SEQUENCE_CW[sequenceCtrCW] do
        sequenceCtrCW = sequenceCtrCW + 1
        if sequenceCtrCW > #CIRCLE_SEQUENCE_CW then
            sequenceCtrCW = 1 -- Wrap back to the start of the CW sequence
        end
    end

    -- Try to align the first input with the start of the circle sequence (CCW)
    while historyCtr <= #inputHistory and inputHistory[historyCtr] ~= CIRCLE_SEQUENCE_CCW[sequenceCtrCCW] do
        sequenceCtrCCW = sequenceCtrCCW + 1
        if sequenceCtrCCW > #CIRCLE_SEQUENCE_CCW then
            sequenceCtrCCW = 1 -- Wrap back to the start of the CCW sequence
        end
    end

    local cw = false
    -- Now that the first match is found for both CW and CCW, check the rest of the inputs
    while historyCtr <= #inputHistory do
        local matched = false

        -- Check CW sequence first
        if inputHistory[historyCtr] == CIRCLE_SEQUENCE_CW[sequenceCtrCW] then
            ctrCW = ctrCW + 1
            sequenceCtrCW = sequenceCtrCW + 1
            if sequenceCtrCW > #CIRCLE_SEQUENCE_CW then
                sequenceCtrCW = 1 -- Wrap back to the start of the CW sequence
            end
            ctrCCW = 0

            if #inputHistory > 1 then
                cw = true
            end
            matched = true
        end

        -- If not matched in CW, check CCW sequence
        if not cw and inputHistory[historyCtr] == CIRCLE_SEQUENCE_CCW[sequenceCtrCCW] then
            ctrCCW = ctrCCW + 1
            sequenceCtrCCW = sequenceCtrCCW + 1
            if sequenceCtrCCW > #CIRCLE_SEQUENCE_CCW then
                sequenceCtrCCW = 1 -- Wrap back to the start of the CCW sequence
            end
            ctrCW = 0
            matched = true
        end

        -- If no match in either sequence, reset everything
        if not matched then
            cw = false
            ctrCW = 0
            ctrCCW = 0
            sequenceCtrCW = 1
            sequenceCtrCCW = 1
            historyCtr = 1    -- Restart history check from the beginning
            inputHistory = {} -- Optional: Clear the history if you want to discard previous inputs
            return 0
        end

        historyCtr = historyCtr + 1 -- Move to the next input in history
    end

    -- Return the greater of the two counters
    return math.max(ctrCW, ctrCCW)
end





function KeyItem:CheckShootingInputs()
    local player = Isaac.GetPlayer(0)

    -- Loop through shoot buttons and check if they're pressed
    for button, direction in pairs(SHOOT_DIRECTIONS) do
        if Input.IsActionTriggered(button, player.ControllerIndex) then
            -- Add direction to history
            table.insert(inputHistory, direction)

            -- -- Keep history size limited
            -- if #inputHistory > maxHistory then
            --     table.remove(inputHistory, 1)
            -- end

            -- Check for full circle
            print("hiiii")
            -- Print the input history
        end
    end
end

return KeyItem
