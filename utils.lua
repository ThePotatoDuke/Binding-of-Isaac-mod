local Utils = {}

-- Define a table of ignored entity types
Utils.IGNORED_ENTITIES = {
    [EntityType.ENTITY_FIREPLACE] = true,
    [EntityType.ENTITY_STONEY] = true,
    [EntityType.ENTITY_BOMB] = true,
    [EntityType.ENTITY_SPIKEBALL] = true,
    [EntityType.ENTITY_POKY] = true,
    [EntityType.ENTITY_WALL_HUGGER] = true,
    [EntityType.ENTITY_MOCKULUS] = true,
    [EntityType.ENTITY_BOMB_GRIMACE] = true,
    [EntityType.ENTITY_QUAKE_GRIMACE] = true,
    [EntityType.ENTITY_BALL_AND_CHAIN] = true,
    [EntityType.ENTITY_GRUDGE] = true,
    [EntityType.ENTITY_DUMMY] = true
}

-- Function to check if an entity should be ignored
function Utils:IsIgnoredEntity(entity)
    return self.IGNORED_ENTITIES[entity.Type] or false
end

return Utils
