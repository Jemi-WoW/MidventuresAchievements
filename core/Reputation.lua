local _, ns = ...
if ns.disabled then return end

-- Being disliked. Anniversary's reputation criteria only ever ask for a standing or better,
-- and everyone is already at Hated or better, so going the other way needs its own type.
-- Data is a faction id, or 0 for whoever will have you least.
CA_Criterias.dataLengths[ns.CRITERIA_REP_HATED] = 1
CA_Criterias.criterias[ns.CRITERIA_REP_HATED] = {}

ns.REP_ANY_FACTION = 0
local HATED = 1

local function check()
    local wanted = CA_Criterias.criterias[ns.CRITERIA_REP_HATED]

    for index = 1, GetNumFactions() do
        local _, _, standing, _, _, _, _, _, isHeader, _, _, _, _, factionID =
            GetFactionInfo(index)
        if not isHeader and standing == HATED then
            CA_Criterias:Trigger(ns.CRITERIA_REP_HATED, {ns.REP_ANY_FACTION})
            if factionID and wanted[factionID] then
                CA_Criterias:Trigger(ns.CRITERIA_REP_HATED, {factionID})
            end
        end
    end
end

-- The faction list is only filled in once the world is up, and collapsed headers hide the
-- rows below them, so this is re-read rather than watched once.
local watcher = CreateFrame('Frame')
watcher:RegisterEvent('UPDATE_FACTION')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function() C_Timer.After(2, check) end)
