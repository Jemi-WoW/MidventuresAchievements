local _, ns = ...
if ns.disabled then return end

local frame = AnniversaryAchievements_GetAchievementFrame()

-- Progress is recorded whether the window is open or not; this only refreshes it.
-- Idles unless something actually moved.
function ns.LiveTick()
    if not (ns.active and frame:IsShown()) then return end
    local changed, earned = ns.ConsumeProgressChange()
    if not changed then return end
    ns.RefreshOpenView(earned)
end

C_Timer.NewTicker(0.5, ns.LiveTick)
