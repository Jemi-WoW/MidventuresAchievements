local _, ns = ...
if ns.disabled then return end

-- Helpful spells landed on other players, counted as auras so group buffs credit each.
CA_Criterias.dataLengths[ns.CRITERIA_BUFF_PLAYERS] = 0
CA_Criterias.criterias[ns.CRITERIA_BUFF_PLAYERS] = {}

-- Heals over time are auras too, so they are named out. GetSpellInfo keeps this localised.
local HEALS = {774, 8936, 139, 740, 33076, 974}

local healNames = {}
for _, spellID in ipairs(HEALS) do
    local name = GetSpellInfo(spellID)
    if name then healNames[name] = true end
end

local playerGUID

ns.OnCombatLog({'SPELL_PERIODIC_HEAL', 'SPELL_AURA_APPLIED'},
    function(subEvent, sourceGUID, _, destGUID, _, _, spellName, _, auraType)
        -- Anything that ticks a heal is one, whoever cast it.
        if subEvent == 'SPELL_PERIODIC_HEAL' then
            if spellName then healNames[spellName] = true end
            return
        end

        if auraType ~= 'BUFF' or not playerGUID then return end
        if sourceGUID ~= playerGUID or destGUID == playerGUID then return end
        if not destGUID or destGUID:sub(1, 7) ~= 'Player-' then return end
        if healNames[spellName] then return end

        CA_Criterias:Trigger(ns.CRITERIA_BUFF_PLAYERS)
    end)

-- The guid is only readable once the player exists, and it never changes after that.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:SetScript('OnEvent', function(self)
    playerGUID = UnitGUID('player')
    self:UnregisterAllEvents()
end)
