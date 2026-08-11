local _, ns = ...
if ns.disabled then return end

-- The server strips hyperlinks from guild chat, so each client rebuilds the link itself.
local LINK = '|cffffff00|Hgarrmission:mvach:%d#%s|h[%s]|h|r'

-- The points shield, held in the image's top left corner.
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

-- Rebuilt by the formatter that sent it; the author says whose leaderboard to open.
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
