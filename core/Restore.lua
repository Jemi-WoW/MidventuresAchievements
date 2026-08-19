local _, ns = ...
if ns.disabled then return end

-- Guildmates keep a copy of everyone's completed list, so they can hand ours back
-- when a character turns up on a machine that has never seen it.
local restore = {}
ns.Restore = restore

local READY_POLL = 0.5
local READY_LIMIT = 30
local SETTLE = 3
local WINDOW = 12

local pending, collecting, settling = nil, false, false
local finish

function restore.Receive(fields)
    if not collecting then return end
    pending = pending or { ids = {}, days = {} }

    for i = 2, #fields do
        local payload = fields[i]:match('^%a:(.*)$')
        if payload and ns.Sync.Decode then
            local ids = {}
            ns.Sync.Decode(payload, ids, pending.days)
            for _, id in ipairs(ids) do pending.ids[id] = true end
        end
    end

    -- The first answer is usually the whole story; the rest get a moment to fold in.
    if settling then return end
    settling = true
    C_Timer.After(SETTLE, finish)
end

-- Only what this machine has never heard of, and only ids the database answers to.
local function missing()
    local completion = CA_CompletionManager:GetLocal()
    local out = {}
    for id in pairs(pending and pending.ids or {}) do
        if CA_Database:GetAchievement(id) and not completion:IsAchievementCompleted(id) then
            out[#out + 1] = id
        end
    end
    table.sort(out)
    return out
end

-- Written straight into the store: the pop-up and the guild message are for earning it.
function restore.Apply(ids)
    local data = CA_CompletionManager:GetLocal():getData()
    local days = pending and pending.days or {}

    for _, id in ipairs(ids) do
        local achievement = CA_Database:GetAchievement(id)
        if achievement then
            local criterias = {}
            for criteriaID, criteria in pairs(achievement:GetCriterias()) do
                criterias[criteriaID] = { true, criteria.quantity or 0 }
            end
            -- Days travel without a time, so noon keeps the date off the boundary.
            data[id] = { true, (days[id] or 0) * 86400 + 43200, criterias }
        end
    end

    ns.Backup.Save()
    ns.InvalidateProgress(true)
    if AchievementFrame_ForceUpdate then AchievementFrame_ForceUpdate() end
    ns.Print(('restored %d achievement(s) from the guild.'):format(#ids))
end

StaticPopupDialogs['MIDVENTURES_RESTORE'] = {
    text = 'Your guild remembers %d achievement(s) for this character that this computer does not have.'
        .. '\n\nRestore them?',
    button1 = YES,
    button2 = NO,
    OnAccept = function(self) restore.Apply(self.data) end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local quietly, asked = false, false

-- Runs once the answers stop coming, or once it is clear none are.
finish = function()
    if not collecting then return end
    collecting, settling = false, false

    local ids = missing()
    if #ids == 0 then
        -- The login check finding nothing is the normal case, and worth no chat line.
        if asked then
            ns.Print('this character is already up to date - the guild has nothing extra for it.')
        end
        return
    end

    if quietly then return restore.Apply(ids) end
    local dialog = StaticPopup_Show('MIDVENTURES_RESTORE', #ids)
    if dialog then dialog.data = ids end
end

-- Silent means nobody is watching: put it back without asking and say so afterwards.
local function ask(silent, byHand)
    if not (ns.Sync and ns.Sync.AskGuildMemory) then return end
    if collecting then return end
    if not IsInGuild() then
        if byHand then ns.Print('no guild to ask.') end
        return
    end

    collecting, pending, settling = true, nil, false
    quietly, asked = silent, byHand
    ns.Sync.AskGuildMemory()
    C_Timer.After(WINDOW, finish)
end

ns.commands.restore = function() ask(false, true) end

-- The guild name is the last thing to turn up at login, and nothing can be sent before it.
local function whenReady(waited, run)
    if GetGuildInfo('player') then return run() end
    if waited >= READY_LIMIT then return end
    C_Timer.After(READY_POLL, function() whenReady(waited + READY_POLL, run) end)
end

local watcher = CreateFrame('Frame')
watcher:RegisterEvent('PLAYER_LOGIN')
watcher:SetScript('OnEvent', function(self)
    self:UnregisterEvent('PLAYER_LOGIN')

    -- Guildmates only answer when they hold more than we do, so asking every login is free.
    local unknownHere = not ns.Backup.Knows()
    whenReady(0, function() ask(unknownHere, false) end)
end)
