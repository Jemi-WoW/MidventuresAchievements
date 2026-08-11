local _, ns = ...
if ns.disabled then return end

-- Maps our criteria to our achievements so Anniversary's triggers complete them.
CA_CompletionManager:PostLoad(ns.tab:GetCategories())

-- Both lists below are derived, so adding content never needs an edit here.

-- Top-level categories get a bar in the summary's Progress Overview, max 12.
local categoryIDs = {}
for id, category in pairs(ns.tab:GetCategories()) do
    if category.parentID == -1 then categoryIDs[#categoryIDs + 1] = id end
end
table.sort(categoryIDs)
ns.summaryCategoryIDs = categoryIDs

-- Suggested on the summary while nothing is earned: the first ones defined.
local achievementIDs = {}
for _, category in pairs(ns.tab:GetCategories()) do
    for id in pairs(category:GetAchievements()) do
        achievementIDs[#achievementIDs + 1] = id
    end
end
table.sort(achievementIDs)

ns.defaultSummaryAchievements = {}
for i = 1, math.min(#achievementIDs, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS) do
    ns.defaultSummaryAchievements[i] = achievementIDs[i]
end

-- Anniversary only revisits achievements it has a record for, so sweep ours after it.
C_Timer.After(6, function()
    local completion = CA_CompletionManager:GetLocal()
    for _, category in pairs(ns.tab:GetCategories()) do
        for id in pairs(category:GetAchievements()) do
            completion:checkAndComplete(id)
        end
    end
end)
