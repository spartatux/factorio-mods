script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.surfaces[event.surface_index]
    local planet = game.planets[surface.name]

    if planet then
        local settingsValue = settings.startup["global-network-setting"].value

        if settingsValue == "for-free" then
            if not surface.has_global_electric_network then
                surface.create_global_electric_network()
            end
        elseif settingsValue == "planetary-research" then
            local technologies = game.forces.player.technologies

            if technologies["global-power-network-" .. planet.name] and technologies["global-power-network-" .. planet.name].researched then
                if not surface.has_global_electric_network then
                    surface.create_global_electric_network()
                end
            end
        elseif settingsValue == "endgame-research" then
            local globalPowerNetworkTechnology = game.forces.player.technologies["global-power-network"]

            if globalPowerNetworkTechnology and globalPowerNetworkTechnology.researched then
                if not surface.has_global_electric_network then
                    surface.create_global_electric_network()
                end
            end
        end
    end
end)

script.on_event(defines.events.on_research_finished, function(event)
    local settingsValue = settings.startup["global-network-setting"].value
    local technology = event.research

    if settingsValue == "for-free" then return end
    if settingsValue == "planetary-research" then
        if string.find(technology.name, "global-power-network-") then
            local planet = game.planets[string.gsub(technology.name, "global-power-network-", "")]

            if planet then
                local surface = planet.surface

                if surface then
                    if not surface.has_global_electric_network then
                        surface.create_global_electric_network()
                    end
                end
            end
        end
    elseif settingsValue == "endgame-research" then
        if technology.name == "global-power-network" then

            for _, planet in pairs(game.planets) do
                local surface = planet.surface

                if surface then
                    if not surface.has_global_electric_network then
                        surface.create_global_electric_network()
                    end
                end
            end
        end
    end
end)

script.on_init(function()
    local surface = game.surfaces["nauvis"]

    if surface and settings.startup["global-network-setting"].value == "for-free" then
        surface.create_global_electric_network()
    end
end)