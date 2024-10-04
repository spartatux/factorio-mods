local base = "__base__"
local tiers = 9
local numbers = { "1.0k", "10k", "25k", "50k", "100k", "250k", "500k", "1M", "5M" }

for i = 1, 3 do
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].icon = nil
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].icon_size = nil
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].icons = {
        {
            icon = base .. "/graphics/achievement/circuit-veteran-" .. i .. ".png",
            icon_size = 128
        },
        {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        }
    }
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        { "more-achievements.circuit-veteran" },
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.advanced-circuit"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].order = "d[production]-c[advanced-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
end

for i = 4, tiers do
    table.insert(data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].icons, {
        icon = base .. "/graphics/icons/quality-normal.png",
        icon_size = 64,
        scale = 0.1875,
        shift = { 0, 26 }
    })
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        { "more-achievements.circuit-veteran" },
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.advanced-circuit"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i].order = "d[production]-c[advanced-circuit-production]-" .. string.char(96 + i) .. "a-[quality]"
end
