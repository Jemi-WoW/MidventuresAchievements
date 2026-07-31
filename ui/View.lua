local _, ns = ...
if ns.disabled then return end

local db = CA_Database
local frame = AnniversaryAchievements_GetAchievementFrame()

-- Anniversary's UI reads these globals, so swapping them switches the view.
local anniversaryFunctions = ACHIEVEMENT_FUNCTIONS
local anniversarySummaryCategories = ACHIEVEMENTUI_SUMMARYCATEGORIES
local anniversaryDefaultSummary = ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS

local midventuresFunctions = {
    categoryAccessor = function()
        local ids = {}
        for id in pairs(ns.tab:GetCategories()) do ids[#ids + 1] = id end
        table.sort(ids)
        return ids
    end,
    clearFunc = AchievementFrameAchievements_ClearSelection,
    updateFunc = function()
        AchievementFrameAchievements_Update()
        -- Our last category is never Feats of Strength.
        AchievementFrameAchievementsFeatOfStrengthText:Hide()
    end,
    selectedCategory = 'summary',
}
ns.functions = midventuresFunctions

-- Set while we drive Anniversary's tab handler ourselves.
local switching = false

local function applyHeader()
    if ns.active then
        AchievementFrameHeaderTitle:SetText(ns.POINTS_LABEL)
        AchievementFrameHeaderPoints:SetText(BreakUpLargeNumbers(ns.GetPoints()))
    else
        AchievementFrameHeaderTitle:SetText(ACHIEVEMENT_TITLE)
        AchievementFrameHeaderPoints:SetText(BreakUpLargeNumbers(GetTotalAchievementPoints()))
    end
    ns.UpdateTabText()
end

-- The summary only rebuilds in OnShow, which won't fire if it is already up.
local function refreshSummary()
    if AchievementFrameSummary:IsShown() then AchievementFrameSummary_OnShow() end
end

-- Anniversary never hides summary rows, so the other view's rows would linger.
local baseSummaryUpdate = AchievementFrameSummary_Update
AchievementFrameSummary_Update = function(...)
    local buttons = AchievementFrameSummaryAchievements.buttons
    if buttons then
        for _, button in ipairs(buttons) do button:Hide() end
    end
    baseSummaryUpdate(...)
end

local function useMidventures(enabled)
    ns.active = enabled
    ACHIEVEMENT_FUNCTIONS = enabled and midventuresFunctions or anniversaryFunctions
    ACHIEVEMENTUI_SUMMARYCATEGORIES = enabled and ns.summaryCategoryIDs or anniversarySummaryCategories
    ACHIEVEMENTUI_DEFAULTSUMMARYACHIEVEMENTS = enabled and ns.defaultSummaryAchievements or anniversaryDefaultSummary
end

function ns.ShowMidventures()
    if ns.active then return end

    switching = true
    useMidventures(true)
    -- Rebinds Anniversary's file-local achievementFunctions to ours.
    ns.baseTabOnClick(1)
    switching = false

    db:SetSelectedTab(ns.TAB_ID)
    PanelTemplates_Tab_OnClick(ns.tabButton, frame)
    applyHeader()
    refreshSummary()
end

function ns.HideMidventures()
    if not ns.active then return end

    useMidventures(false)
    ns.baseTabOnClick(1)
    applyHeader()
    refreshSummary()
end

-- Every tab switch funnels through here: tab button, keybinding, micro button.
ns.baseTabOnClick = AchievementFrameBaseTab_OnClick
AchievementFrameBaseTab_OnClick = function(id)
    if switching then return ns.baseTabOnClick(id) end

    local wasActive = ns.active
    if wasActive then useMidventures(false) end
    ns.baseTabOnClick(id)
    if wasActive then
        applyHeader()
        refreshSummary()
    end
end
AchievementFrameTab_OnClick = AchievementFrameBaseTab_OnClick

local baseComparisonTabOnClick = AchievementFrameComparisonTab_OnClick
AchievementFrameComparisonTab_OnClick = function(id)
    ns.HideMidventures()
    baseComparisonTabOnClick(id)
end

local function findRow(id)
    for _, button in next, AchievementFrameAchievementsContainer.buttons do
        if button.id == id and button:IsShown() then return button end
    end
end

-- Anniversary's SelectAchievement scroll-hunts for the row and can spin or throw.
-- Jump straight to it instead.
local function jumpToOwn(id)
    ns.ShowMidventures()

    id = AchievementFrame_FindDisplayedAchievement(id)

    -- A filtered-out row would never appear.
    local _, _, _, completed = GetAchievementInfo(id)
    if completed and ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_INCOMPLETE].func then
        AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL)
    elseif not completed and ACHIEVEMENTUI_SELECTEDFILTER == AchievementFrameFilters[ACHIEVEMENT_FILTER_COMPLETE].func then
        AchievementFrame_SetFilter(ACHIEVEMENT_FILTER_ALL)
    end

    local category = GetAchievementCategory(id)
    midventuresFunctions.selectedCategory = category
    AchievementFrame_ShowSubFrame(AchievementFrameAchievements)
    AchievementFrameCategories_ClearSelection()
    AchievementFrameCategories_Update()
    AchievementFrameAchievements_ClearSelection()

    local scrollBar = AchievementFrameAchievementsContainerScrollBar
    scrollBar:SetValue(0)
    midventuresFunctions.updateFunc()

    if not findRow(id) then
        -- Off screen: scroll straight to its row.
        for i = 1, (ACHIEVEMENTUI_SELECTEDFILTER(category)) do
            if GetAchievementInfo(category, i) == id then
                local _, maxValue = scrollBar:GetMinMaxValues()
                scrollBar:SetValue(math.min((i - 1) * ACHIEVEMENTBUTTON_COLLAPSEDHEIGHT, maxValue))
                midventuresFunctions.updateFunc()
                break
            end
        end
    end

    local row = findRow(id)
    -- true ignores modifiers, so this cannot track or link it.
    if row then AchievementButton_OnClick(row, nil, nil, true) end
end

-- Jumping to an achievement: search result, meta criteria, summary row, chat link.
local baseSelectAchievement = AchievementFrame_SelectAchievement
AchievementFrame_SelectAchievement = function(id, forceSelect, isComparison)
    if not ns.Owns(id) then
        ns.HideMidventures()
        return baseSelectAchievement(id, forceSelect, isComparison)
    end
    if not (frame:IsShown() or forceSelect) then return end

    jumpToOwn(id)
    PanelTemplates_Tab_OnClick(ns.tabButton, frame)
    applyHeader()
end

-- The expanded row caches its objectives by id, so bust that to move its bar.
-- A full redraw is only needed when a row's body changed, ie something was earned.
local function refreshList(fullRedraw)
    if not AchievementFrameAchievements:IsShown() then return end
    if fullRedraw then
        AchievementFrameAchievements_ForceUpdate()
    else
        AchievementFrameAchievementsObjectives.id = nil
        midventuresFunctions.updateFunc()
    end
end

-- Anniversary's ticker misses the header and summary, and skips partial progress.
function ns.RefreshOpenView(earnedSomething)
    if not ns.active then return end
    refreshList(earnedSomething)

    -- Points, counters and the summary only move when something is earned.
    if not earnedSomething then return end
    applyHeader()
    AchievementFrameCategories_Update()
    if AchievementFrameSummary:IsShown() then
        AchievementFrameSummary_OnShow()
    end
end

-- Remember the tab on close, but leave the view for real.
-- Otherwise Anniversary's file-local achievementFunctions stays bound to ours.
local reopenOnMidventures = false

frame:HookScript('OnHide', function()
    reopenOnMidventures = ns.active
    ns.HideMidventures()
end)

local baseToggle = AchievementFrame_ToggleAchievementFrame
AchievementFrame_ToggleAchievementFrame = function(toggleStatFrame, toggleGuildView)
    -- Anniversary only closes on toggle while tab 1 is selected.
    if not toggleStatFrame and frame:IsShown() and ns.active then
        frame.selectedTab = 1
    end

    baseToggle(toggleStatFrame, toggleGuildView)

    -- It always opens on tab 1, so switch back after.
    if reopenOnMidventures and frame:IsShown() then
        ns.ShowMidventures()
    end
end
