local _, ns = ...
if ns.disabled then return end

-- A critical strike worth at least so much. Data is the damage to reach.
CA_Criterias.dataLengths[ns.CRITERIA_CRIT_ABOVE] = 1
CA_Criterias.criterias[ns.CRITERIA_CRIT_ABOVE] = {}

-- Where the amount sits in each event, after the eleven fields every combat log line starts
-- with. Swing has no prefix payload, the rest carry a spell id, name and school first.
-- From the amount onwards the shape is the same, so critical is always six further along.
local AMOUNT_AT = {
    SWING_DAMAGE          = 12,
    SPELL_DAMAGE          = 15,
    SPELL_PERIODIC_DAMAGE = 15,
    RANGE_DAMAGE          = 15,
}

local playerGUID

-- No need to ask whether the player is in combat: dealing damage is being in combat.
local function onCombatLog()
    local _, subEvent, _, sourceGUID = CombatLogGetCurrentEventInfo()
    local at = AMOUNT_AT[subEvent]
    if not at or sourceGUID ~= playerGUID then return end

    local amount, _, _, _, _, _, critical = select(at, CombatLogGetCurrentEventInfo())
    if not critical or not amount then return end

    -- The registered criteria are the whole list of thresholds anyone cares about.
    for damage in pairs(CA_Criterias.criterias[ns.CRITERIA_CRIT_ABOVE]) do
        if amount >= damage then
            CA_Criterias:Trigger(ns.CRITERIA_CRIT_ABOVE, {damage})
        end
    end
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
