local _, ns = ...
if ns.disabled then return end

-- Anniversary has no guild criteria type, so we register one of our own.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD] = {}

-- Reads membership rather than listening for a join, so installing later still counts.
local function check()
    if GetGuildInfo('player') == ns.GUILD_NAME then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD)
    end
end

-- Guild data is not up yet at login, so every event gets a moment to settle.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('PLAYER_GUILD_UPDATE')
watcher:RegisterEvent('GUILD_ROSTER_UPDATE')
watcher:SetScript('OnEvent', function() C_Timer.After(2, check) end)
