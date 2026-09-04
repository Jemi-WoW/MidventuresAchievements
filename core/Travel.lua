local _, ns = ...
if ns.disabled then return end

-- Getting about: flight paths, hearthstones, boats and zeppelins, and warlock summons.
CA_Criterias.dataLengths[ns.CRITERIA_FLIGHTS] = 0
CA_Criterias.criterias[ns.CRITERIA_FLIGHTS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_HEARTHS] = 0
CA_Criterias.criterias[ns.CRITERIA_HEARTHS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_TRANSPORT] = 0
CA_Criterias.criterias[ns.CRITERIA_TRANSPORT] = {}
CA_Criterias.dataLengths[ns.CRITERIA_SUMMONED] = 0
CA_Criterias.criterias[ns.CRITERIA_SUMMONED] = {}

local HEARTHSTONE = 8690

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.travel = MidventuresProgressDB.travel
        or { flights = 0, hearths = 0, transports = 0, summons = 0 }
    return MidventuresProgressDB.travel
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

-- Nothing announces a flight, so the taxi state is polled and the landing is the count.
local onTaxi = false

-- Aboard a boat or a zeppelin the client stops placing you, and that gap is the ride.
local boardedAt = nil

-- Elevators and loading screens read the same way, so a crossing has to outlast them.
local MIN_RIDE = 30

local debugging = false

-- World coordinates, missing on anything the world carries you on.
local function worldPlaced()
    if not UnitPosition then return nil end
    local y, x = UnitPosition('player')
    return x ~= nil and y ~= nil
end

-- The map arrow, which a transport either hides or pins to the corner.
local function mapPlaced()
    local mapID = C_Map.GetBestMapForUnit('player')
    local spot = mapID and C_Map.GetPlayerMapPosition(mapID, 'player')
    if not spot then return false end

    local x, y = spot:GetXY()
    return x ~= nil and not (x == 0 and y == 0)
end

local function aboard()
    if IsInInstance() then return false end
    if UnitOnTaxi and UnitOnTaxi('player') then return false end

    local world = worldPlaced()
    return world == false or not mapPlaced()
end

local function poll()
    local flying = UnitOnTaxi and UnitOnTaxi('player') or false
    if onTaxi and not flying then bump('flights', ns.CRITERIA_FLIGHTS) end
    onTaxi = flying

    local riding, now = aboard(), GetTime()
    if riding and not boardedAt then
        boardedAt = now
        if debugging then ns.Print('travel: boarded something') end
    elseif not riding and boardedAt then
        local ride = now - boardedAt
        boardedAt = nil
        if debugging then ns.Print(('travel: stepped off after %.0fs'):format(ride)) end
        if ride >= MIN_RIDE then bump('transports', ns.CRITERIA_TRANSPORT) end
    end
end

-- /midv travel says what the poll sees, for when a crossing does not count.
ns.commands.travel = function()
    debugging = not debugging
    local record = progress()
    ns.Print(('travel logging %s. world %s, map %s, aboard %s, crossings %d.'):format(
        debugging and 'on' or 'off',
        tostring(worldPlaced()), tostring(mapPlaced()), tostring(aboard()),
        record.transports or 0))
end

-- A summon is offered, then the world reloads around you if it was taken.
local summonOffered = nil

local function onCast(unit, _, spellID)
    if unit == 'player' and spellID == HEARTHSTONE then
        bump('hearths', ns.CRITERIA_HEARTHS)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('CONFIRM_SUMMON')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'UNIT_SPELLCAST_SUCCEEDED' then
        onCast(...)
    elseif event == 'CONFIRM_SUMMON' then
        summonOffered = GetTime and GetTime() or 0
    elseif event == 'PLAYER_ENTERING_WORLD' then
        local now = GetTime and GetTime() or 0
        -- Two minutes is how long a summon stands, so arriving inside that means it was taken.
        if summonOffered and now - summonOffered <= 120 then
            summonOffered = nil
            bump('summons', ns.CRITERIA_SUMMONED)
        end
    elseif event == 'PLAYER_LOGIN' then
        C_Timer.NewTicker(2, poll)
    end
end)
