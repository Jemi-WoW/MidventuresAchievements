local _, ns = ...
if ns.disabled then return end

local frame = AnniversaryAchievements_GetAchievementFrame()
local frameName = frame:GetName()

local ICON = 'Interface\\Icons\\INV_Letter_03'
local WIDTH = 64

-- Third bottom tab, hard right, carrying the icon where the others carry a label.
local tab = CreateFrame('Button', frameName .. 'Tab3', frame, 'AchievementFrameTabButtonTemplate')
tab:SetID(3)
tab:SetText('')
tab:SetPoint('BOTTOMRIGHT', frame, 'BOTTOMRIGHT', -11, -30)

-- The template sizes itself from its text, which we do not have.
local function sizeTab(self)
    local name = self:GetName()
    local middle = WIDTH - _G[name .. 'Left']:GetWidth() - _G[name .. 'Right']:GetWidth()
    _G[name .. 'Middle']:SetWidth(middle)
    _G[name .. 'MiddleDisabled']:SetWidth(middle)
    self:SetWidth(WIDTH)
end

sizeTab(tab)
tab:SetScript('OnShow', sizeTab)

local icon = tab:CreateTexture(nil, 'ARTWORK')
icon:SetTexture(ICON)
icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
icon:SetSize(20, 20)
icon:SetPoint('CENTER', 0, -4)
tab.icon = icon

tab:SetScript('OnClick', function()
    PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
    ns.ShowLeaderboard()
end)

tab:HookScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(ns.LEADERBOARD_LABEL, 1, 1, 1)
    GameTooltip:AddLine('Midi Points and Achievement Points across the guild.', nil, nil, nil, true)
    GameTooltip:Show()
end)

tab:HookScript('OnLeave', function() GameTooltip:Hide() end)

PanelTemplates_SetNumTabs(frame, 3)
PanelTemplates_UpdateTabs(frame)
AnniversaryAchievements_RefreshFrameAliases()

ns.LeaderboardTab = tab
ns.UpdateTabText()
