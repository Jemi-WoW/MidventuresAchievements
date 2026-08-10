local _, ns = ...
if ns.disabled then return end

-- Anniversary counts duels won but never asks who lost, so we register our own type.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_DUEL] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_DUEL] = {}

-- The rest of what a duel says about you: who you have faced, whether the boss was one of
-- them, and how often it went the other way.
CA_Criterias.dataLengths[ns.CRITERIA_DUEL_PARTNERS] = 0
CA_Criterias.criterias[ns.CRITERIA_DUEL_PARTNERS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DUEL_MASTER] = 0
CA_Criterias.criterias[ns.CRITERIA_DUEL_MASTER] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DUEL_LOSSES] = 0
CA_Criterias.criterias[ns.CRITERIA_DUEL_LOSSES] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.duels = MidventuresProgressDB.duels or { losses = 0, faced = {} }
    return MidventuresProgressDB.duels
end

local MARK = '\1'

local function toPattern(text)
    if not text then return nil, {} end

    local order, plain = {}, 0
    local marked = text:gsub('%%(%d)%$s', function(index)
        order[#order + 1] = tonumber(index)
        return MARK
    end)
    marked = marked:gsub('%%s', function()
        plain = plain + 1
        order[#order + 1] = plain
        return MARK
    end)

    local escaped = marked:gsub('([%^%$%(%)%.%[%]%*%+%-%?%%])', '%%%1')
    return '^' .. escaped:gsub(MARK, '(.+)') .. '$', order
end

local KNOCKOUT, KNOCKOUT_ORDER = toPattern(DUEL_WINNER_KNOCKOUT)  -- winner, then loser
local RETREAT, RETREAT_ORDER = toPattern(DUEL_WINNER_RETREAT)     -- loser, then winner

local function argument(order, wanted, captures)
    for i, number in ipairs(order) do
        if number == wanted then return captures[i] end
    end
end

local function duelResult(msg)
    if KNOCKOUT then
        local captures = { msg:match(KNOCKOUT) }
        if captures[1] then
            return argument(KNOCKOUT_ORDER, 1, captures), argument(KNOCKOUT_ORDER, 2, captures)
        end
    end
    if RETREAT then
        local captures = { msg:match(RETREAT) }
        if captures[1] then
            return argument(RETREAT_ORDER, 2, captures), argument(RETREAT_ORDER, 1, captures)
        end
    end
end

-- Everyone you have ever duelled, kept by name so the same rival all evening is one face.
local function remember(name)
    local record, total = progress(), 0
    record.faced[name] = true
    for _ in pairs(record.faced) do total = total + 1 end
    CA_Criterias:Trigger(ns.CRITERIA_DUEL_PARTNERS, nil, total, true)
end

local function isOurs(name)
    local unit = UnitName('target') == name and 'target' or nil
    return ns.IsGuildmate(name, unit)
end

-- Only duels between us count, whichever way they went.
local function check(msg)
    local winner, loser = duelResult(msg)
    if not (winner and loser) then return end

    local me = UnitName('player')
    if winner == me then
        if not isOurs(loser) then return end
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_DUEL)
        remember(loser)
        if loser == ns.GuildMasterName() then
            CA_Criterias:Trigger(ns.CRITERIA_DUEL_MASTER)
        end
    elseif loser == me then
        if not isOurs(winner) then return end
        remember(winner)
        local record = progress()
        record.losses = record.losses + 1
        CA_Criterias:Trigger(ns.CRITERIA_DUEL_LOSSES, nil, record.losses, true)
    end
end

local function refill()
    local record, total = progress(), 0
    for _ in pairs(record.faced) do total = total + 1 end
    CA_Criterias:Trigger(ns.CRITERIA_DUEL_PARTNERS, nil, total, true)
    CA_Criterias:Trigger(ns.CRITERIA_DUEL_LOSSES, nil, record.losses, true)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_SYSTEM')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event, msg)
    if event == 'CHAT_MSG_SYSTEM' then
        check(msg)
    else
        C_Timer.After(8, refill)
    end
end)
