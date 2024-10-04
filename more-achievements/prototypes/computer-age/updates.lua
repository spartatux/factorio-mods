local base = "__base__"
local numbers = { "500", "1.0k", "5k", "10k", "25k", "50k", "100k", "250k", "500k" }

for i = 1, 3 do
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].icon = nil
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].icon_size = nil
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].icons = {
        {
            icon = base .. "/graphics/achievement/computer-age-" .. i .. ".png",
            icon_size = 128
        },
        {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        }
    }
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.computer-age"},
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.processing-unit"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i) .. "-a[quality]"
end

for i = 4, 9 do
    table.insert(data.raw["produce-per-hour-achievement"]["computer-age-" .. i].icons, {
        icon = base .. "/graphics/icons/quality-normal.png",
        icon_size = 64,
        scale = 0.1875,
        shift = { 0, 26 }
    })
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.computer-age"},
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.processing-unit"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["computer-age-" .. i].order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i) .. "-a[quality]"
end
