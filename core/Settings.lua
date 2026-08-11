local _, ns = ...
if ns.disabled then return end

-- Our own settings, in our own saved variable rather than Anniversary's CA_Settings.
-- Saved variables are loaded before this file runs, so the table is already whatever
-- the player left it as.
local DEFAULTS = {
    guildAnnounce = true,
    leaderboardLayout = 'list',
}

function ns.Setting(key)
    MidventuresSettingsDB = MidventuresSettingsDB or {}
    if MidventuresSettingsDB[key] == nil then MidventuresSettingsDB[key] = DEFAULTS[key] end
    return MidventuresSettingsDB[key]
end

function ns.SetSetting(key, value)
    MidventuresSettingsDB = MidventuresSettingsDB or {}
    MidventuresSettingsDB[key] = value
end

-- Anniversary registers its options with Ace, so ours can be appended to the same table.
-- One checkbox does not deserve a second panel in the addon list.
local APP = 'Anniversary Achievements'

local registry = LibStub('AceConfigRegistry-3.0', true)
local options = registry and registry:GetOptionsTable(APP, 'dialog', 'AceConfigDialog-3.0')
if not (options and options.args) then return end

-- Their own entries run to order 5, and the reload warning sits at 90.
options.args.mvHeader = {
    type = 'header',
    name = 'Midventures Achievements',
    order = 10,
}

options.args.mvGuildAnnounce = {
    type = 'toggle',
    name = 'Achievement Guild chat messages',
    desc = 'Alert completed Achievements in guild chat.',
    width = 2,
    set = function(_, value) ns.SetSetting('guildAnnounce', value) end,
    get = function() return ns.Setting('guildAnnounce') end,
    order = 11,
}

options.args.mvGuildAnnounceNote = {
    type = 'description',
    name = 'Alert completed Achievements in guild chat',
    width = 'full',
    order = 12,
}

registry:NotifyChange(APP)
