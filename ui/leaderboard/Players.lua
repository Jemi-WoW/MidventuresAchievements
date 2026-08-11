local _, ns = ...
if ns.disabled then return end

local leaderboard = ns.Leaderboard

local CLASS_ICONS = 'Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES'
local TINY_SHIELD = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-TinyShield'
-- The friends list' own dots, so online means the same thing in both windows.
local STATUS_ONLINE = 'Interface\\FriendsFrame\\StatusIcon-Online'
local STATUS_OFFLINE = 'Interface\\FriendsFrame\\StatusIcon-Offline'

-- Player rows always carry a status dot, and a class icon whenever we know the class.
local LABEL_INSET, LABEL_INSET_WITH_DOT, LABEL_INSET_WITH_BOTH = 16, 22, 40
local LABEL_RIGHT, LABEL_RIGHT_WITH_POINTS = -8, -52

-- Ranked ids, in the order the sidebar should list them.
function leaderboard.CategoryIDs()
    local ids = {}
    for _, record in ipairs(ns.Roster.Get()) do
        ids[#ids + 1] = leaderboard.CategoryID(record.name)
    end
    return ids
end

-- Why the sidebar is empty, said in the sidebar itself.
local message = AchievementFrameCategories:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
message:SetPoint('TOPLEFT', 18, -22)
message:SetPoint('TOPRIGHT', -18, -22)
message:SetJustifyH('CENTER')
message:Hide()
leaderboard.sidebarMessage = message

function leaderboard.UpdateSidebarMessage()
    if not ns.leaderboard then
        message:Hide()
        return
    end

    if not IsInGuild() then
        message:SetText('You are not in a guild.')
    elseif #ns.Roster.Get() == 0 then
        message:SetText('No one in the guild is running Midventures Achievements yet.')
    else
        message:Hide()
        return
    end
    message:Show()
end

-- Online state, in the leftmost slot the friends list puts it in too.
local function statusDot(button)
    if not button.mvStatus then
        local dot = button:CreateTexture(nil, 'ARTWORK')
        dot:SetSize(14, 14)
        -- Same drop as the score, for the row background hanging 7px low.
        dot:SetPoint('LEFT', 4, -3)
        button.mvStatus = dot
    end
    return button.mvStatus
end

local function classIcon(button)
    if not button.mvClassIcon then
        local icon = button:CreateTexture(nil, 'ARTWORK')
        icon:SetSize(16, 16)
        -- Sits right of the status dot, dropped the same 3px as everything else.
        icon:SetPoint('LEFT', 20, -3)
        button.mvClassIcon = icon
    end
    return button.mvClassIcon
end

-- Combined score, right of the name, wearing the same shield as the point plates.
local function pointsText(button)
    if not button.mvPoints then
        local shield = button:CreateTexture(nil, 'ARTWORK')
        shield:SetTexture(TINY_SHIELD)
        shield:SetTexCoord(0, 0.625, 0, 0.625)
        shield:SetSize(13, 13)
        -- The row's background hangs 7px low, so its visible middle sits below centre.
        shield:SetPoint('RIGHT', -12, -3)
        button.mvShield = shield

        local text = button:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
        text:SetPoint('RIGHT', shield, 'LEFT', -2, 1)
        text:SetJustifyH('RIGHT')
        button.mvPoints = text
    end
    return button.mvPoints
end

local function playerTooltip(self)
    local record = leaderboard.RecordFor(self.categoryID)
    if not record then return end

    GameTooltip_SetDefaultAnchor(GameTooltip, self)
    GameTooltip:SetText(record.name, 1, 1, 1)
    if record.level and record.className then
        GameTooltip:AddLine(('Level %d %s'):format(record.level, record.className), 0.8, 0.8, 0.8)
    end
    local annPoints, midiPoints = record.annPoints or 0, record.midiPoints or 0
    GameTooltip:AddDoubleLine(ns.ANNIVERSARY_LABEL, BreakUpLargeNumbers(annPoints), 1, 0.82, 0, 1, 1, 1)
    GameTooltip:AddDoubleLine(ns.POINTS_LABEL, BreakUpLargeNumbers(midiPoints), 1, 0.82, 0, 1, 1, 1)

    -- The combined score, which is what ranks the list.
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine('Total', BreakUpLargeNumbers(annPoints + midiPoints), 1, 1, 1, 1, 1, 1)
    if not record.online and not record.isPlayer then
        GameTooltip:AddLine('Offline - last known score.', 0.6, 0.6, 0.6)
    end
    GameTooltip:Show()
end

local CATEGORY_COLOR = { 1, 0.82, 0 }

function leaderboard.PaintCategoryRow(button)
    if button and button.label then
        button.label:SetTextColor(unpack(CATEGORY_COLOR))
    end
end

-- Every row put back at once, for leaving the leaderboard without waiting for a redraw.
function leaderboard.PaintCategoryRows()
    local container = AchievementFrameCategoriesContainer
    for _, button in next, (container and container.buttons) or {} do
        leaderboard.PaintCategoryRow(button)
    end
end

-- Player rows get a status dot, a class icon and a class-coloured name; everything else is untouched.
local baseDisplayButton = AchievementFrameCategories_DisplayButton

AchievementFrameCategories_DisplayButton = function(button, element)
    baseDisplayButton(button, element)
    if not (element and button.element) then return end

    local record = leaderboard.RecordFor(element.id)
    if not record then
        if button.mvClassIcon then button.mvClassIcon:Hide() end
        if button.mvStatus then button.mvStatus:Hide() end
        if button.mvPoints then
            button.mvPoints:Hide()
            button.mvShield:Hide()
        end
        button.label:SetPoint('BOTTOMLEFT', LABEL_INSET, 4)
        button.label:SetPoint('TOPRIGHT', LABEL_RIGHT, -4)
        leaderboard.PaintCategoryRow(button)
        return
    end

    -- Our own row is always online, whether or not the guild roster has landed yet.
    local online = record.online or record.isPlayer
    local dot = statusDot(button)
    dot:SetTexture(online and STATUS_ONLINE or STATUS_OFFLINE)
    dot:Show()

    local icon = classIcon(button)
    local coords = record.class and CLASS_ICON_TCOORDS[record.class]
    if coords then
        icon:SetTexture(CLASS_ICONS)
        icon:SetTexCoord(unpack(coords))
        icon:Show()
        button.label:SetPoint('BOTTOMLEFT', LABEL_INSET_WITH_BOTH, 4)
    else
        icon:Hide()
        button.label:SetPoint('BOTTOMLEFT', LABEL_INSET_WITH_DOT, 4)
    end

    local points = pointsText(button)
    points:SetText(BreakUpLargeNumbers((record.annPoints or 0) + (record.midiPoints or 0)))
    points:Show()
    button.mvShield:Show()
    button.label:SetPoint('TOPRIGHT', LABEL_RIGHT_WITH_POINTS, -4)

    local color = record.class and RAID_CLASS_COLORS[record.class]
    button.label:SetTextColor(color and color.r or 1, color and color.g or 0.82, color and color.b or 0)
    icon:SetDesaturated(not online)

    button.name = record.name
    button.showTooltipFunc = playerTooltip
end
