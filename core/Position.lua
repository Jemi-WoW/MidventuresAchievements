local _, ns = ...
if ns.disabled then return end

-- Standing somewhere. Data is the spot key an achievement file registered below.
CA_Criterias.dataLengths[ns.CRITERIA_POSITION] = 1
CA_Criterias.criterias[ns.CRITERIA_POSITION] = {}

local spots = {}

-- Map percentages, a radius in the same units, and AreaTableLocale zone ids.
function ns.Spot(key, def)
    spots[key] = def
    return key
end

local function inZone(def)
    local here = GetZoneText()
    for _, areaID in ipairs(def.zones) do
        if AreaTableLocale[areaID] == here then return true end
    end
    return false
end

-- Positions are per map, so a spot only ever matches on the map its numbers were read from.
local function atSpot(def)
    local mapID = C_Map.GetBestMapForUnit('player')
    if not mapID then return false end
    local position = C_Map.GetPlayerMapPosition(mapID, 'player')
    if not position then return false end

    local x, y = position:GetXY()
    if not x then return false end
    x, y = x * 100, y * 100
    return (x - def.x) ^ 2 + (y - def.y) ^ 2 <= def.radius ^ 2
end

local function check()
    for key, def in pairs(spots) do
        if inZone(def) and atSpot(def) then
            CA_Criterias:Trigger(ns.CRITERIA_POSITION, {key})
        end
    end
end

-- No event fires for walking, so this ticks, and only inside a registered zone.
local ticker
local function rearm()
    local wanted = false
    for _, def in pairs(spots) do
        if inZone(def) then
            wanted = true
            break
        end
    end

    if wanted and not ticker then
        ticker = C_Timer.NewTicker(1, check)
    elseif not wanted and ticker then
        ticker:Cancel()
        ticker = nil
    end
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:RegisterEvent('ZONE_CHANGED_NEW_AREA')
watcher:RegisterEvent('ZONE_CHANGED')
watcher:SetScript('OnEvent', function() C_Timer.After(1, rearm) end)

-- Every spot in the addon was read off the map with this, and it is how to correct one.
SLASH_MIDVENTURESWHERE1 = '/mv'
SlashCmdList['MIDVENTURESWHERE'] = function(args)
    if args and args:lower():match('^%s*where') == nil then
        DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00Midventures:|r try /mv where')
        return
    end

    local mapID = C_Map.GetBestMapForUnit('player')
    local spot = mapID and C_Map.GetPlayerMapPosition(mapID, 'player')
    local x, y = spot and spot:GetXY()
    if not x then
        DEFAULT_CHAT_FRAME:AddMessage('|cff00ff00Midventures:|r no position here.')
        return
    end

    DEFAULT_CHAT_FRAME:AddMessage(('|cff00ff00Midventures:|r %s / %s - x %.2f, y %.2f')
        :format(GetZoneText(), GetSubZoneText() ~= '' and GetSubZoneText() or '-',
            x * 100, y * 100))
end
