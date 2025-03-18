if EID then
    EID:addCollectible(Isaac.GetItemIdByName("Grandfather's Clock"),
        "{{Timer}} On every in-game timer minute, one of the following effects occurs with an equal chance:# Mama Mega explosion# Enemies freeze for 5 seconds# 1-3 Dead Birds spawn in the room")
    EID:addCollectible(Isaac.GetItemIdByName("Wind-Up Key"),
        "Fire in a circling motion to wind up.#Stopping releases a spiral of tears in the opposite direction.# Pressing the wrong button or leaving the room resets the winding#\1Tear amount increases with tear stat#\2 Tears from the spiral deal 0.8 X Isaac's dmg (multipler can get lower for some synergies)")
    EID:addCollectible(Isaac.GetItemIdByName("Critical Hit"),
        "\2 0.6 range multiplier# Tears get larger right before hitting the ground# \1 If the tear hits an enemy during this time, it deals Isaac's damage x 1.8")
    EID:addCollectible(Isaac.GetItemIdByName("Schizophrenia"),
        "Enemies have a 30% chance to be replaced by hallucinations#{{BossRoom}} Bosses have 15% chance to be replaced# {{Luck}} Not affected by luck# Hallucinations can pass through walls and eachother# Hallucinations can't hurt Isaac# Hallucinations disappear after clearing the room")
    EID:addCollectible(Isaac.GetItemIdByName("Fixed Modem"),
        "A random location is chosen each time isaac enters a room#\1 The closer Isaac gets to that spot, the higher his damage becomes# An indicator above shows how close Isaac is to that spot")
    EID:addCollectible(Isaac.GetItemIdByName("Malediction"),
        "Isaac fires a special tear every 2 tears while holding the item# If these tears hit an enemy, the enemy is marked# Using the item deals damage to the marked enemeis#\1 The damage dealt increases with the number of marked enemies (1.8 x dmg x marked enemy count)")
    EID:addCollectible(Isaac.GetItemIdByName("Dyslexia"),
        "\1 0.8 tears up# \3 External item descriptions are unreadable!")
end
