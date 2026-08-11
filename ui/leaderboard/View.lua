local _, ns = ...
if ns.disabled then return end

local db = CA_Database
local frame = AnniversaryAchievements_GetAchievementFrame()
local leaderboard = ns.Leaderboard
local detail = leaderboard.detail

local savedFilter = nil

local function hideFilterDropDown()
    AchievementFrameFilterDropDown:Hide()
    AchievementFrameHeaderLeftDDLInset:Hide()
end

-- Roster tables are reused in place, so the selected id always resolves to the live record.
local function syncRecord()
    local id = ns.leaderboardFunctions.selectedCategory
    local record = id and leaderboard.RecordFor(id) or nil
    leaderboard.SetRecord(record)
    if record then ns.Sync.RequestDetail(record) end
end

-- Anniversary's list update indexes the last sidebar row, so it must never run empty.
local function updateView()
    syncRecord()
    hideFilterDropDown()
    AchievementFrameAchievementsFeatOfStrengthText:Hide()
    leaderboard.UpdateSidebarMessage()

    if not leaderboard.record then
        AchievementFrameAchievementsContainer:Hide()
        detail:Hide()
        return
    end

    AchievementFrameAchievementsContainer:Show()
    AchievementFrameAchievements_Update()
    detail.Refresh()
end

local leaderboardFunctions = {
    noSummary = true,
    categoryAccessor = function() return leaderboard.CategoryIDs() end,
    clearFunc = AchievementFrameAchievements_ClearSelection,
    updateFunc = updateView,
    selectedCategory = nil,
}
ns.leaderboardFunctions = leaderboardFunctions

-- Where a guild chat link lands. Both halves are held onto rather than used once:
-- a guildmate who has never spoken to us is not in the roster yet,
-- and their achievements follow their name by a second or two.
local PENDING_TIMEOUT = 60
local pending, chasing = nil, false

local function rowFor(achievementID)
    for _, button in next, AchievementFrameAchievementsContainer.buttons do
        if button.id == achievementID and button:IsShown() then return button end
    end
end

local function indexOf(achievementID)
    for index, achievement in ipairs(leaderboard.List()) do
        if achievement.id == achievementID then return index end
    end
end

-- Scrolls an achievement into view and opens it.
local function jumpTo(achievementID)
    local index = indexOf(achievementID)
    if not index then return false end

    local container = AchievementFrameAchievementsContainer
    local scrollBar = AchievementFrameAchievementsContainerScrollBar

    AchievementFrameAchievements_Update()
    local _, furthest = scrollBar:GetMinMaxValues()
    scrollBar:SetValue(math.min((index - 1) * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT, furthest))
    AchievementFrameAchievements_Update()

    local row = rowFor(achievementID)
    if not row then return false end
    -- The last argument is what keeps a shift-click from linking it instead of opening it.
    if not row.selected then AchievementButton_OnClick(row, nil, nil, true) end

    -- Opening it pushed everything below it down, so it goes back to the top afterwards.
    row = rowFor(achievementID)
    if row then
        local _, highest = scrollBar:GetMinMaxValues()
        local wanted = scrollBar:GetValue() + container:GetTop() - row:GetTop()
        scrollBar:SetValue(math.max(0, math.min(wanted, highest)))
    end
    return true
end

local function followPending()
    if not pending then return end
    if GetTime() - pending.at > PENDING_TIMEOUT then pending = nil return end

    local record = ns.Roster.Find(pending.name)
    if not record then return end

    local categoryID = leaderboard.CategoryID(record.name)
    if leaderboardFunctions.selectedCategory ~= categoryID then
        leaderboardFunctions.selectedCategory = categoryID
        AchievementFrameCategories_Update()
        AchievementFrameAchievements_ForceUpdate()
        updateView()
    end

    if not pending.id then pending = nil return end
    if jumpTo(pending.id) then pending = nil end
end

-- Both halves can arrive over the wire, so this keeps trying until they have or the wait runs out.
local function chase()
    chasing = false
    if not (ns.leaderboard and frame:IsShown()) then
        pending = nil
        return
    end

    followPending()
    if pending then
        chasing = true
        C_Timer.After(1, chase)
    end
end

local function setListInset(inset)
    local container = AchievementFrameAchievementsContainer
    container:ClearAllPoints()
    container:SetPoint('TOPLEFT', 4, -3 - inset)
    container:SetPoint('BOTTOMRIGHT', 0, 5)
end

-- Search should look in whichever section is on screen.
local function applySearchTab()
    db:SetSelectedTab(leaderboard.section == ns.SECTION_MIDVENTURES and ns.TAB_ID or db.TAB_ID_PLAYER)
end

local function selectFirstPlayer()
    local ids = leaderboard.CategoryIDs()
    leaderboardFunctions.selectedCategory = ids[1]
end

local REFRESH_EVERY = 10
local PING_EVERY = 60
local refreshing, lastPinged = false, 0

local function refresh()
    refreshing = false
    if not (ns.leaderboard and frame:IsShown()) then return end

    ns.Roster.MergeGuildRoster()
    if GetTime() - lastPinged >= PING_EVERY then
        lastPinged = GetTime()
        ns.Sync.RequestGuildRoster()
        ns.Sync.Ping(true)
    end
    updateView()

    refreshing = true
    C_Timer.After(REFRESH_EVERY, refresh)
end

function ns.ShowLeaderboard()
    if ns.leaderboard then return end

    -- Open on whichever side you were already looking at.
    leaderboard.SetSection(ns.active and ns.SECTION_MIDVENTURES or ns.SECTION_ANNIVERSARY)
    ns.HideMidventures()

    ns.leaderboard = true
    ACHIEVEMENT_FUNCTIONS = leaderboardFunctions

    ns.Roster.RefreshSelf()
    ns.Roster.MergeGuildRoster()
    ns.Sync.RequestGuildRoster()
    ns.Sync.Ping()
    -- Ask twice, so a guildmate who was zoning when we opened still turns up.
    C_Timer.After(5, function() if ns.leaderboard then ns.Sync.Ping(true) end end)
    selectFirstPlayer()

    -- Rebinds Anniversary's file-local achievementFunctions to ours.
    ns.baseTabOnClick(1)
    applySearchTab()

    -- Everything listed is already earned, so the complete/incomplete filter has no meaning.
    savedFilter = AchievementFrameFilterDropDown.value or ACHIEVEMENT_FILTER_ALL
    AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL)

    -- Our own tab owns this view, exactly like the other two own theirs.
    PanelTemplates_Tab_OnClick(ns.LeaderboardTab, frame)
    ns.UpdateTabText()

    AchievementFrameHeaderTitle:SetText(ns.LEADERBOARD_LABEL)
    AchievementFrameHeaderPoints:SetText('')
    AchievementFrameHeaderShield:Hide()
    AchievementFrameHeaderPointBorder:Hide()

    setListInset(leaderboard.STRIP_HEIGHT)
    AchievementFrame_ShowSubFrame(AchievementFrameAchievements)
    AchievementFrameAchievements_ForceUpdate()
    updateView()

    lastPinged = GetTime()
    if not refreshing then
        refreshing = true
        C_Timer.After(REFRESH_EVERY, refresh)
    end
end

-- Where a guild chat link lands: the window open, on that player, on the right side of it,
-- scrolled to the achievement and opened. A player or a list we do not have yet is waited
-- for rather than given up on, which is what the chase above is for.
function ns.ShowLeaderboardFor(name, achievementID)
    if not frame:IsShown() then
        if InCombatLockdown() then
            DEFAULT_CHAT_FRAME:AddMessage('|cffffff00' .. ns.LEADERBOARD_LABEL
                .. ' cannot be opened during combat!|r')
            return
        end
        AchievementFrame_ToggleAchievementFrame()
    end

    ns.ShowLeaderboard()
    if achievementID then
        ns.SetLeaderboardSection(ns.Owns(achievementID)
            and ns.SECTION_MIDVENTURES or ns.SECTION_ANNIVERSARY)
    end

    pending = name and { name = ns.Roster.PlainName(name), id = achievementID, at = GetTime() } or nil
    if pending and not ns.Roster.Find(pending.name) then
        -- Never heard of them, so ask the guild now rather than wait for whatever they
        -- earn next to introduce them.
        ns.Sync.RequestGuildRoster()
        ns.Sync.Ping(true)
    end

    followPending()
    if pending and not chasing then
        chasing = true
        C_Timer.After(1, chase)
    end
end

-- Leaves leaderboard state behind without picking the next view; callers do that.
function ns.HideLeaderboard()
    if not ns.leaderboard then return end

    ns.leaderboard = false
    ACHIEVEMENT_FUNCTIONS = ns.anniversaryFunctions
    leaderboard.SetRecord(nil)
    -- Class colours belong to player rows, and there are none outside this view.
    leaderboard.PaintCategoryRows()

    detail:Hide()
    leaderboard.sidebarMessage:Hide()
    leaderboard.listMessage:Hide()
    AchievementFrameAchievementsContainer:Show()
    setListInset(0)
    AchievementFrameHeaderShield:Show()
    AchievementFrameHeaderPointBorder:Show()
    AchievementFrameAchievementsFeatOfStrengthText:Hide()
    if savedFilter then
        AchievementFrame_SetFilter(savedFilter)
        savedFilter = nil
    end
    frame.selectedTab = 1
    AchievementFrameAchievements_ForceUpdate()
end

function ns.SetLeaderboardSection(section)
    if leaderboard.section == section then return end

    leaderboard.SetSection(section)
    applySearchTab()
    AchievementFrameAchievementsContainerScrollBar:SetValue(0)
    AchievementFrameAchievements_ForceUpdate()
    updateView()
end

-- Both bottom tabs leave the leaderboard, which is how you get back out of it.
local baseTabOnClickWrapper = AchievementFrameBaseTab_OnClick
AchievementFrameBaseTab_OnClick = function(id)
    ns.HideLeaderboard()
    return baseTabOnClickWrapper(id)
end
AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick

local baseShowMidventures = ns.ShowMidventures
ns.ShowMidventures = function()
    ns.HideLeaderboard()
    return baseShowMidventures()
end

-- Jumping to an achievement always means leaving someone else's list.
local baseSelectAchievement = AchievementFrame_SelectAchievement
AchievementFrame_SelectAchievement = function(id, forceSelect, isComparison)
    ns.HideLeaderboard()
    return baseSelectAchievement(id, forceSelect, isComparison)
end

-- New points or a fresh roster reorder the sidebar under us.
ns.Sync.onUpdate = function(record)
    if not (ns.leaderboard and frame:IsShown()) then return end

    ns.Roster.Invalidate()
    AchievementFrameCategories_GetCategoryList(ACHIEVEMENTUI_CATEGORIES)

    -- Guildmates answering the opening ping should not leave the pane empty.
    local autoSelected = false
    if not leaderboardFunctions.selectedCategory then
        selectFirstPlayer()
        autoSelected = leaderboardFunctions.selectedCategory ~= nil
    end
    AchievementFrameCategories_Update()

    if not autoSelected and record and record ~= leaderboard.record then return end
    AchievementFrameAchievements_ForceUpdate()
    updateView()
end

-- Reopen where you left off, the way the Midventures view already does.
local reopenOnLeaderboard = false

frame:HookScript('OnHide', function()
    reopenOnLeaderboard = ns.leaderboard
    ns.HideLeaderboard()
end)

local baseToggle = AchievementFrame_ToggleAchievementFrame
AchievementFrame_ToggleAchievementFrame = function(toggleStatFrame, toggleGuildView)
    baseToggle(toggleStatFrame, toggleGuildView)
    if reopenOnLeaderboard and not toggleStatFrame and frame:IsShown() then
        ns.ShowLeaderboard()
    end
end
