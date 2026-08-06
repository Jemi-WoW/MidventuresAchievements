local _, ns = ...
if ns.disabled then return end

-- Guild chat carries the achievement as plain text, because the server strips hyperlinks
-- and textures it does not recognise. Each client with the addon turns that text back into
-- a link, and anyone without it still reads a sensible sentence.
local LINK = '|cffffff00|Hgarrmission:mvach:%d#%s|h[%s]|h|r'

-- The points shield, the same one the leaderboard puts beside a score. The image holds it
-- in its top left corner, hence the coordinates.
local ICON = '|TInterface\\AddOns\\AnniversaryAchievements\\textures\\'
    .. 'UI-Achievement-TinyShield:14:14:0:0:64:64:0:40:0:40|t '

local byName

local function achievementByName(name)
    if not byName then
        byName = {}
        for id, achievement in pairs(CA_Database:GetAllAchievements()) do
            byName[achievement.name] = id
        end
    end
    return byName[name]
end

-- Rebuilt from the same formatter that sent it, so the link sits exactly where the name was.
-- The line never names the player, so who to open the leaderboard on comes off the author.
local function relink(_, _, message, author, ...)
    local name = ns.ParseAnnouncement(message)
    if not name then return false end

    local achievementID = achievementByName(name)
    if not achievementID then return false end

    local player = strsplit('-', author or '')
    local link = LINK:format(achievementID, player, name)
    return false, ICON .. ns.Announcement(link), author, ...
end

ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', relink)

-- Anniversary hooks the same function for its own `clach` links and leaves ours alone.
hooksecurefunc('SetItemRef', function(link)
    local linkType, addon, params = strsplit(':', link)
    if linkType ~= 'garrmission' or addon ~= 'mvach' or not params then return end

    local achievementID, player = strsplit('#', params)
    ns.ShowLeaderboardFor(player, tonumber(achievementID))
end)
