local logGui = require("__captains-log__/scripts/gui")
local spacePlatformStateDefine = defines.space_platform_state
local eventsDefine = defines.events
local eventsLib = {}

local function initPlayer(player)
    local playerIndexString = tostring(player.index)
    local forceIndexString = tostring(player.force_index)

    if not storage.players[playerIndexString] then
        storage.players[playerIndexString] = {
            selectedIndex = 1,
            guis = {}
        }

        if #storage.platforms[forceIndexString] > 0 then
            logGui.buildGuiButton(storage.players[playerIndexString], player)
        end
    end
end

local function initStorage()
    storage.players = storage.players or {}
    storage.platforms = storage.platforms or {}
    storage.platformsList = storage.platformsList or {}
    storage.platformsListDisplay = storage.platformsListDisplay or {}

    for _, force in pairs(game.forces) do
        local forceIndexString = tostring(force.index)

        storage.platforms[forceIndexString] = storage.platforms[forceIndexString] or {}
        storage.platformsList[forceIndexString] = storage.platformsList[forceIndexString] or {}
        storage.platformsListDisplay[forceIndexString] = storage.platformsListDisplay[forceIndexString] or {}

        for _, platform in pairs(force.platforms) do
            local platformIndexString = tostring(platform.index)

            storage.platforms[forceIndexString][platformIndexString] = {
                name = platform.name,
                index = #storage.platformsList[forceIndexString] + 1,
                leaveTick = 0,
                arriveTick = 0,
                platform = platform,
                entries = {}
            }

            table.insert(storage.platformsList[forceIndexString], platformIndexString)
            table.insert(storage.platformsListDisplay[forceIndexString], platform.name)
        end
    end
end

eventsLib.events = {
    [eventsDefine.on_player_created] = function(event)
        initPlayer(game.players[event.player_index])
    end,
    [eventsDefine.on_player_removed] = function(event)
        if storage.players then
            storage.players[tostring(event.player_index)] = nil
        end
    end,
    [eventsDefine.on_space_platform_changed_state] = function(event)
        local platform = event.platform
        local platformForce = platform.force
        local platformState = platform.state
        local spaceLocation = platform.space_location
        local forceIndexString = tostring(platformForce.index)
        local platformIndexString = tostring(platform.index)
        local gameTick = game.tick

        if platformState == spacePlatformStateDefine.paused then
            if event.old_state ~= spacePlatformStateDefine.on_the_path or event.old_state ~= spacePlatformStateDefine.on_the_path then
                local firstPlatform = #storage.platformsList[forceIndexString] == 0

                storage.platforms[forceIndexString][platformIndexString] = {
                    name = platform.name,
                    index = #storage.platformsList[forceIndexString] + 1,
                    leaveTick = 0,
                    arriveTick = gameTick,
                    platform = platform,
                    entries = {
                        {
                            leavePlanet = spaceLocation.name,
                            startWaitingTick = gameTick,
                            arriveTick = 0,
                            leaveTick = 0
                        }
                    }
                }

                table.insert(storage.platformsList[forceIndexString], platformIndexString)
                table.insert(storage.platformsListDisplay[forceIndexString], platform.name)

                for _, player in pairs(platformForce.players) do
                    local playerIndexString = tostring(player.index)
                    local globalPlayerGuis = storage.players[playerIndexString].guis

                    if firstPlatform then
                        logGui.buildGuiButton(storage.players[playerIndexString], player)
                    end

                    if globalPlayerGuis.logGuiPlatformListBox and globalPlayerGuis.logGuiPlatformListBox.valid then
                        globalPlayerGuis.logGuiPlatformListBox.items = storage.platformsListDisplay[forceIndexString]
                    end
                end
            end
        elseif platformState == spacePlatformStateDefine.waiting_at_station then
            local platformData = storage.platforms[forceIndexString][platformIndexString]

            if platformData.leaveTick > 0 then
                platformData.entries[#platformData.entries].arriveTick = gameTick
                platformData.entries[#platformData.entries].arrivePlanet = spaceLocation.name
                platformData.arriveTick = gameTick
                platformData.leaveTick = 0
                platformData.entries[#platformData.entries + 1] = {
                    leavePlanet = spaceLocation.name,
                    startWaitingTick = gameTick,
                    arriveTick = 0,
                    leaveTick = 0
                }

                for _, player in pairs(platformForce.players) do
                    local playerIndexString = tostring(player.index)
                    local globalPlayer = storage.players[playerIndexString]

                    if globalPlayer.selectedIndex == platformData.index then
                        if globalPlayer.guis.logGuiMain then
                            logGui.buildLogGui(globalPlayer, platformData.entries)
                        end
                    end
                end
            end
        elseif platformState == spacePlatformStateDefine.on_the_path then
            local platformData = storage.platforms[forceIndexString][platformIndexString]

            if platformData.arriveTick > 0 then
                platformData.entries[#platformData.entries].leaveTick = gameTick
                platformData.leaveTick = gameTick
                platformData.arriveTick = 0

                for _, player in pairs(platformForce.players) do
                    local playerIndexString = tostring(player.index)
                    local globalPlayer = storage.players[playerIndexString]

                    if globalPlayer.selectedIndex == platformData.index then
                        if globalPlayer.guis.logGuiMain then
                            logGui.buildLogGui(globalPlayer, platformData.entries)
                        end
                    end
                end
            end
        end
    end
}

eventsLib.on_init = function()
    initStorage()
end

return eventsLib
