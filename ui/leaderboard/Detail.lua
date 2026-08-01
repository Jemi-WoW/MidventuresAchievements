local _, ns = ...
if ns.disabled then return end

local leaderboard = ns.Leaderboard
local pane = AchievementFrameAchievements

local HEADER = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-Header'
local TINY_SHIELD = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-TinyShield'
local CATEGORY_BG = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-Category-Background'
local CATEGORY_HIGHLIGHT = 'Interface\\AddOns\\AnniversaryAchievements\\textures\\UI-Achievement-Category-Highlight'

local STRIP_HEIGHT = 88
leaderboard.STRIP_HEIGHT = STRIP_HEIGHT

local detail = CreateFrame('Frame', 'MidventuresLeaderboardDetail', pane)
detail:SetPoint('TOPLEFT', 4, -3)
detail:SetPoint('TOPRIGHT', -4, -3)
detail:SetHeight(STRIP_HEIGHT)
detail:Hide()
leaderboard.detail = detail

detail.name = detail:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
detail.name:SetPoint('TOPLEFT', 16, -14)
detail.name:SetJustifyH('LEFT')
detail.name:SetWidth(190)

detail.subtitle = detail:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
detail.subtitle:SetPoint('TOPLEFT', detail.name, 'BOTTOMLEFT', 0, -4)
detail.subtitle:SetJustifyH('LEFT')
detail.subtitle:SetWidth(190)

-- The same plate the window header uses for its points total.
local function createPlate(label)
    local plate = CreateFrame('Frame', nil, detail)
    plate:SetSize(133, 39)

    local border = plate:CreateTexture(nil, 'BORDER')
    border:SetTexture(HEADER)
    border:SetTexCoord(0.419921875, 0.6796875, 0.4140625, 0.56640625)
    border:SetAllPoints()

    plate.title = plate:CreateFontString(nil, 'BORDER', 'GameFontNormal')
    plate.title:SetPoint('TOP', 0, 7)
    plate.title:SetText(label)

    plate.value = plate:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
    plate.value:SetPoint('TOP', 0, -13)

    plate.shield = plate:CreateTexture(nil, 'ARTWORK')
    plate.shield:SetTexture(TINY_SHIELD)
    plate.shield:SetTexCoord(0, 0.625, 0, 0.625)
    plate.shield:SetSize(20, 20)
    plate.shield:SetPoint('LEFT', plate.value, 'RIGHT', 3, -1)

    return plate
end

detail.midiPlate = createPlate(ns.POINTS_LABEL)
detail.midiPlate:SetPoint('TOPRIGHT', -16, -20)

detail.annPlate = createPlate(ns.ANNIVERSARY_LABEL)
detail.annPlate:SetPoint('TOPRIGHT', detail.midiPlate, 'TOPLEFT', -10, 0)

-- Sidebar art reused as a section picker, so it reads as part of the same window.
local function createSectionButton(label, section)
    local button = CreateFrame('Button', nil, detail)
    button:SetSize(150, 24)

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

    -- The background hangs 7px below the button, so centring needs that offset back.
    button.label = button:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    button.label:SetPoint('CENTER', 0, -2)
    button.label:SetText(label)

    button.section = section
    button:SetScript('OnClick', function(self)
        PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
        ns.SetLeaderboardSection(self.section)
    end)

    return button
end

detail.annButton = createSectionButton('Anniversary', ns.SECTION_ANNIVERSARY)
detail.annButton:SetPoint('TOPLEFT', 16, -60)

detail.midiButton = createSectionButton(ns.TAB_LABEL, ns.SECTION_MIDVENTURES)
detail.midiButton:SetPoint('LEFT', detail.annButton, 'RIGHT', 10, 0)

function detail.Refresh()
    local record = leaderboard.record
    if not record then
        detail:Hide()
        return
    end

    local color = record.class and RAID_CLASS_COLORS[record.class]
    detail.name:SetText(record.name)
    detail.name:SetTextColor(color and color.r or 1, color and color.g or 0.82, color and color.b or 0)

    if record.level and record.className then
        detail.subtitle:SetText(('Level %d %s'):format(record.level, record.className))
    else
        detail.subtitle:SetText(record.online and 'Online' or '')
    end

    detail.annPlate.value:SetText(BreakUpLargeNumbers(record.annPoints or 0))
    detail.midiPlate.value:SetText(BreakUpLargeNumbers(record.midiPoints or 0))

    for _, button in ipairs({ detail.annButton, detail.midiButton }) do
        if button.section == leaderboard.section then
            button:LockHighlight()
            button.label:SetTextColor(1, 1, 1)
        else
            button:UnlockHighlight()
            button.label:SetTextColor(1, 0.82, 0)
        end
    end

    detail:Show()
end
