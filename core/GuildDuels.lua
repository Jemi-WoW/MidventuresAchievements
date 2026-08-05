local _, ns = ...
if ns.disabled then return end

-- Anniversary counts duels won but never asks who lost, so we register our own type.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_DUEL] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_DUEL] = {}

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

-- The loser is rarely still targetable by the time this fires, so match against the roster.
local function check(msg)
    local winner, loser = duelResult(msg)
    if not winner or winner ~= UnitName('player') then return end
    if ns.GuildMemberNames()[loser] then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_DUEL)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_SYSTEM')
watcher:SetScript('OnEvent', function(_, _, msg) check(msg) end)
