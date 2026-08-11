local _, ns = ...
if ns.disabled then return end

-- Battlegrounds and arenas, told apart by how many of the guild came along.
CA_Criterias.dataLengths[ns.CRITERIA_BG_WIN_GUILD] = 1
CA_Criterias.criterias[ns.CRITERIA_BG_WIN_GUILD] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BG_LOSSES] = 0
CA_Criterias.criterias[ns.CRITERIA_BG_LOSSES] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BG_DEATHS] = 0
CA_Criterias.criterias[ns.CRITERIA_BG_DEATHS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_BG_CARRIED] = 0
CA_Criterias.criterias[ns.CRITERIA_BG_CARRIED] = {}
CA_Criterias.dataLengths[ns.CRITERIA_ARENA_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_ARENA_GUILD] = {}
CA_Criterias.dataLengths[ns.CRITERIA_ARENA_LOSSES] = 0
CA_Criterias.criterias[ns.CRITERIA_ARENA_LOSSES] = {}

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.battlegrounds = MidventuresProgressDB.battlegrounds
        or { losses = 0, deaths = 0, arenaWins = 0, arenaLosses = 0 }
    return MidventuresProgressDB.battlegrounds
end

local function bump(key, criteriaType)
    local record = progress()
    record[key] = (record[key] or 0) + 1
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

-- The score board is the only place that says which side won and what you did about it.
local function myScore()
    local me = UnitName('player')
    for i = 1, GetNumBattlefieldScores() do
        local name, killingBlows, honorableKills, deaths, _, faction = GetBattlefieldScore(i)
        if name == me then return killingBlows, honorableKills, deaths, faction end
    end
end

local function iWon(winner)
    local _, _, _, faction = myScore()
    if faction then return faction == winner end

    -- No row of our own means a disconnect at the worst moment, so fall back to the side.
    local mine = UnitFactionGroup('player') == 'Horde' and 0 or 1
    return mine == winner
end

-- Each match is scored once: the event fires again and again while the board is open.
local scored = false

local function onBattleground(winner)
    local guildmates = ns.GuildsInRaid()

    if not iWon(winner) then
        bump('losses', ns.CRITERIA_BG_LOSSES)
        return
    end

    for wanted in pairs(CA_Criterias.criterias[ns.CRITERIA_BG_WIN_GUILD]) do
        if guildmates >= wanted then
            CA_Criterias:Trigger(ns.CRITERIA_BG_WIN_GUILD, {wanted})
        end
    end

    local killingBlows, honorableKills = myScore()
    if killingBlows == 0 and honorableKills == 0 then
        CA_Criterias:Trigger(ns.CRITERIA_BG_CARRIED)
    end
end

-- An arena team is a party, so every other member being one of ours is the whole test.
local function allGuild()
    if not ns.InOurGuild() then return false end

    local mates = 0
    for i = 1, 4 do
        local unit = 'party' .. i
        if UnitExists(unit) then
            if not UnitIsInMyGuild(unit) then return false end
            mates = mates + 1
        end
    end
    return mates >= 1
end

local function onArena(winner)
    local me = UnitName('player')
    for i = 1, GetNumBattlefieldScores() do
        local name, _, _, _, _, team = GetBattlefieldScore(i)
        if name == me then
            if team ~= winner then
                bump('arenaLosses', ns.CRITERIA_ARENA_LOSSES)
            elseif allGuild() then
                bump('arenaWins', ns.CRITERIA_ARENA_GUILD)
            end
            return
        end
    end
end

local function onScore()
    local winner = GetBattlefieldWinner()
    if winner == nil then
        scored = false
        return
    end
    if scored then return end
    scored = true

    if IsActiveBattlefieldArena and IsActiveBattlefieldArena() then
        onArena(winner)
    else
        onBattleground(winner)
    end
end

-- Dying in a battleground is its own thing, and there are a lot of ways to arrange it.
local function onDeath()
    local inside, kind = IsInInstance()
    if inside and kind == 'pvp' then bump('deaths', ns.CRITERIA_BG_DEATHS) end
end

local function refill()
    local record = progress()
    CA_Criterias:Trigger(ns.CRITERIA_BG_LOSSES, nil, record.losses, true)
    CA_Criterias:Trigger(ns.CRITERIA_BG_DEATHS, nil, record.deaths, true)
    CA_Criterias:Trigger(ns.CRITERIA_ARENA_GUILD, nil, record.arenaWins, true)
    CA_Criterias:Trigger(ns.CRITERIA_ARENA_LOSSES, nil, record.arenaLosses, true)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('UPDATE_BATTLEFIELD_SCORE')
watcher:RegisterEvent('PLAYER_DEAD')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event)
    if event == 'UPDATE_BATTLEFIELD_SCORE' then
        onScore()
    elseif event == 'PLAYER_DEAD' then
        onDeath()
    else
        scored = false
        C_Timer.After(8, refill)
    end
end)
