local atomicPickaxe = table.deepcopy(data.raw.technology["steel-axe"])

atomicPickaxe.name = "atomic-pickaxe"
atomicPickaxe.icon = "__atomic_pickaxe__/atomic-pickaxe.png"
atomicPickaxe.effects = {{type = "character-mining-speed", modifier = 10}}
atomicPickaxe.prerequisites = {"steel-axe", "uranium-processing"}
atomicPickaxe.unit = {
    count = 500,
    time = 30,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
    }
}
atomicPickaxe.order = "c-c-b"

data:extend{atomicPickaxe}