local _, ns = ...
if ns.disabled then return end

-- How far through the list you are, beside the count the bar already carries.
local base

-- The bar's own numbers, so the two can never disagree.
local function percent(bar)
    local _, total = bar:GetMinMaxValues()
    local completed = bar:GetValue() or 0
    if not total or total <= 0 then return nil end
    -- Rounded down: 609 of 610 is not all of them.
    return math.floor(completed / total * 100)
end

hooksecurefunc('AchievementFrameSummaryCategoriesStatusBar_Update', function()
    local bar = AchievementFrameSummaryCategoriesStatusBar
    local label = AchievementFrameSummaryCategoriesStatusBarTitle
    if not (bar and label) then return end

    -- Read before the first write, since nothing else ever sets this text back.
    base = base or label:GetText() or ''

    local done = percent(bar)
    if not done then
        label:SetText(base)
        return
    end
    label:SetText(('%s |cffffffff%d%%|r'):format(base, done))
end)
