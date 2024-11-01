local modName = "__captains-log__"
local icons = {
    "waiting",
    "requested",
    "on-the-way",
    "on-the-path",
    "waiting-for-departure",
    "no-schedule",
    "waiting-at-station",
    "pause"
}

data:extend({
    {
        type = "sprite",
        name = "log-button-icon",
        filename = "__captains-log__/graphics/gui-button.png",
        priority = "extra-high-no-scale",
        flags = { "gui-icon" },
        size = 256,
        scale = 0.125
    },
})

for _, icon in pairs(icons) do
    data:extend({
        {
            type = "sprite",
            name = icon .. "-icon",
            filename = modName .. "/graphics/" .. icon .. "-icon.png",
            priority = "medium",
            flags = { "icon" },
            size = 64
        }
    })
end

data.raw["gui-style"].default["captains_log_table"] = {
    type = "table_style",
    odd_row_graphical_set = {
        filename = "__core__/graphics/gui-new.png",
        position = { 472, 25 },
        size = 1
    }
}
