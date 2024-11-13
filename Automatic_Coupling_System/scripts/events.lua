local coupleSignalId = { type = "virtual", name = "signal-couple" }
local decoupleSignalId = { type = "virtual", name = "signal-decouple" }
local railDirectionDefine = defines.rail_direction
local wireConnectorIdDefine = defines.wire_connector_id
local eventsDefine = defines.events
local eventsLib = {}

---comment
---@param positionA MapPosition
---@param positionB MapPosition
---@return double
local function getTileDistanceBetweenTwoPositions(positionA, positionB)
    return math.abs(positionA.x - positionB.x) + math.abs(positionA.y - positionB.y)
end

---comment
---@param entity LuaEntity
---@param signalId any
---@return boolean
local function checkCircuitNetworkHasSignal(entity, signalId)
    local redCircuitNetwork = entity.get_circuit_network(wireConnectorIdDefine.circuit_red)
    local greenCircuitNetwork = entity.get_circuit_network(wireConnectorIdDefine.circuit_green)

    return (redCircuitNetwork ~= nil and redCircuitNetwork.get_signal(signalId) ~= 0) or (greenCircuitNetwork ~= nil and greenCircuitNetwork.get_signal(signalId) ~= 0)
end
---comment
---@param train LuaTrain
---@return boolean
local function checkCircuitNetworkHasSignals(train)
    local stationEntity = train.station

    return stationEntity ~= nil and (checkCircuitNetworkHasSignal(stationEntity, coupleSignalId) or checkCircuitNetworkHasSignal(stationEntity, decoupleSignalId))

end
---comment
---@param entity LuaEntity
---@param signalId any
---@return integer
local function getCircuitNetworkSingalValue(entity, signalId)
    local redCircuitNetwork = entity.get_circuit_network(wireConnectorIdDefine.circuit_red)
    local greenCircuitNetwork = entity.get_circuit_network(wireConnectorIdDefine.circuit_green)
    local signalValue = 0

    if redCircuitNetwork then
        signalValue = redCircuitNetwork.get_signal(signalId)
    end

    if greenCircuitNetwork then
        signalValue = signalValue + greenCircuitNetwork.get_signal(signalId)
    end

    return signalValue
end

---comment
---@param train LuaTrain
---@param stationEntity any
---@return LuaEntity, LuaEntity
local function getFrontBackTrainEntity(train, stationEntity)
    local trainFrontEntity = train.front_stock
    local trainBackEntity = train.back_stock

    if trainFrontEntity ~= nil and getTileDistanceBetweenTwoPositions(trainFrontEntity.position, stationEntity.position) < getTileDistanceBetweenTwoPositions(trainBackEntity.position, stationEntity.position) then
        return trainFrontEntity, trainBackEntity
    else
        return trainBackEntity, trainFrontEntity
    end
end

---@param train LuaTrain
---@param decoupleCount integer
---@param trainFrontEntity LuaEntity
---the first value is the part that has the locomotives the closest to the train stop
---@return LuaEntity
---the second value is what left behind
---@return LuaEntity
local function attemptUncoupleTrain(train, decoupleCount, trainFrontEntity)
    local carriages = train.carriages

    local rail_direction
    -- front end
    local targetWagon
    -- back end the part of the train that is left behind
    local back_end

    -- if decoupleCount is negatif we start from the end of the train
    if decoupleCount < 0 then
        decoupleCount = #carriages + decoupleCount
    end

    if math.abs(decoupleCount) < #carriages then
        -- by default the disonnection direction is back
        rail_direction = defines.rail_direction.back

        if trainFrontEntity == train.front_stock then
            targetWagon = carriages[decoupleCount]
            back_end = carriages[decoupleCount + 1]
            -- but if the targetWagon is connected at the front to the back_end, we switch direction
            if back_end == targetWagon.get_connected_rolling_stock(defines.rail_direction.front) then
                rail_direction = defines.rail_direction.front
            end
        else
            decoupleCount = (#carriages - decoupleCount) + 1
            targetWagon = carriages[decoupleCount]
            back_end = carriages[decoupleCount - 1]

            -- but if the targetWagon is connected at the front to the back_end, we switch direction
            if back_end == targetWagon.get_connected_rolling_stock(defines.rail_direction.front) then
                rail_direction = defines.rail_direction.front
            end
        end
            if targetWagon.disconnect_rolling_stock(rail_direction) then
                return targetWagon, back_end
            else
                return nil,nil
            end
        end
        return nil,nil
    end

    ---@param trainFrontEntity LuaTrain
    ---@param coupleCount integer
    ---@return boolean
local function attemptCoupleTrain( trainFrontEntity, coupleCount)
    if coupleCount ~= 0 then
        local coupleRailDirection = coupleCount < 0 and railDirectionDefine.back or railDirectionDefine.front
        return trainFrontEntity.connect_rolling_stock(coupleRailDirection)
    end
    return false
end

---@param train LuaTrain
local function doTrainCoupleLogic(train)
    local trainIdString = tostring(train.id)
    local stationEntity = storage.automaticTrainIds[trainIdString].station
    local trainSchedule = train.schedule
    local currentStation = train.schedule.current
    local trainGroup = train.group

    storage.automaticTrainIds[trainIdString] = nil

    if stationEntity and stationEntity.valid then
        local trainFrontEntity, trainBackEntity = getFrontBackTrainEntity(train, stationEntity)

        local motored_end
        local unmotored_end

        local decoupleCount = getCircuitNetworkSingalValue(stationEntity, decoupleSignalId)
        local coupleCount = getCircuitNetworkSingalValue(stationEntity, coupleSignalId)

        if attemptCoupleTrain(trainFrontEntity, coupleCount) then
            train = trainFrontEntity.train

            if trainFrontEntity == train.front_stock or trainBackEntity == train.back_stock then
                trainFrontEntity = train.front_stock
                trainBackEntity = train.back_stock
            else
                trainFrontEntity = train.back_stock
                trainBackEntity = train.front_stock
            end
            if trainGroup  == nil or trainGroup == "" then
                trainFrontEntity.train.schedule = trainSchedule
            else
                trainFrontEntity.train.group = trainGroup
            end
            trainFrontEntity.train.go_to_station(currentStation)
        end
        if decoupleCount ~= 0 then
            trainFrontEntity, trainBackEntity = attemptUncoupleTrain(train, decoupleCount, trainFrontEntity)
            if  trainFrontEntity ~= nil and trainBackEntity ~= nil  and (#trainFrontEntity.train.locomotives.front_movers > 0 or #trainFrontEntity.train.locomotives.back_movers > 0) then
                motored_end = trainFrontEntity
                unmotored_end = trainBackEntity
            else
                motored_end = trainBackEntity
                unmotored_end = trainFrontEntity
            end
            if motored_end then
                if (#trainGroup > 0) then
                    motored_end.train.group = trainGroup
                    if unmotored_end then
                        unmotored_end.train.group = nil
                    end
                else
                    motored_end.train.schedule = trainSchedule
                    if unmotored_end then
                        unmotored_end.train.schedule = nil
                    end
                end
                motored_end.train.go_to_station(currentStation)
            end
        end
    end
end

eventsLib.events = {
    [eventsDefine.on_game_created_from_scenario] = function()
        storage.automaticTrainIds = storage.automaticTrainIds or {}
    end,
    [eventsDefine.on_train_created] = function(eventData)
        local newTrainId = tostring(eventData.train.id)
        local oldTrainId1 = tostring(eventData.old_train_id_1)
        local oldTrainId2 = tostring(eventData.old_train_id_2)

        if storage.automaticTrainIds[oldTrainId1] then
            storage.automaticTrainIds[newTrainId] = storage.automaticTrainIds[oldTrainId1]
        elseif storage.automaticTrainIds[oldTrainId2] then
            storage.automaticTrainIds[newTrainId] = storage.automaticTrainIds[oldTrainId2]
        end

        if storage.automaticTrainIds[oldTrainId1] then
            storage.automaticTrainIds[oldTrainId1] = nil
        end

        if storage.automaticTrainIds[oldTrainId2] then
            storage.automaticTrainIds[oldTrainId2] = nil
        end
    end,
    [eventsDefine.on_train_changed_state] = function(eventData)
        local train = eventData.train
        local waitStationDefine = defines.train_state.wait_station
        if train ~= nil then
            if train.state == waitStationDefine then
                if checkCircuitNetworkHasSignals(train) then
                    storage.automaticTrainIds[tostring(train.id)] = { station = train.station }
                end
            elseif eventData.old_state == waitStationDefine then
                local storageTrainData = storage.automaticTrainIds[tostring(train.id)]
                if storageTrainData then
                    doTrainCoupleLogic(train)
                end
            end 
        end
    end
}

eventsLib.on_init = function()
    storage.automaticTrainIds = storage.automaticTrainIds or {}
end

script.on_configuration_changed(function(eventData)
    local modChanges = eventData.mod_changes

    storage.automaticTrainIds = storage.automaticTrainIds or {}

    if modChanges then
        local atcChanges = modChanges["Automatic_Coupling_System"]

        if atcChanges then
            local oldAtcVersion = atcChanges.old_version

            if oldAtcVersion and atcChanges.new_version then
                if oldAtcVersion <= "0.2.3" then
                    local trainIds = storage.TrainsID

                    storage.TrainsID = nil

                    if next(trainIds) then
                        for trainId, tableData in pairs(trainIds) do
                            storage.automaticTrainIds[tostring(trainId)] = { station = tableData.s }
                        end
                    end
                end

                if oldAtcVersion > "0.2.3" and oldAtcVersion < "2.0.0" then
                    local trainIds = storage.TrainsID

                    storage.TrainsID = nil

                    if next(trainIds) then
                        for trainId, tableData in pairs(trainIds) do
                            storage.automaticTrainIds[tostring(trainId)] = { station = tableData.station }
                        end
                    end
                end

                if oldAtcVersion > "2.0.0" and oldAtcVersion < "2.0.3" then
                    if not storage.automaticTrainIds then
                        storage.automaticTrainIds = storage.trainIds
                        storage.trainIds = nil
                    end
                end
            end
        end
    end
end)

return eventsLib
