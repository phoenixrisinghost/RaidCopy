-- ========================
-- Core Functions
-- ========================

local function GetRaidData()
    local r = {}
    local c = 0
    for i = 1, 40 do
        local u = "raid"..i
        local n = UnitName(u)
        local _, cl = UnitClass(u)
        if n and n ~= "Unknown" and cl then
            tinsert(r, n..","..cl)
            c = c + 1
        end
    end
    table.sort(r)
    return c, table.concat(r, "; ")
end

-- ========================
-- Popup Frame (persistent)
-- ========================

local popupTitle, popupEB

local function BuildCopyFrame()
    local f = CreateFrame("Frame", "RaidCopyFrame", UIParent)
    f:SetWidth(600)
    f:SetHeight(130)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left=11, right=12, top=12, bottom=11 }
    })
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function() f:StartMoving() end)
    f:SetScript("OnDragStop",  function() f:StopMovingOrSizing() end)
    f:Hide()

    popupTitle = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    popupTitle:SetPoint("TOP", f, "TOP", 0, -16)

    popupEB = CreateFrame("EditBox", nil, f)
    popupEB:SetMultiLine(false)
    popupEB:SetMaxLetters(0)
    popupEB:SetAutoFocus(true)
    popupEB:SetFontObject(ChatFontNormal)
    popupEB:SetWidth(560)
    popupEB:SetHeight(32)
    popupEB:SetPoint("TOP", popupTitle, "BOTTOM", 0, -10)
    popupEB:SetScript("OnEscapePressed", function() f:Hide() end)

    local btnPrint = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnPrint:SetWidth(110)
    btnPrint:SetHeight(24)
    btnPrint:SetPoint("BOTTOM", f, "BOTTOM", -100, 14)
    btnPrint:SetText("Print to Chat")
    btnPrint:SetScript("OnClick", function()
        local c, data = GetRaidData()
        print("Raid ("..c.."/40): "..data)
        popupTitle:SetText("Raid ("..c.."/40)")
        popupEB:SetText(data)
        popupEB:HighlightText()
    end)

    local btnClose = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btnClose:SetWidth(80)
    btnClose:SetHeight(24)
    btnClose:SetPoint("BOTTOM", f, "BOTTOM", 60, 14)
    btnClose:SetText("Close")
    btnClose:SetScript("OnClick", function() f:Hide() end)

    return f
end

local copyFrame = BuildCopyFrame()

local function ShowCopyFrame()
    local c, data = GetRaidData()
    popupTitle:SetText("Raid ("..c.."/40)")
    popupEB:SetText(data)
    popupEB:HighlightText()
    copyFrame:Show()
end

-- ========================
-- Minimap Button
-- ========================

minimapBtn = CreateFrame("Button", "RaidCopyMinimapBtn", Minimap)
minimapBtn:SetWidth(31)
minimapBtn:SetHeight(31)
minimapBtn:SetFrameStrata("MEDIUM")
minimapBtn:SetFrameLevel(8)
minimapBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

local icon = minimapBtn:CreateTexture(nil, "BACKGROUND")
icon:SetWidth(20)
icon:SetHeight(20)
icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
icon:SetTexture("Interface\\ICONS\\Ability_Warrior_BattleShout")
icon:SetPoint("TOPLEFT", minimapBtn, "TOPLEFT", 7, -5)

local border = minimapBtn:CreateTexture(nil, "OVERLAY")
border:SetWidth(53)
border:SetHeight(53)
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", minimapBtn, "TOPLEFT", 0, 0)
minimapBtn:SetPoint("TOPLEFT", Minimap, "TOPLEFT",
    54 - (78 * cos(220)),
    (78 * sin(220)) - 55)
minimapBtn:Show()

minimapBtn:SetScript("OnClick", function()
    if copyFrame:IsShown() then
        copyFrame:Hide()
    else
        ShowCopyFrame()
    end
end)

minimapBtn:SetScript("OnEnter", function()
    GameTooltip:SetOwner(minimapBtn, "ANCHOR_LEFT")
    GameTooltip:SetText("RaidCopy", 1, 1, 1)
    GameTooltip:AddLine("Left-click to open/close roster", 1, 1, 1)
    GameTooltip:Show()
end)

minimapBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

-- ========================
-- Slash Commands
-- ========================

SLASH_RAIDCOPY1 = "/raidcopy"
SLASH_RAIDCOPY2 = "/rc"
SlashCmdList["RAIDCOPY"] = function()
    if copyFrame:IsShown() then
        copyFrame:Hide()
    else
        ShowCopyFrame()
    end
end
