local _, ns = ...
if ns.disabled then return end

-- Helpful spells landed on other players. Counting auras rather than casts means a group
-- buff credits everyone it reaches, and every class has something that counts.
CA_Criterias.dataLengths[ns.CRITERIA_BUFF_PLAYERS] = 0
CA_Criterias.criterias[ns.CRITERIA_BUFF_PLAYERS] = {}

-- Where the aura type sits, after the eleven fields every combat log line starts with and
-- the spell id, name and school the event carries first.
local AURA_TYPE_AT = 15

local playerGUID

-- The combat log is a hot path, so this bails on the subevent before reading anything else.
local function onCombatLog()
    local _, subEvent, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
    if subEvent ~= 'SPELL_AURA_APPLIED' then return end
    if sourceGUID ~= playerGUID or destGUID == playerGUID then return end
    if not destGUID or destGUID:sub(1, 7) ~= 'Player-' then return end

    if select(AURA_TYPE_AT, CombatLogGetCurrentEventInfo()) ~= 'BUFF' then return end
    CA_Criterias:Trigger(ns.CRITERIA_BUFF_PLAYERS)
end

-- The guid is only readable once the player exists, and it never changes after that.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:SetScript('OnEvent', function(self)
    playerGUID = UnitGUID('player')
    self:UnregisterEvent('PLAYER_LOGIN')
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self:SetScript('OnEvent', onCombatLog)
end)
