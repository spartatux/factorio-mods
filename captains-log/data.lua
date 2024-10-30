data:extend({
    {
        type = "sprite",
        name = "log-button-icon",
        filename = "__captains-log__/graphics/gui-button.png",
        priority = "extra-high-no-scale",
        size = 256,
        scale = 0.125
    }
})

data.raw["gui-style"].default["captains_log_table"] = {
    type = "table_style",
    odd_row_graphical_set = {
        filename = "__core__/graphics/gui-new.png",
        position = {472, 25},
        size = 1
    }
}