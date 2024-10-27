local quene = {}

function quene:add(entity, gameTick, unitNumberString, surfaceIndexString, forceIndexString)
    self[gameTick] = self[gameTick] or {}
    self[gameTick][unitNumberString] = { entity = entity, surfaceIndexString = surfaceIndexString, forceIndexString = forceIndexString }
end

function quene:remove(gameTick, unitNumberString)
    self[gameTick][unitNumberString] = nil

    if not next(self[gameTick]) then
        self[gameTick] = nil
    end
end

return quene
