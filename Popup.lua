local _, FF = ...

local DEFAULT_WIDTH, DEFAULT_HEIGHT = 392, 300
local MIN_WIDTH, MIN_HEIGHT = 350, 200
local MAX_WIDTH, MAX_HEIGHT = 650, 480

-- Popup placement is saved per character; fractional offsets survive UI scale changes.
function FF:ApplyPopupLayout()
    local layout = self.stats.popupLayout
    for _, popup in ipairs({ self.popup, self.previewPopup }) do
        popup:ClearAllPoints()
        if type(layout) == "table" and type(layout.x) == "number" and type(layout.y) == "number" then
            popup:SetSize(
                math.max(MIN_WIDTH, math.min(MAX_WIDTH, layout.width or DEFAULT_WIDTH)),
                math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, layout.height or DEFAULT_HEIGHT))
            )
            popup:SetPoint("CENTER", UIParent, "CENTER",
                math.max(-0.5, math.min(0.5, layout.x)) * UIParent:GetWidth(),
                math.max(-0.5, math.min(0.5, layout.y)) * UIParent:GetHeight())
        else
            popup:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
            if ChatFrame1 then
                popup:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 18)
            else
                popup:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 40, 260)
            end
        end
    end
end

function FF:SavePopupLayout(popup)
    local x, y = popup:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if not x or not parentX then return end
    self.stats.popupLayout = {
        x = (x - parentX) / UIParent:GetWidth(),
        y = (y - parentY) / UIParent:GetHeight(),
        width = math.floor(popup:GetWidth() + 0.5),
        height = math.floor(popup:GetHeight() + 0.5),
    }
    self:ApplyPopupLayout()
end

function FF:ResetPopupLayout()
    self.stats.popupLayout = nil
    self:ApplyPopupLayout()
end

function FF:HidePopupPreview()
    if self.previewPopup then self.previewPopup:Hide() end
end

local function CreatePopup(preview)
    local popup = CreateFrame("Frame", preview and "ForeverFitLayoutPreviewFrame" or "ForeverFitReminderFrame", UIParent, "BackdropTemplate")
    popup:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
    popup:SetFrameStrata(preview and "FULLSCREEN_DIALOG" or "DIALOG")
    popup:SetClampedToScreen(true)
    popup:SetMovable(preview)
    popup:SetResizable(preview)
    popup:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
    popup:EnableMouse(true)
    if preview then
        popup:RegisterForDrag("LeftButton")
        popup:SetScript("OnDragStart", function(self) self:StartMoving() end)
        popup:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            FF:SavePopupLayout(self)
        end)
    end
    popup:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 11, top = 11, bottom = 11 },
    })
    popup:SetBackdropColor(0.06, 0.06, 0.10, 0.97)

    popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    popup.title:SetPoint("TOPLEFT", 22, -19)
    popup.title:SetText(preview and "FOREVER FIT (PREVIEW)" or "FOREVER FIT")

    popup.subtitle = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    popup.subtitle:SetPoint("TOPLEFT", popup.title, "BOTTOMLEFT", 0, -5)
    popup.subtitle:SetText(preview and "Drag to move; use the corner to resize" or "A quick quest for your health")

    local close = CreateFrame("Button", nil, popup, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -6)
    close:SetScript("OnClick", function()
        if preview then FF:HidePopupPreview() else FF:DismissExercise(false) end
    end)

    popup.icon = popup:CreateTexture(nil, "ARTWORK")
    popup.icon:SetSize(72, 72)
    popup.icon:SetPoint("TOPLEFT", 25, -72)
    popup.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

    popup.exerciseName = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    popup.exerciseName:SetPoint("TOPLEFT", popup.icon, "TOPRIGHT", 16, -3)
    popup.exerciseName:SetJustifyH("LEFT")

    popup.target = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    popup.target:SetPoint("TOPLEFT", popup.exerciseName, "BOTTOMLEFT", 0, -9)
    popup.target:SetJustifyH("LEFT")

    popup.instructions = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    popup.instructions:SetPoint("TOPLEFT", popup.target, "BOTTOMLEFT", 0, -7)
    popup.instructions:SetHeight(DEFAULT_HEIGHT - 197)
    popup.instructions:SetJustifyH("LEFT")
    popup.instructions:SetJustifyV("TOP")

    popup.quip = popup:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    popup.quip:SetPoint("BOTTOMLEFT", 25, 46)
    popup.quip:SetHeight(27)
    popup.quip:SetJustifyH("CENTER")
    popup.quip:SetJustifyV("MIDDLE")

    popup:SetScript("OnSizeChanged", function(self, width, height)
        self.exerciseName:SetWidth(width - 138)
        self.target:SetWidth(width - 138)
        self.instructions:SetWidth(width - 138)
        self.instructions:SetHeight(math.max(1, height - 197))
        self.quip:SetWidth(width - 50)
    end)
    popup.exerciseName:SetWidth(DEFAULT_WIDTH - 138)
    popup.target:SetWidth(DEFAULT_WIDTH - 138)
    popup.instructions:SetWidth(DEFAULT_WIDTH - 138)
    popup.quip:SetWidth(DEFAULT_WIDTH - 50)

    local completedButton = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    completedButton:SetSize(128, 26)
    completedButton:SetPoint("BOTTOMRIGHT", popup, "BOTTOM", -7, 17)
    completedButton:SetText("Completed")
    completedButton:SetScript("OnClick", function()
        if preview then FF:HidePopupPreview() else FF:DismissExercise(true) end
    end)

    local skipButton = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
    skipButton:SetSize(128, 26)
    skipButton:SetPoint("BOTTOMLEFT", popup, "BOTTOM", 7, 17)
    skipButton:SetText("Skip")
    skipButton:SetScript("OnClick", function()
        if preview then FF:HidePopupPreview() else FF:DismissExercise(false) end
    end)

    if preview then
        local grip = CreateFrame("Button", nil, popup)
        grip:SetSize(24, 24)
        grip:SetPoint("BOTTOMRIGHT", -12, 12)
        grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        grip:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Drag to resize Forever Fit")
            GameTooltip:Show()
        end)
        grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
        grip:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then popup:StartSizing("BOTTOMRIGHT") end
        end)
        grip:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                popup:StopMovingOrSizing()
                FF:SavePopupLayout(popup)
            end
        end)
    end
    popup:Hide()
    return popup
end

function FF:BuildPopup()
    self.popup = CreatePopup(false)
    self.previewPopup = CreatePopup(true)
    self:ApplyPopupLayout()
end

function FF:ShowPopupPreview()
    local popup = self.previewPopup
    local exercise = self.baseExercises[1]
    popup.icon:SetTexture(self:ResolveIcon(exercise.icon))
    popup.exerciseName:SetText(exercise.name)
    popup.target:SetText("Goal: " .. exercise.target)
    popup.instructions:SetText(exercise.instructions)
    popup.quip:SetText('"Preview only — no workout is recorded."')
    self:ApplyPopupLayout()
    popup:Show()
end

function FF:ShowExercisePopup(exercise)
    local popup = self.popup
    popup.icon:SetTexture(self:ResolveIcon(exercise.icon))
    popup.exerciseName:SetText(exercise.name)
    popup.target:SetText("Goal: " .. exercise.target)
    popup.instructions:SetText(exercise.instructions)
    popup.quip:SetText('"' .. exercise.quip .. '"')
    popup:Show()
end
