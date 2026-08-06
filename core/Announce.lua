local _, ns = ...
if ns.disabled then return end

-- The one place the guild message is written and read, so the sender and the chat filter
-- in ui/ChatLink.lua can never drift apart. Guild chat already prints who is talking, so
-- the line does not name the player again.
local FORMAT = 'Has just completed %s!'
local PATTERN = '^Has just completed %[(.+)%]!$'

-- The achievement arrives already wrapped: in brackets from here, or in a link from the
-- chat filter, which is how the link can cover the brackets rather than sit inside them.
function ns.Announcement(achievement)
    return FORMAT:format(achievement)
end

-- Returns the achievement name, or nothing if this is an ordinary line.
function ns.ParseAnnouncement(message)
    return message:match(PATTERN)
end

-- Anniversary re-checks everything a couple of seconds after login, and a fresh install
-- earns a pile of old achievements at once. Nothing is said until that has passed.
local SETTLE = 15
local ready = false

-- A meta and its parts can land together, so they go out one at a time rather than in a
-- burst the server would throttle.
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

-- Anniversary calls this once for every achievement as it is earned, theirs and ours
-- alike, so it is the one place both kinds pass through.
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
