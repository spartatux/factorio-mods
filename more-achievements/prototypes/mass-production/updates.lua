local base = "__base__"
local numbers = { "10k", "1M", "20M", "50M", "100M", "250M", "500M", "1G", "20G" }

for i = 1, 3 do
    data.raw["produce-achievement"]["mass-production-" .. i].icon = nil
    data.raw["produce-achievement"]["mass-production-" .. i].icon_size = nil
    data.raw["produce-achievement"]["mass-production-" .. i].icons = {
        {
            icon = base .. "/graphics/achievement/mass-production-" .. i .. ".png",
            icon_size = 128
        },
        {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        }
    }
    data.raw["produce-achievement"]["mass-production-" .. i].quality = "normal"
    data.raw["produce-achievement"]["mass-production-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.mass-production"},
        " " .. i
    }
    data.raw["produce-achievement"]["mass-production-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.electronic-circuit"},
        "."
    }
    data.raw["produce-achievement"]["mass-production-" .. i].order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
end

for i = 4, 9 do
    table.insert(data.raw["produce-achievement"]["mass-production-" .. i].icons, {
        icon = base .. "/graphics/icons/quality-normal.png",
        icon_size = 64,
        scale = 0.1875,
        shift = { 0, 26 }
    })
    data.raw["produce-achievement"]["mass-production-" .. i].quality = "normal"
    data.raw["produce-achievement"]["mass-production-" .. i].localised_name = {
        "",
        "[img=quality/normal]",
        " ",
        {"more-achievements.mass-production"},
        " " .. i
    }
    data.raw["produce-achievement"]["mass-production-" .. i].localised_description = {
        "",
        {"more-achievements.produce"},
        "[img=quality/normal]",
        " ",
        numbers[i],
        " ",
        {"item-name.electronic-circuit"},
        "."
    }
    data.raw["produce-achievement"]["mass-production-" .. i].order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
end
