local base = "__base__"
local numbers = { "20k", "200k", "400k", "1M", "2.5M", "5M", "10M", "25M", "50M" }

for i = 1, 3 do
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].icon = nil
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].icon_size = nil
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].icons = {
        {
            icon = base .. "/graphics/achievement/iron-throne-" .. i .. ".png",
            icon_size = 128
        },
        {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        }
    }
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.iron-throne"},
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.iron-plate"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].order = "d[production]-e[iron-throne-" .. i .. "]-a[quality]"
end

for i = 4, 9 do
    table.insert(data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].icons, {
        icon = base .. "/graphics/icons/quality-normal.png",
        icon_size = 64,
        scale = 0.1875,
        shift = { 0, 26 }
    })
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].quality = "normal"
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.iron-throne"},
        " " .. i
    }
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.iron-plate"},
        {"more-achievements.per-hour"}
    }
    data.raw["produce-per-hour-achievement"]["iron-throne-" .. i].order = "d[production]-e[iron-throne-" .. i .. "]-a[quality]"
end
