local modName = "__molten-tungsten__"
local spaceAge = "__space-age__"
local meld = require("__core__/lualib/meld")
local recipes = data.raw.recipe
local tungstenSteelTechnology = data.raw.technology["tungsten-steel"]
local defaultIconSizeDefine = defines.default_icon_size
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

-- 0.8125 for a single molten fluid = 52px at shift 19/-2
-- 0.65625 for a double molten fluid, top fluid = 42px at shift 27/-1
-- 0.59375 for a double molten fluid, lower fluid = 38px at shift 10/-1
-- base graphic is also scaled to 52px and shifted to 0/20
local function makeCastingIcons(item, tungstenAmount, otherFluid)
    local icons = {
        {
            icon = modName .. "/graphics/64x64-empty.png"
        }
    }

    if item.icons == nil then
        icons[#icons + 1] = {
            icon = item.icon,
            icon_size = item.icon_size,
            scale = (0.5 * defaultIconSizeDefine / (item.icon_size or defaultIconSizeDefine)) * 0.8125,
            shift = { 0, 20 / 2 },
            draw_background = true
        }
    else
        for i = 1, #item.icons do
            local icon = table.deepcopy(item.icons[i])

            icon.scale = ((icon.scale == nil) and (0.5 * defaultIconSizeDefine / (icon.icon_size or defaultIconSizeDefine)) or icon.scale) * 0.8125
            icon.shift = util.mul_shift(icon.shift, 0.8125)

            if icon.shift then
                icon.shift = { icon.shift[1], icon.shift[2] + (20 / 2) }
            else
                icon.shift = { 0, 20 / 2 }
            end

            icons[#icons + 1] = icon
        end
    end

    if otherFluid and otherFluid.amount > 0 then
        log(serpent.block(otherFluid))

        local first = tungstenAmount >= otherFluid.amount
        local graphics = {
            copper = spaceAge .. "/graphics/icons/fluid/molten-copper.png",
            iron = spaceAge .. "/graphics/icons/fluid/molten-iron.png",
            tungsten = modName .. "/graphics/molten-tungsten.png",
        }

        icons[#icons + 1] = {
            icon = graphics[first and otherFluid.name or "tungsten"],
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.59375,
            shift = { 10 / 2, -1 / 2 },
            draw_background = true
        }

        icons[#icons + 1] = {
            icon = graphics[first and "tungsten" or otherFluid.name],
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.65625,
            shift = { 27 / 2, -1 / 2 },
            draw_background = true
        }
    else
        icons[#icons + 1] = {
            icon = modName .. "/graphics/molten-tungsten.png",
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.8125,
            shift = { 19 / 2, -2 / 2 },
            draw_background = true
        }
    end

    return icons
end

local function ingredientsMagic(ingredients)
    local moltenTungstenIngredients = 0
    local moltenTungstenAmount = 0
    local otherFluid = { name = "", amount = 0 }
    local differentFluidAmount = 0
    local toRemove = {}

    if ingredients and #ingredients > 0 then
        for index, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                if ingredient.name == "tungsten-plate" then
                    moltenTungstenIngredients = moltenTungstenIngredients + 1
                    moltenTungstenAmount = moltenTungstenAmount + (10 * ingredient.amount)

                    toRemove[tostring(index)] = true
                end
            elseif ingredient.type == "fluid" then
                if ingredient.name == "molten-iron" then
                    otherFluid = { name = "iron", amount = ingredient.amount }
                end

                if ingredient.name == "molten-copper" then
                    otherFluid = { name = "copper", amount = ingredient.amount }
                end

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
                table.insert(ingredients, { type = "fluid", name = "molten-tungsten", amount = moltenTungstenAmount * (1 - (moltenTungstenIngredients / 10)), fluidbox_multiplier = 10 })
            end
        end
    end

    return moltenTungstenAmount, otherFluid, ingredients
end

local function createRecipe(item)
    local recipe = recipes[item.name]

    if recipe then
        if moreCastingActive and recipes["casting-" .. item.name] then
            recipe = recipes["casting-" .. item.name]
        end

        local moltenTungstenAmount, otherFluid, ingredients = ingredientsMagic(table.deepcopy(recipe.ingredients))

        if moltenTungstenAmount > 0 then
            data:extend({
                meld(table.deepcopy(recipe), {
                    name = "casting-tungsten-" .. item.name,
                    icons = makeCastingIcons(item, moltenTungstenAmount, otherFluid),
                    localised_name = { "molten-tungsten.casting", { "?", { "entity-name." .. item.name }, { "item-name." .. item.name }, { "equipment-name." .. item.name } } },
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
            order = meld.invoke(function(oldOrder) return (oldOrder or "") .. "a" end)
        })
    })
end

for _, itemRaw in pairs(itemRaws) do
    for _, item in pairs(data.raw[itemRaw]) do
        createRecipe(item)
    end
end
