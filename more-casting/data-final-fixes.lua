local modName = "__more-casting__"
local spaceAge = "__space-age__"
local meld = require("__core__/lualib/meld")
local util = require("util")
local recipes = data.raw.recipe
local foundryTechnology = data.raw.technology["foundry"]
local defaultIconSizeDefine = defines.default_icon_size
local banList = {
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    ["iron-plate"] = true,
    ["copper-plate"] = true,
    ["steel-plate"] = true,
    ["iron-gear-wheel"] = true,
    ["iron-stick"] = true,
    ["low-density-structure"] = true,
    ["concrete"] = true,
    ["copper-cable"] = true
}
local castingIngredients = {
    moltenIron = {
        ["iron-plate"] = 10,      --10, 5
        ["steel-plate"] = 30,     --30, 20
        ["iron-gear-wheel"] = 30, --10, 5
        ["iron-stick"] = 5,       --5, 2.5
        ["pipe"] = 10             --10, 5
    },
    moltenCopper = {
        ["copper-plate"] = 10, --10, 5
        ["copper-cable"] = 2.5 --2.5, 1.25
    }
}
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
local function makeCastingIcons(item, fluids)
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

    if fluids.moltenIronAmount > 0 and fluids.moltenCopperAmount > 0 then
        local first = fluids.moltenIronAmount >= fluids.moltenCopperAmount

        icons[#icons + 1] = {
            icon = spaceAge .. "/graphics/icons/fluid/molten-" .. (first and "copper" or "iron") .. ".png",
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.59375,
            shift = { 10 / 2, -1 / 2 },
            draw_background = true
        }

        icons[#icons + 1] = {
            icon = spaceAge .. "/graphics/icons/fluid/molten-" .. (first and "iron" or "copper") .. ".png",
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.65625,
            shift = { 27 / 2, -1 / 2 },
            draw_background = true
        }
    elseif fluids.moltenIronAmount > 0 then
        icons[#icons + 1] = {
            icon = spaceAge .. "/graphics/icons/fluid/molten-iron.png",
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.8125,
            shift = { 19 / 2, -2 / 2 },
            draw_background = true
        }
    else
        icons[#icons + 1] = {
            icon = spaceAge .. "/graphics/icons/fluid/molten-copper.png",
            icon_size = 64,
            scale = (0.5 * defines.default_icon_size / 64) * 0.8125,
            shift = { 19 / 2, -2 / 2 },
            draw_background = true
        }
    end

    return icons
end

local function ingredientsMagic(ingredients)
    local moltenIronIngredients = 0
    local moltenCopperIngredients = 0
    local moltenIronAmount = 0
    local moltenCopperAmount = 0
    local hasFluid = false
    local toRemove = {}

    if ingredients and #ingredients > 0 then
        for index, ingredient in pairs(ingredients) do
            if ingredient.type == "item" then
                local moltenIronAmountC = castingIngredients.moltenIron[ingredient.name]
                local moltenCopperAmountC = castingIngredients.moltenCopper[ingredient.name]

                if moltenIronAmountC then
                    moltenIronIngredients = moltenIronIngredients + 1
                    moltenIronAmount = moltenIronAmount + (moltenIronAmountC * ingredient.amount)

                    toRemove[tostring(index)] = true
                elseif moltenCopperAmountC then
                    moltenCopperIngredients = moltenCopperIngredients + 1
                    moltenCopperAmount = moltenCopperAmount + (moltenCopperAmountC * ingredient.amount)

                    toRemove[tostring(index)] = true
                end
            elseif ingredient.type == "fluid" then
                hasFluid = true
            end
        end

        if hasFluid and moltenIronAmount > 0 and moltenCopperAmount > 0 then
            moltenIronAmount = 0
            moltenCopperAmount = 0
        else
            for i = #ingredients, 1, -1 do
                if toRemove[tostring(i)] then
                    table.remove(ingredients, i)
                end
            end

            if moltenIronAmount > 0 then
                table.insert(ingredients, { type = "fluid", name = "molten-iron", amount = moltenIronAmount * (1 - (moltenIronIngredients / 10)), fluidbox_multiplier = 10 })
            end

            if moltenCopperAmount > 0 then
                table.insert(ingredients, { type = "fluid", name = "molten-copper", amount = moltenCopperAmount * (1 - (moltenCopperIngredients / 10)), fluidbox_multiplier = 10 })
            end
        end
    end

    return moltenIronAmount, moltenCopperAmount, ingredients
end

local function createRecipe(item)
    if not banList[item.name] then
        local recipe = recipes[item.name]

        if recipe then
            local moltenIronAmount, moltenCopperAmount, ingredients = ingredientsMagic(table.deepcopy(recipe.ingredients))

            if moltenIronAmount > 0 or moltenCopperAmount > 0 then
                data:extend({
                    meld(table.deepcopy(recipe), {
                        name = "casting-" .. item.name,
                        icons = makeCastingIcons(item, { moltenIronAmount = moltenIronAmount, moltenCopperAmount = moltenCopperAmount }),
                        localised_name = { "more-casting.casting", { "?", { "entity-name." .. item.name }, { "item-name." .. item.name }, { "equipment-name." .. item.name } } },
                        category = "metallurgy",
                        subgroup = "casting-" .. item.subgroup,
                        ingredients = meld.overwrite(ingredients),
                        allow_decomposition = false,
                        enabled = false
                    })
                })

                table.insert(foundryTechnology.effects, {
                    type = "unlock-recipe",
                    recipe = "casting-" .. item.name
                })
            end
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
