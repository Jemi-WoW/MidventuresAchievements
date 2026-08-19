local _, ns = ...
if ns.disabled then return end

local leaderboard = ns.Leaderboard
local pane = AchievementFrameAchievements
local detail = leaderboard.detail

-- The same list as icons, with two buttons in the detail strip to pick between them.
leaderboard.LAYOUT_LIST, leaderboard.LAYOUT_GRID = 'list', 'grid'
leaderboard.layout = ns.Setting('leaderboardLayout')

local ICON, CELL, SPACING = 40, 58, 6
local ICON_FRAME = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-IconFrame'
local CATEGORY_BG = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-Category-Background'
local CATEGORY_HIGHLIGHT = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-Category-Highlight'
local WHITE = 'Interface\\Buttons\\WHITE8X8'

local SELECTED, UNSELECTED = { 1, 1, 1 }, { 1, 0.82, 0 }

local STEP = CELL + SPACING

-- The same corners the list container is given, so both views fill the pane identically.
local grid = CreateFrame('ScrollFrame', 'MidventuresLeaderboardGrid', pane)
grid:SetPoint('TOPLEFT', 4, -3 - leaderboard.STRIP_HEIGHT)
grid:SetPoint('BOTTOMRIGHT', 0, 5)
grid:Hide()

local content = CreateFrame('Frame', nil, grid)
content:SetSize(1, 1)
grid:SetScrollChild(content)

-- Built from the list's own template, so it is the same widget with the same art.
local function makeScrollBar()
    for _, template in ipairs({ 'HybridScrollBarTemplate', 'UIPanelScrollBarTrimTemplate',
        'UIPanelScrollBarTemplate' }) do
        local ok, bar = pcall(CreateFrame, 'Slider', 'MidventuresLeaderboardGridScrollBar',
            grid, template)
        if ok and bar then return bar end
    end
end

local scrollBar = makeScrollBar()

local function scrollTo(value)
    if not scrollBar then return end
    local lowest, highest = scrollBar:GetMinMaxValues()
    scrollBar:SetValue(math.max(lowest, math.min(value, highest)))
end

if scrollBar then
    -- Replaced before anything can move the bar: the template's drive a hybrid list.
    scrollBar:SetScript('OnValueChanged', function(_, value) grid:SetVerticalScroll(value) end)

    local up = scrollBar.ScrollUpButton or _G['MidventuresLeaderboardGridScrollBarScrollUpButton']
    local down = scrollBar.ScrollDownButton or _G['MidventuresLeaderboardGridScrollBarScrollDownButton']
    if up then up:SetScript('OnClick', function() scrollTo(scrollBar:GetValue() - STEP) end) end
    if down then down:SetScript('OnClick', function() scrollTo(scrollBar:GetValue() + STEP) end) end

    -- Where the list hangs its own: off the right edge, arrows tucked in top and bottom.
    scrollBar:ClearAllPoints()
    scrollBar:SetPoint('TOPLEFT', grid, 'TOPRIGHT', 1, -16)
    scrollBar:SetPoint('BOTTOMLEFT', grid, 'BOTTOMRIGHT', 1, 12)
    scrollBar:SetMinMaxValues(0, 0)
    scrollBar:SetValueStep(1)
    scrollBar:SetValue(0)

    -- The dark groove behind the thumb, which the template ships hidden.
    if scrollBar.trackBG then
        scrollBar.trackBG:Show()
        scrollBar.trackBG:SetVertexColor(0, 0, 0, 1)
    end
end

grid:EnableMouseWheel(true)
grid:SetScript('OnMouseWheel', function(_, delta)
    if scrollBar then scrollTo(scrollBar:GetValue() - delta * STEP) end
end)

-- A window the player resizes, or a first draw, changes how many columns fit.
grid:SetScript('OnSizeChanged', function(self)
    if self:IsShown() and leaderboard.RefreshGrid then leaderboard.RefreshGrid() end
end)

-- Ours rather than the viewed player's, the same question ui/leaderboard/Mine.lua asks.
local function earnedByMe(id)
    local completion = CA_CompletionManager and CA_CompletionManager:GetLocal()
    return completion and completion:IsAchievementCompleted(id) or false
end

local function tileTooltip(self)
    if not self.id then return end

    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(self.title, 1, 1, 1)
    if self.description then GameTooltip:AddLine(self.description, nil, nil, nil, true) end
    if self.earned then
        GameTooltip:AddLine(('Earned %s'):format(self.earned), 0.6, 0.6, 0.6)
    end
    GameTooltip:AddDoubleLine(ns.POINTS_LABEL, self.points or 0, 1, 0.82, 0, 1, 1, 1)
    if not self.mine then
        GameTooltip:AddLine('You do not have this one.', 1, 0.4, 0.4)
    end
    GameTooltip:Show()
end

local tiles = {}

local function newTile()
    local tile = CreateFrame('Button', nil, content)
    tile:SetSize(CELL, CELL)

    tile.icon = tile:CreateTexture(nil, 'ARTWORK')
    tile.icon:SetSize(ICON, ICON)
    tile.icon:SetPoint('CENTER')

    -- The same frame the list rows wear, at the same ratio to the icon inside it.
    tile.art = tile:CreateTexture(nil, 'OVERLAY')
    tile.art:SetTexture(ICON_FRAME)
    tile.art:SetTexCoord(0, 0.5625, 0, 0.5625)
    tile.art:SetSize(ICON * 1.44, ICON * 1.44)
    tile.art:SetPoint('CENTER', -1, 1)

    tile:SetScript('OnEnter', tileTooltip)
    tile:SetScript('OnLeave', function() GameTooltip:Hide() end)
    tile:SetScript('OnClick', function(self)
        if self.id then ns.JumpToLeaderboardAchievement(self.id) end
    end)
    return tile
end

-- One tile per achievement, laid out left to right in as many columns as the pane fits.
function leaderboard.RefreshGrid()
    local list = leaderboard.List()
    -- The pane answers for the width until the grid has been through a layout pass itself.
    local width = grid:GetWidth()
    if width < CELL then width = pane:GetWidth() - 42 end

    local columns = math.max(1, math.floor((width + SPACING) / STEP))
    -- Leftover width is shared out as equal gaps rather than left on the right.
    local gap = math.max(SPACING, (width - columns * CELL) / (columns + 1))
    local mine = ns.Roster.IsMe(leaderboard.record)

    for index, achievement in ipairs(list) do
        local tile = tiles[index] or newTile()
        tiles[index] = tile

        local row, column = math.floor((index - 1) / columns), (index - 1) % columns
        tile:ClearAllPoints()
        tile:SetPoint('TOPLEFT', gap + column * (CELL + gap), -row * STEP)

        local id, name, points, _, month, day, year, description, _, icon =
            GetAchievementInfo(achievement.id)
        tile.id, tile.title, tile.description, tile.points = id, name, description, points
        tile.earned = month and ('%d/%d/%d'):format(month, day, year) or nil
        tile.mine = mine or earnedByMe(achievement.id)

        tile.icon:SetTexture(icon)
        -- Greyed means you have not earned it, so a glance says who is ahead of whom.
        tile.icon:SetDesaturated(not tile.mine)
        tile:Show()
    end

    for index = #list + 1, #tiles do tiles[index]:Hide() end

    local rows = math.ceil(#list / columns)
    local height = math.max(1, rows * STEP)
    content:SetSize(width, height)

    -- The bar covers whatever does not fit, and steps aside when everything does.
    if scrollBar then
        local range = math.max(0, height - grid:GetHeight())
        scrollBar:SetMinMaxValues(0, range)
        scrollTo(scrollBar:GetValue())
        if range > 0 then scrollBar:Show() else scrollBar:Hide() end
    end
end

local listButton, gridButton
local shownKey

local function paintButtons()
    for _, button in ipairs({ listButton, gridButton }) do
        local color = button.layout == leaderboard.layout and SELECTED or UNSELECTED
        for _, mark in ipairs(button.marks) do
            mark:SetVertexColor(color[1], color[2], color[3])
        end
        if button.layout == leaderboard.layout then
            button:LockHighlight()
        else
            button:UnlockHighlight()
        end
    end
end

-- Which of the two is on screen. An empty list stays a list, where the note lives.
function leaderboard.ApplyLayout()
    local showGrid = ns.leaderboard and leaderboard.layout == leaderboard.LAYOUT_GRID
        and leaderboard.record ~= nil and #leaderboard.List() > 0

    if showGrid then
        AchievementFrameAchievementsContainer:Hide()
        leaderboard.RefreshGrid()
        grid:Show()
        -- A frame never shown has no width, so the columns are worked out again now.
        leaderboard.RefreshGrid()

        -- A different player, or their other section, starts at the top of their tiles.
        local key = leaderboard.record.name .. '/' .. (leaderboard.section or '')
        if key ~= shownKey then
            shownKey = key
            if scrollBar then scrollBar:SetValue(0) end
        end
    else
        grid:Hide()
        if ns.leaderboard and leaderboard.record then
            AchievementFrameAchievementsContainer:Show()
        end
    end
    paintButtons()
end

function leaderboard.SetLayout(layout)
    if leaderboard.layout == layout then return end

    leaderboard.layout = layout
    ns.SetSetting('leaderboardLayout', layout)
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    leaderboard.ApplyLayout()
end

-- Three bars and four squares, drawn flat; the glyph drops with the background.
local GLYPH_DROP = -2

local function mark(button, width, height, x, y)
    local texture = button:CreateTexture(nil, 'ARTWORK')
    texture:SetTexture(WHITE)
    texture:SetSize(width, height)
    texture:SetPoint('CENTER', x, y + GLYPH_DROP)
    return texture
end

local function listMarks(button)
    local marks = {}
    for _, y in ipairs({ 4, 0, -4 }) do
        marks[#marks + 1] = mark(button, 2, 2, -5, y)
        marks[#marks + 1] = mark(button, 8, 2, 2, y)
    end
    return marks
end

-- Four squares with a pixel between them.
local function gridMarks(button)
    return {
        mark(button, 5, 5, -3, 3), mark(button, 5, 5, 3, 3),
        mark(button, 5, 5, -3, -3), mark(button, 5, 5, 3, -3),
    }
end

-- Same art as the section buttons beside them, so the row reads as one strip.
local function layoutButton(layout, label, marks)
    local button = CreateFrame('Button', nil, detail)
    button:SetSize(24, 24)

    local background = button:CreateTexture(nil, 'BACKGROUND')
    background:SetTexture(CATEGORY_BG)
    background:SetTexCoord(0, 0.6640625, 0, 1)
    background:SetPoint('TOPLEFT')
    background:SetPoint('BOTTOMRIGHT', 0, -7)

    button:SetHighlightTexture(CATEGORY_HIGHLIGHT)
    local highlight = button:GetHighlightTexture()
    highlight:SetBlendMode('ADD')
    highlight:SetTexCoord(0, 0.6640625, 0, 1)
    highlight:ClearAllPoints()
    highlight:SetPoint('TOPLEFT')
    highlight:SetPoint('BOTTOMRIGHT', -1, -7)

    button.marks = marks(button)
    button.layout = layout
    button:SetScript('OnClick', function(self) leaderboard.SetLayout(self.layout) end)
    button:SetScript('OnEnter', function(self)
        GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
        GameTooltip:SetText(label, 1, 1, 1)
        GameTooltip:Show()
    end)
    button:SetScript('OnLeave', function() GameTooltip:Hide() end)
    return button
end

gridButton = layoutButton(leaderboard.LAYOUT_GRID, 'Grid', gridMarks)
gridButton:SetPoint('TOPRIGHT', detail, 'TOPRIGHT', -16, -60)

listButton = layoutButton(leaderboard.LAYOUT_LIST, 'List', listMarks)
listButton:SetPoint('TOPRIGHT', gridButton, 'TOPLEFT', -6, 0)

paintButtons()
