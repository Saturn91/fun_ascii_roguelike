-- Enemy Configuration Array
return {
    goblin = {
        char = "g",
        color = "green",
        health = 3,
        damage = 1,
        name = "Goblin",
        moveChance = 0.3, -- 30% chance to move each turn
        aggroRange = 3    -- Will chase player within 3 tiles
    },
    orc = {
        char = "O",
        color = "brown",
        health = 5,
        damage = 2,
        name = "Orc",
        moveChance = 0.2, -- 20% chance to move each turn
        aggroRange = 4    -- Will chase player within 4 tiles
    },
    skeleton = {
        char = "s",
        color = "light_gray",
        health = 2,
        damage = 1,
        name = "Skeleton",
        moveChance = 0.4, -- 40% chance to move each turn
        aggroRange = 2    -- Will chase player within 2 tiles
    }
}
