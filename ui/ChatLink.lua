local _, ns = ...
if ns.disabled then return end

-- Guild chat carries the achievement as plain text, because the server strips hyperlinks
-- it does not recognise. Each client with the addon turns that text back into a link, and
-- anyone without it still reads a sensible sentence.
local LINK = '|cffffff00|Hgarrmission:mvach:%d#%s|h[%s]|h|r'

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
local function relink(_, _, message, ...)
    local player, name = ns.ParseAnnouncement(message)
    if not player then return false end

    local achievementID = achievementByName(name)
    if not achievementID then return false end

    local link = LINK:format(achievementID, player, name)
    return false, ns.Announcement(player, link), ...
end

ChatFrame_AddMessageEventFilter('CHAT_MSG_GUILD', relink)

-- Anniversary hooks the same function for its own `clach` links and leaves ours alone.
hooksecurefunc('SetItemRef', function(link)
    local linkType, addon, params = strsplit(':', link)
    if linkType ~= 'garrmission' or addon ~= 'mvach' or not params then return end

    local achievementID, player = strsplit('#', params)
    ns.ShowLeaderboardFor(player, tonumber(achievementID))
end)
