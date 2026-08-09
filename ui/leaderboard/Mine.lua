local _, ns = ...
if ns.disabled then return end

local leaderboard = ns.Leaderboard

-- Whether you have it too, on someone else's row. Only on an expanded one: collapsed rows
-- are a list to skim, and a mark on every line would be noise.
local TICK = 'Interface\\RaidFrame\\ReadyCheck-Ready'
local CROSS = 'Interface\\RaidFrame\\ReadyCheck-NotReady'

-- Made once per row, the way ui/leaderboard/Players.lua makes its shields.
local function marker(button)
    if button.mvMine then return button.mvMine end

    local frame = CreateFrame('Frame', nil, button)
    frame:SetSize(60, 16)
    frame:SetPoint('BOTTOMRIGHT', -14, 12)

    frame.icon = frame:CreateTexture(nil, 'OVERLAY')
    frame.icon:SetSize(16, 16)
    frame.icon:SetPoint('RIGHT')

    frame.label = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
    frame.label:SetPoint('RIGHT', frame.icon, 'LEFT', -2, 0)
    frame.label:SetText('You')

    frame:Hide()
    button.mvMine = frame
    return frame
end

-- Our own completion, read straight from Anniversary rather than through the achievement
-- api, because ui/leaderboard/Remote.lua has that answering for the player on screen.
local function earnedByMe(id)
    local completion = CA_CompletionManager and CA_CompletionManager:GetLocal()
    return completion and completion:IsAchievementCompleted(id) or false
end

local function wanted(button)
    if not (ns.leaderboard and button and button.id) then return false end
    if button.collapsed then return false end

    local record = leaderboard.record
    return record ~= nil and not record.isPlayer
end

local function refresh(button)
    if not wanted(button) then
        if button and button.mvMine then button.mvMine:Hide() end
        return
    end

    local mark = marker(button)
    if earnedByMe(button.id) then
        mark.icon:SetTexture(TICK)
        mark.label:SetTextColor(0.4, 1, 0.4)
    else
        mark.icon:SetTexture(CROSS)
        mark.label:SetTextColor(1, 0.4, 0.4)
    end
    mark:Show()
end

ns.RefreshMineMarker = refresh

-- Every redraw of a row goes through the first, and expanding or collapsing one goes
-- through the other two without a redraw, so all three are hooked.
hooksecurefunc('AchievementButton_DisplayAchievement', function(button) refresh(button) end)
hooksecurefunc('AchievementButton_Expand', function(button) refresh(button) end)
hooksecurefunc('AchievementButton_Collapse', function(button)
    if button and button.mvMine then button.mvMine:Hide() end
end)
