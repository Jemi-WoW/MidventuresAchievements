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

-- The client answers 0,0 for map position while the player is standing on something that
-- moves, which is the only way to know a boat or zeppelin is under your feet.
local onTransport = false

local function position()
    local mapID = C_Map.GetBestMapForUnit('player')
    if not mapID then return nil end
    local spot = C_Map.GetPlayerMapPosition(mapID, 'player')
    if not spot then return nil end
    return spot:GetXY()
end

local function poll()
    local flying = UnitOnTaxi and UnitOnTaxi('player') or false
    if onTaxi and not flying then bump('flights', ns.CRITERIA_FLIGHTS) end
    onTaxi = flying

    local x, y = position()
    local moving = x == 0 and y == 0 and not IsInInstance()
    if moving and not onTransport then bump('transports', ns.CRITERIA_TRANSPORT) end
    onTransport = moving
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
