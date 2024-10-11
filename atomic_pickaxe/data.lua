local atomicPickaxe = table.deepcopy(data.raw.technology["steel-axe"])

atomicPickaxe.name = "atomic-pickaxe"
atomicPickaxe.icon = "__atomic_pickaxe__/atomic-pickaxe.png"
atomicPickaxe.effects = { { type = "character-mining-speed", modifier = 10 } }
atomicPickaxe.prerequisites = { "steel-axe", "uranium-processing" }
atomicPickaxe.research_trigger =
{
    type = "mine-entity",
    entity = "uranium-ore"
}
atomicPickaxe.order = "c-c-b"

data:extend({ atomicPickaxe })
