local _, ns = ...
if ns.disabled then return end

-- The window the transfer string is copied out of and pasted back into.
local frame = CreateFrame('Frame', 'MidventuresTransferFrame', UIParent, 'BackdropTemplate')
frame:SetSize(580, 380)
frame:SetPoint('CENTER')
frame:SetFrameStrata('DIALOG')
frame:SetBackdrop({
    bgFile = 'Interface/DialogFrame/UI-DialogBox-Background',
    edgeFile = 'Interface/DialogFrame/UI-DialogBox-Border',
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag('LeftButton')
frame:SetScript('OnDragStart', frame.StartMoving)
frame:SetScript('OnDragStop', frame.StopMovingOrSizing)
frame:Hide()
tinsert(UISpecialFrames, 'MidventuresTransferFrame')

local function paint(texture, red, green, blue, alpha)
    if texture.SetColorTexture then return texture:SetColorTexture(red, green, blue, alpha) end
    texture:SetTexture(red, green, blue, alpha)
end

-- The backdrop's own tile does not always draw, and a see-through window is unreadable.
local sheet = frame:CreateTexture(nil, 'BACKGROUND')
sheet:SetPoint('TOPLEFT', 11, -12)
sheet:SetPoint('BOTTOMRIGHT', -12, 11)
paint(sheet, 0.04, 0.04, 0.05, 0.95)

local title = frame:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
title:SetPoint('TOP', 0, -18)

local hint = frame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
hint:SetPoint('TOPLEFT', 20, -44)
hint:SetPoint('TOPRIGHT', -20, -44)
hint:SetJustifyH('LEFT')
hint:SetHeight(28)

local close = CreateFrame('Button', nil, frame, 'UIPanelCloseButton')
close:SetPoint('TOPRIGHT', -6, -6)

-- A sunken panel, so it is obvious the text goes in here.
local well = CreateFrame('Frame', nil, frame)
well:SetPoint('TOPLEFT', 18, -76)
well:SetPoint('BOTTOMRIGHT', -18, 48)

local wellEdge = well:CreateTexture(nil, 'BACKGROUND')
wellEdge:SetAllPoints()
paint(wellEdge, 0.35, 0.32, 0.25, 1)

local wellFace = well:CreateTexture(nil, 'BORDER')
wellFace:SetPoint('TOPLEFT', 1, -1)
wellFace:SetPoint('BOTTOMRIGHT', -1, 1)
paint(wellFace, 0.09, 0.09, 0.1, 1)

local scroll = CreateFrame('ScrollFrame', 'MidventuresTransferScroll', well,
    'UIPanelScrollFrameTemplate')
scroll:SetPoint('TOPLEFT', 6, -6)
scroll:SetPoint('BOTTOMRIGHT', -26, 6)

local box = CreateFrame('EditBox', nil, scroll)
box:SetMultiLine(true)
box:SetAutoFocus(false)
box:SetMaxLetters(0)
box:SetFontObject(ChatFontNormal)
box:SetTextInsets(4, 4, 4, 4)
box:SetScript('OnEscapePressed', function() frame:Hide() end)
scroll:SetScrollChild(box)

-- An empty multi-line box has no height of its own, so there is nothing to click.
local LINE = 14

local function fitBox()
    local width = scroll:GetWidth()
    if width and width > 0 then box:SetWidth(width) end

    local perLine = math.max(1, math.floor((width or 500) / 7))
    local lines = math.ceil(((box:GetNumLetters() or 0) + 1) / perLine) + 1
    box:SetHeight(math.max(scroll:GetHeight() or 200, lines * LINE))
end

box:SetScript('OnTextChanged', fitBox)

-- The padding around the box is still part of the box as far as a click goes.
well:EnableMouse(true)
well:SetScript('OnMouseDown', function() box:SetFocus() end)

local action = CreateFrame('Button', nil, frame, 'UIPanelButtonTemplate')
action:SetSize(130, 22)
action:SetPoint('BOTTOMRIGHT', -22, 18)

local everything = CreateFrame('CheckButton', 'MidventuresTransferAll', frame,
    'UICheckButtonTemplate')
everything:SetSize(24, 24)
everything:SetPoint('BOTTOMLEFT', 22, 16)
-- The template names its own label on some clients and fields it on others.
local everythingLabel = everything.text or _G[everything:GetName() .. 'Text']
if not everythingLabel then
    everythingLabel = everything:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    everythingLabel:SetPoint('LEFT', everything, 'RIGHT', 2, 0)
end
everythingLabel:SetText('Every character on this account')

local function fillExport()
    box:SetText(ns.Backup.Export(everything:GetChecked()))
    fitBox()
    box:HighlightText()
    box:SetFocus()
end

-- Export fills the box and import empties it, so the two share the one window.
-- Shown first: the box cannot be measured until the frame has a size on screen.
function ns.ShowTransfer(mode)
    frame.mode = mode
    frame:Show()

    if mode == 'import' then
        title:SetText('Paste progress in')
        hint:SetText('Click the black box below, paste with Ctrl+V, then press Import. '
            .. 'Nothing you already have is lost: the two are merged.')
        everything:Hide()
        action:SetText('Import')
        box:SetText('')
        fitBox()
        scroll:SetVerticalScroll(0)
        box:SetFocus()
    else
        title:SetText('Copy progress out')
        hint:SetText('Click the black box below, select all with Ctrl+A, copy with Ctrl+C, '
            .. 'then paste it into /midv import on your other PC.')
        everything:Show()
        action:SetText('Select all')
        fillExport()
        scroll:SetVerticalScroll(0)
    end
end

action:SetScript('OnClick', function()
    if frame.mode ~= 'import' then
        box:HighlightText()
        box:SetFocus()
        return
    end

    local pasted = (box:GetText() or ''):gsub('%s+', '')
    if pasted == '' then
        ns.Print('nothing pasted in yet - click the black box and press Ctrl+V.')
        return
    end

    local characters, gained = ns.Backup.Import(pasted)
    if not characters then
        ns.Print(gained)
        return
    end

    ns.Print(('read %d character(s); %d achievement(s) restored here.'):format(characters, gained))
    if gained == 0 then
        ns.Print('the rest come back as you log each character in.')
    end
    frame:Hide()
end)

everything:SetScript('OnClick', function()
    if frame.mode ~= 'import' then fillExport() end
end)

ns.commands.export = function() ns.ShowTransfer('export') end
ns.commands.import = function() ns.ShowTransfer('import') end
