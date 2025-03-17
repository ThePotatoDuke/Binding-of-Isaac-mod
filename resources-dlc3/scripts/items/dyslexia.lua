local DyslexiaItem = {}
DyslexiaItem.ID = Isaac.GetItemIdByName("Dyslexia")
local game = Game()
local MIN_FIRE_DELAY = 5

--
local shuffledDescriptions = {} -- Cache table to store shuffled descriptions

local function modifierCondition(descObj)
    local numPlayers = game:GetNumPlayers()
    for i = 0, numPlayers - 1 do
        local player = Isaac.GetPlayer(i)

        if player:HasCollectible(DyslexiaItem.ID) then
            return true
        end
    end
    return false
end

local function shuffleString(str)
    local chars = {}
    for i = 1, #str do
        local char = str:sub(i, i)
        -- Only add character if it is not a brace or a number
        if char ~= '{' and char ~= '}' and not char:match("%d") then
            table.insert(chars, char) -- Split string into characters, excluding braces and numbers
        end
    end


    -- Fisher-Yates shuffle algorithm
    for i = #chars, 2, -1 do
        local j = math.random(i)
        chars[i], chars[j] = chars[j], chars[i] -- Swap
    end

    return table.concat(chars) -- Reconstruct shuffled string
end

local function modifierCallback(descObj)
    if descObj == nil then
        return
    end
    -- Check if we already shuffled this item's description
    if not shuffledDescriptions[descObj.fullItemString] then
        shuffledDescriptions[descObj.fullItemString] = shuffleString(descObj.Description)
    end
    -- Use the cached shuffled description
    descObj.Description = shuffledDescriptions[descObj.fullItemString]
    return descObj
end

local DYSLEXIA_TEARS = 0.8 -- Lower value for a smaller increase


local function toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end

local function toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

function DyslexiaItem:EvaluateCache(player, cacheFlag)
    if cacheFlag == CacheFlag.CACHE_FIREDELAY then
        if player.MaxFireDelay > MIN_FIRE_DELAY then

        end
        local count = player:GetCollectibleNum(DyslexiaItem.ID)
        local tearsPerSecond = toTearsPerSecond(player.MaxFireDelay)
        tearsPerSecond = tearsPerSecond + (count * DYSLEXIA_TEARS)
        player.MaxFireDelay = toMaxFireDelay(tearsPerSecond)
    end
end

-- Register the modifier with a unique name
EID:addDescriptionModifier("My new Modifier", modifierCondition, modifierCallback)
return DyslexiaItem
