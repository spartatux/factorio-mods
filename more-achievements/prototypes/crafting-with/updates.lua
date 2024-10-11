local base = "__base__"
local tiers = 3
local modules = { "speed", "efficiency", "productivity" }
local numbers = { "1", "50", "100" }

for i = 1, #modules do
    local module = modules[i]

    data.raw["produce-achievement"]["crafting-with-" .. module].icon = nil
    data.raw["produce-achievement"]["crafting-with-" .. module].icon_size = nil
    data.raw["produce-achievement"]["crafting-with-" .. module].icons = {
        {
            icon = base .. "/graphics/achievement/crafting-with-" .. module .. ".png",
            icon_size = 128
        },
        {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { -10, 10 }
        }
    }
    data.raw["produce-achievement"]["crafting-with-" .. module].quality = "normal"
    data.raw["produce-achievement"]["crafting-with-" .. module].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        { "more-achievements.crafting-with", module }
    }
    data.raw["produce-achievement"]["crafting-with-" .. module].localised_description = {
        "",
        { "more-achievements.craft-a" },
        "[img=quality/normal]",
        " ",
        { "item-name." .. module .. "-module-3" },
        "."
    }
    data.raw["produce-achievement"]["crafting-with-" .. module].order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + i) .. "[" .. module .. "]-a-a[quality]"

    for j = 2, tiers do
        table.insert(data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j].icons, {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { -10, 10 }
        })
        data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j].quality = "normal"
        data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j].localised_name = {
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.crafting-with", module },
            " " .. j
        }
        data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j].localised_description = {
            "",
            { "more-achievements.craft" },
            numbers[j],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name." .. module .. "-module-3" },
            "."
        }
        data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j].order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + i) .. "[" .. module .. "]-" .. string.char(96 + j) .. "-a[quality]"
    end
end
