local _, ns = ...
if ns.disabled then return end

-- One read of the combat log per event, shared out by subevent. '*' takes every event.
local handlers = { ['*'] = {} }

function ns.OnCombatLog(subEvents, handler)
    for _, subEvent in ipairs(subEvents) do
        local list = handlers[subEvent]
        if not list then
            list = {}
            handlers[subEvent] = list
        end
        list[#list + 1] = handler
    end
end

-- Everything from the twelfth field on is passed through: its meaning is per subevent.
local function dispatch(_, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, ...)
    local list = handlers[subEvent]
    if list then
        for i = 1, #list do
            list[i](subEvent, sourceGUID, sourceName, destGUID, destName, ...)
        end
    end

    local every = handlers['*']
    for i = 1, #every do
        every[i](subEvent, sourceGUID, sourceName, destGUID, destName, ...)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
watcher:SetScript('OnEvent', function() dispatch(CombatLogGetCurrentEventInfo()) end)
