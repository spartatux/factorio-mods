local modName = "__molten-tungsten__"
local spaceAge = "__space-age__"
local meld = require("__core__/lualib/meld")
local recipes = data.raw.recipe
local tungstenSteelTechnology = data.raw.technology["tungsten-steel"]
local moreCastingActive = mods["more-casting"]
local itemRaws = {
    "item",
    "item-with-entity-data",
    "rail-planner",
    "repair-tool",
    "ammo",
    "space-platform-starter-pack",
    "capsule",
    "armor",
    "tool"
}

local function makeCastingIcons(otherIcon)
    return {
        {
            icon = otherIcon,
            icon_size = 64,
            scale = 0.40625,
            shift = { 0, 10 },
            draw_background = true
        },
        {
            icon = modName .. "/graphics/molten-tungsten.png",
            icon_size = 64,
            scale = 0.40625,
            shift = { 9.5, -0.6 },
            draw_background = true
        }
    }
end

local function ingredientsMagic(ingredients)
    local moltenTungstenAmount = 0
    local differentFluidAmount = 0
    local toRemove = {}

    if ingredients and #ingredients > 0 then
        for index, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                if ingredient.name == "tungsten-plate" then
                    moltenTungstenAmount = moltenTungstenAmount + (10 * ingredient.amount)

                    toRemove[tostring(index)] = true
                end
            elseif ingredient.type == "fluid" then
                differentFluidAmount = differentFluidAmount + 1
            end
        end

        if differentFluidAmount > 1 then
            moltenTungstenAmount = 0
        else
            for i = #ingredients, 1, -1 do
                if toRemove[tostring(i)] then
                    table.remove(ingredients, i)
                end
            end

            if moltenTungstenAmount > 0 then
                table.insert(ingredients, { type = "fluid", name = "molten-tungsten", amount = moltenTungstenAmount, fluidbox_multiplier = 10 })
            end
        end
    end

    return moltenTungstenAmount, ingredients
end

local function createRecipe(item)
    local recipe = recipes[item.name]

    if recipe then
        if moreCastingActive and recipes["casting-" .. item.name] then
            recipe = recipes["casting-" .. item.name]
        end

        local moltenTungstenAmount, ingredients = ingredientsMagic(table.deepcopy(recipe.ingredients))

        if moltenTungstenAmount > 0 then
            data:extend({
                meld(table.deepcopy(recipe), {
                    name = "casting-tungsten-" .. item.name,
                    icons = item.icon and makeCastingIcons(item.icon) or nil,
                    localised_name = { "molten-tungsten.casting", { "?", { "entity-name." .. item.name }, { "item-name." .. item.name }, {"equipment-name." .. item.name} } },
                    category = "metallurgy",
                    subgroup = "casting-" .. item.subgroup,
                    ingredients = meld.overwrite(ingredients),
                    allow_decomposition = false,
                    enabled = false
                })
            })

            table.insert(tungstenSteelTechnology.effects, {
                type = "unlock-recipe",
                recipe = "casting-tungsten-" .. item.name
            })
        end
    end
end

for _, subGroup in pairs(table.deepcopy(data.raw["item-subgroup"])) do
    data:extend({
        meld(table.deepcopy(subGroup), {
            name = meld.invoke(function(oldName) return "casting-" .. oldName end),
            order = meld.invoke(function(oldOrder) return oldOrder .. "a" end)
        })
    })
end

data:extend({
    meld(table.deepcopy(data.raw.fluid["molten-iron"]), {
        name = "molten-tungsten",
        icon = modName .. "/graphics/molten-tungsten.png",
        order = "b[new-fluid]-b[vulcanus]-c[molten-tungsten]",
        base_color = { 70, 58, 72 },
        flow_color = { 222, 214, 231 },
    }),
    meld(table.deepcopy(recipes["tungsten-plate"]), {
        name = "molten-tungsten",
        order = "c[tungsten]-d[molten-tungsten]",
        results = { { type = "fluid", name = "molten-tungsten", amount = 10 } },
    })
})

table.insert(tungstenSteelTechnology.effects, {
    type = "unlock-recipe",
    recipe = "molten-tungsten"
})

for _, itemRaw in pairs(itemRaws) do
    for _, item in pairs(data.raw[itemRaw]) do
        createRecipe(item)
    end
end
