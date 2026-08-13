local _, ns = ...
if ns.disabled then return end

local leaderboard = ns.Leaderboard

-- Guildmates stagger their answers by up to six seconds, so the wait covers that.
local WINDOW = 9
local SETTLE = 3

local button = CreateFrame('Button', 'MidventuresLeaderboardRefresh', AchievementFrameHeader,
    'UIPanelButtonTemplate')
button:SetSize(88, 22)
button:SetPoint('BOTTOMLEFT', AchievementFrameHeader, 'BOTTOMLEFT', 128, 28)
button:SetText('Refresh')
button:Hide()

local status = button:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
status:SetPoint('BOTTOM', button, 'TOP', 0, 3)
status:Hide()

local busy = false

local function redraw()
    if not ns.leaderboard then return end
    ns.Roster.Invalidate()
    AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES)
    AchievementFrameCategories_Update()
    AchievementFrameAchievements_ForceUpdate()
    ns.leaderboardFunctions.updateFunc()
end

local function finish()
    busy = false
    button:Enable()
    status:SetText('|cff40ff40Up to date.|r')
    redraw()
    C_Timer.After(SETTLE, function()
        if not busy then status:Hide() end
    end)
end

local function refresh()
    if busy or not ns.leaderboard then return end
    busy = true
    button:Disable()
    status:SetText('|cffffff00Refreshing the guild...|r')
    status:Show()

    ns.Sync.RequestGuildRoster()
    ns.Roster.RefreshSelf()
    ns.Roster.MergeGuildRoster()
    -- Everyone reports their points, and the player on screen sends their list again.
    ns.Sync.Ping(true)
    ns.Sync.BroadcastPoints(true)
    if leaderboard.record then ns.Sync.RequestDetail(leaderboard.record, true) end

    -- Answers trickle in, so the view is redrawn part way through as well.
    C_Timer.After(1, function()
        ns.Roster.MergeGuildRoster()
        redraw()
    end)
    C_Timer.After(WINDOW / 2, redraw)
    C_Timer.After(WINDOW, finish)
end

button:SetScript('OnClick', refresh)
button:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_BOTTOM')
    GameTooltip:SetText('Refresh', 1, 1, 1)
    GameTooltip:AddLine('Ask the guild for names, points and achievements again.',
        nil, nil, nil, true)
    if busy then GameTooltip:AddLine('Already refreshing.', 1, 0.4, 0.4) end
    GameTooltip:Show()
end)
button:SetScript('OnLeave', function() GameTooltip:Hide() end)

-- The button belongs to the leaderboard, so it comes and goes with it.
local baseShow = ns.ShowLeaderboard
ns.ShowLeaderboard = function()
    baseShow()
    if ns.leaderboard then button:Show() end
end

local baseHide = ns.HideLeaderboard
ns.HideLeaderboard = function()
    baseHide()
    button:Hide()
    status:Hide()
end
