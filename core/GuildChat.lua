local _, ns = ...
if ns.disabled then return end

-- Counts what this character says in guild chat. Anniversary has no chat criteria at all.
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_CHAT] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_CHAT] = {}

-- CHAT_MSG_GUILD only ever carries our own guild, so the sender is the whole test.
-- Some clients suffix the realm onto the sender and never onto UnitName, hence the strip.
local function check(_, sender)
    if not ns.InOurGuild() then return end
    local name = sender and (sender:match('^([^-]+)') or sender)
    if name == UnitName('player') then
        CA_Criterias:Trigger(ns.CRITERIA_GUILD_CHAT)
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_GUILD')
watcher:SetScript('OnEvent', function(_, _, ...) check(...) end)
