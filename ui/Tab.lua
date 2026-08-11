local _, ns = ...
if ns.disabled then return end

local frame = AnniversaryAchievements_GetAchievementFrame()
local frameName = frame:GetName()
local tab1 = _G[frameName .. 'Tab1']

-- Second bottom tab; the name must follow "<frame name>Tab<index>" for PanelTemplates.
local tab = CreateFrame('Button', frameName .. 'Tab2', frame, 'AchievementFrameTabButtonTemplate')
tab:SetID(2)
tab:SetText(ns.TAB_LABEL)
tab:SetPoint('LEFT', tab1, 'RIGHT', -5, 0)
tab:SetScript('OnClick', function()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    ns.ShowMidventures()
end)
PanelTemplates_TabResize(tab, 10)

-- PanelTemplates defaults the text too high and Anniversary only corrects tab 1.
local TEXT_Y_SELECTED, TEXT_Y_DESELECTED = -5, -3
for _, t in ipairs({ tab1, tab }) do
    t.selectedTextY = TEXT_Y_SELECTED
    t.deselectedTextY = TEXT_Y_DESELECTED
end

-- Fallback for clients whose PanelTemplates ignores those fields.
function ns.UpdateTabText()
    local midventures = ns.active and not ns.leaderboard
    local anniversary = not ns.active and not ns.leaderboard
    tab1.text:SetPoint('CENTER', 0, anniversary and TEXT_Y_SELECTED or TEXT_Y_DESELECTED)
    tab.text:SetPoint('CENTER', 0, midventures and TEXT_Y_SELECTED or TEXT_Y_DESELECTED)
end

PanelTemplates_SetNumTabs(frame, 2)
PanelTemplates_UpdateTabs(frame)
ns.UpdateTabText()

-- Anniversary mirrors its $parent globals onto AchievementFrame* aliases.
AnniversaryAchievements_RefreshFrameAliases()

ns.tabButton = tab
