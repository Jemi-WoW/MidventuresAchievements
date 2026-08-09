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

-- The same trick util/Triggers.lua uses: the client's own strings are the patterns.
local function toPattern(text)
    return '^' .. text:gsub('([%^%$%(%)%.%[%]%*%+%-%?%%])', '%%%1'):gsub('%%%%s', '(.+)') .. '$'
end

local KNOCKOUT = toPattern(DUEL_WINNER_KNOCKOUT)  -- winner, then loser
local RETREAT = toPattern(DUEL_WINNER_RETREAT)    -- loser, then winner

-- Returns the pair the way the line orders them, or nothing when it is not a duel result.
local function duelResult(msg)
    local winner, loser = msg:match(KNOCKOUT)
    if winner then return winner, loser end
    loser, winner = msg:match(RETREAT)
    return winner, loser
end

-- Everyone you have ever duelled, kept by name so the same rival all evening is one face.
local function remember(name)
    local record, total = progress(), 0
    record.faced[name] = true
    for _ in pairs(record.faced) do total = total + 1 end
    CA_Criterias:Trigger(ns.CRITERIA_DUEL_PARTNERS, nil, total, true)
end

-- The other one is often still the target when this fires, so that is checked first and
-- the cached roster is the fallback.
local function check(msg)
    local winner, loser = duelResult(msg)
    if not winner then return end

    local me = UnitName('player')
    if winner == me then
        if not ns.IsGuildmate(loser, 'target') then return end
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_DUEL)
        remember(loser)
        if loser == ns.GuildMasterName() then
            CA_Criterias:Trigger(ns.CRITERIA_DUEL_MASTER)
        end
    elseif loser == me then
        if not ns.IsGuildmate(winner, 'target') then return end
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
