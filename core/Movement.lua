local _, ns = ...
if ns.disabled then return end

-- Jumping, and the ground covered on your own two feet.
CA_Criterias.dataLengths[ns.CRITERIA_JUMPS] = 0
CA_Criterias.criterias[ns.CRITERIA_JUMPS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_YARDS] = 0
CA_Criterias.criterias[ns.CRITERIA_YARDS] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.movement = MidventuresProgressDB.movement or { jumps = 0, yards = 0 }
    return MidventuresProgressDB.movement
end

-- One press reaches us twice, and the client only admits a jump once you are airborne.
local DEBOUNCE = 0.75
local lastJump = -math.huge

local function jumped()
    if UnitOnTaxi and UnitOnTaxi('player') then return end
    if IsFlying and IsFlying() then return end
    if not (IsFalling and IsFalling()) then return end

    local now = GetTime()
    if now - lastJump <= DEBOUNCE then return end
    lastJump = now

    local record = progress()
    record.jumps = (record.jumps or 0) + 1
    CA_Criterias:Trigger(ns.CRITERIA_JUMPS, nil, record.jumps, true)
end

local function hook(name, fn)
    if _G[name] then hooksecurefunc(name, fn) end
end

hook('AscendStop', jumped)

-- Falling has not begun at the keypress, so this one looks again a moment later.
hook('JumpOrAscendStart', function() C_Timer.After(0.2, jumped) end)

-- Nothing reports distance, so it is sampled, the way JemiStats reads it.
local SAMPLE = 1

-- Further than this in a second is a loading screen or a summon, not a stride.
local MAX_STEP = 300

local lastX, lastY, lastInstance

local function forget()
    lastX, lastY, lastInstance = nil, nil, nil
end

local banked = 0

local function walked(step)
    local record = progress()
    record.yards = (record.yards or 0) + step

    -- The bar counts whole yards and does not need one every second.
    banked = banked + step
    if banked < 10 then return end

    banked = 0
    CA_Criterias:Trigger(ns.CRITERIA_YARDS, nil, math.floor(record.yards), true)
end

local function sample()
    if not UnitPosition then return end
    if UnitIsDeadOrGhost and UnitIsDeadOrGhost('player') then return forget() end
    if UnitOnTaxi and UnitOnTaxi('player') then return forget() end

    local y, x, _, instanceID = UnitPosition('player')
    if not (x and y) then return forget() end

    if lastX and instanceID == lastInstance then
        local step = math.sqrt((x - lastX) ^ 2 + (y - lastY) ^ 2)
        if step > 0 and step < MAX_STEP then walked(step) end
    end

    lastX, lastY, lastInstance = x, y, instanceID
end

-- Rungs added later start empty, so the running totals are pushed again at login.
local function refill()
    local record = progress()
    CA_Criterias:Trigger(ns.CRITERIA_JUMPS, nil, record.jumps or 0, true)
    CA_Criterias:Trigger(ns.CRITERIA_YARDS, nil, math.floor(record.yards or 0), true)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event)
    forget()
    if event == 'PLAYER_LOGIN' then C_Timer.NewTicker(SAMPLE, sample) end
    C_Timer.After(1, refill)
end)
