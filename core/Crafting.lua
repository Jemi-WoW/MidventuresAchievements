local _, ns = ...
if ns.disabled then return end

-- Making things, taking them apart, and handing them over.
CA_Criterias.dataLengths[ns.CRITERIA_CRAFTED] = 0
CA_Criterias.criterias[ns.CRITERIA_CRAFTED] = {}
CA_Criterias.dataLengths[ns.CRITERIA_DISENCHANTS] = 0
CA_Criterias.criterias[ns.CRITERIA_DISENCHANTS] = {}
CA_Criterias.dataLengths[ns.CRITERIA_GUILD_TRADES] = 0
CA_Criterias.criterias[ns.CRITERIA_GUILD_TRADES] = {}
CA_Criterias.dataLengths[ns.CRITERIA_ENCHANT_GUILD] = 0
CA_Criterias.criterias[ns.CRITERIA_ENCHANT_GUILD] = {}

local DISENCHANT = 13262

local function progress()
    MidventuresProgressDB = MidventuresProgressDB or {}
    MidventuresProgressDB.crafting = MidventuresProgressDB.crafting
        or { crafted = 0, disenchanted = 0, trades = 0 }
    return MidventuresProgressDB.crafting
end

local function add(key, criteriaType, amount)
    local record = progress()
    record[key] = (record[key] or 0) + (amount or 1)
    CA_Criterias:Trigger(criteriaType, nil, record[key], true)
end

-- "You create: %s" as the client writes it, numbered placeholders and all.
local function toPattern(message)
    local pattern = message:gsub('%.', '%%.')
    for i = 1, 4 do
        pattern = pattern:gsub('%%' .. i .. '%$s', '(.+)'):gsub('%%' .. i .. '%$d', '(%%d+)')
    end
    return (pattern:gsub('%%s', '(.+)'):gsub('%%d', '(%%d+)'))
end

local CREATED = toPattern(LOOT_ITEM_CREATED_SELF or 'You create: %s.')
local CREATED_MULTIPLE = toPattern(LOOT_ITEM_CREATED_SELF_MULTIPLE or 'You create: %sx%d.')

local function professionOpen()
    if TradeSkillFrame and TradeSkillFrame:IsShown() then return true end
    if CraftFrame and CraftFrame:IsShown() then return true end
    return false
end

-- Every craft announces itself in the loot channel.
local function onLoot(message, initiator, _, _, playerName)
    local who = playerName or initiator
    if who and who ~= UnitName('player') then return end
    if not message then return end
    if not professionOpen() then return end

    local _, quantity = message:match(CREATED_MULTIPLE)
    if quantity then
        add('crafted', ns.CRITERIA_CRAFTED, tonumber(quantity) or 1)
    elseif message:match(CREATED) then
        add('crafted', ns.CRITERIA_CRAFTED, 1)
    end
end

-- The trade partner, kept while the window is open: the name is gone once it shuts.
local partner = nil
local accepted = false

local function onCast(unit, _, spellID)
    if unit ~= 'player' then return end

    local disenchant = GetSpellInfo(DISENCHANT)
    if disenchant and GetSpellInfo(spellID) == disenchant then
        add('disenchanted', ns.CRITERIA_DISENCHANTS)
        return
    end

    -- The only cast that ever lands in an open trade window is an enchant on their gear.
    if partner and TradeFrame and TradeFrame:IsShown() then
        CA_Criterias:Trigger(ns.CRITERIA_ENCHANT_GUILD)
    end
end

local function refill()
    local record = progress()
    CA_Criterias:Trigger(ns.CRITERIA_CRAFTED, nil, record.crafted, true)
    CA_Criterias:Trigger(ns.CRITERIA_DISENCHANTS, nil, record.disenchanted, true)
    CA_Criterias:Trigger(ns.CRITERIA_GUILD_TRADES, nil, record.trades, true)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('CHAT_MSG_LOOT')
watcher:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
watcher:RegisterEvent('TRADE_SHOW')
watcher:RegisterEvent('TRADE_ACCEPT_UPDATE')
watcher:RegisterEvent('TRADE_CLOSED')
watcher:RegisterEvent('PLAYER_ENTERING_WORLD')
watcher:SetScript('OnEvent', function(_, event, ...)
    if event == 'CHAT_MSG_LOOT' then
        onLoot(...)
    elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then
        onCast(...)
    elseif event == 'TRADE_SHOW' then
        local name = UnitName('NPC')
        partner = ns.IsGuildmate(name, 'NPC') and name or nil
        accepted = false
    elseif event == 'TRADE_ACCEPT_UPDATE' then
        local mine, theirs = ...
        accepted = mine == 1 and theirs == 1
    elseif event == 'TRADE_CLOSED' then
        -- Both sides accepted and then the window shut, which is a trade that went through.
        if partner and accepted then add('trades', ns.CRITERIA_GUILD_TRADES) end
        partner, accepted = nil, false
    else
        C_Timer.After(8, refill)
    end
end)
