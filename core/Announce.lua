local _, ns = ...
if ns.disabled then return end

-- Written and read in one place, so this and ui/ChatLink.lua cannot drift apart.
local FORMAT = 'Has just completed %s!'
local PATTERN = '^Has just completed %[(.+)%]!$'

-- Arrives wrapped already: brackets from here, a link from the chat filter.
function ns.Announcement(achievement)
    return FORMAT:format(achievement)
end

-- Returns the achievement name, or nothing if this is an ordinary line.
function ns.ParseAnnouncement(message)
    return message:match(PATTERN)
end

-- A fresh install earns a pile at once, so nothing is said until login has settled.
local SETTLE = 15
local ready = false

-- One at a time: a meta and its parts land together and the server throttles bursts.
local SPACING = 2
local MAX_QUEUED = 8

local queue, draining = {}, false

local function drain()
    local message = table.remove(queue, 1)
    if not message then
        draining = false
        return
    end
    SendChatMessage(message, 'GUILD')
    C_Timer.After(SPACING, drain)
end

local function announce(achievementID)
    if not (ready and IsInGuild() and ns.Setting('guildAnnounce')) then return end

    local achievement = CA_Database:GetAchievement(achievementID)
    if not achievement then return end
    if #queue >= MAX_QUEUED then return end

    queue[#queue + 1] = ns.Announcement('[' .. achievement.name .. ']')
    if draining then return end
    draining = true
    drain()
end

-- Called once per achievement earned, theirs and ours alike.
local baseShare = CA_ShareAchievement
function CA_ShareAchievement(achievementID)
    baseShare(achievementID)
    announce(achievementID)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:SetScript('OnEvent', function(self)
    self:UnregisterEvent('PLAYER_LOGIN')
    C_Timer.After(SETTLE, function() ready = true end)
end)
