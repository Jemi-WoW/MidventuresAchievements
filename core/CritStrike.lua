local _, ns = ...
if ns.disabled then return end

-- A critical strike worth at least so much. Data is the damage to reach.
CA_Criterias.dataLengths[ns.CRITERIA_CRIT_ABOVE] = 1
CA_Criterias.criterias[ns.CRITERIA_CRIT_ABOVE] = {}

-- Where the amount sits in the payload; critical is always six fields further along.
local AMOUNT_AT = {
    SWING_DAMAGE          = 1,
    SPELL_DAMAGE          = 4,
    SPELL_PERIODIC_DAMAGE = 4,
    RANGE_DAMAGE          = 4,
}

local playerGUID

-- No need to ask whether the player is in combat: dealing damage is being in combat.
ns.OnCombatLog({'SWING_DAMAGE', 'SPELL_DAMAGE', 'SPELL_PERIODIC_DAMAGE', 'RANGE_DAMAGE'},
    function(subEvent, sourceGUID, _, _, _, ...)
        if sourceGUID ~= playerGUID then return end

        local amount, _, _, _, _, _, critical = select(AMOUNT_AT[subEvent], ...)
        if not critical or not amount then return end

        -- The registered criteria are the whole list of thresholds anyone cares about.
        for damage in pairs(CA_Criterias.criterias[ns.CRITERIA_CRIT_ABOVE]) do
            if amount >= damage then
                CA_Criterias:Trigger(ns.CRITERIA_CRIT_ABOVE, {damage})
            end
        end
    end)

-- The guid is only readable once the player exists, and it never changes after that.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:SetScript('OnEvent', function(self)
    playerGUID = UnitGUID('player')
    self:UnregisterAllEvents()
end)
