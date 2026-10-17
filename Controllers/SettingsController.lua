local _, FF = ...

-- Registers General as the settings root and constructs the remaining settings tabs.
-- Input: loaded settings views and saved preferences. Output: registered Blizzard settings pages.
function FF:BuildOptions()
    local panel = self:BuildGeneralTab()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Forever Fit")
    Settings.RegisterAddOnCategory(category)
    self.category = category
    self.settingsPanel = panel
    self:BuildDefaultOptions()
    self:BuildCustomOptions()
    self:BuildStatisticsTab()
    self:BuildInfoOptions()
    self:RefreshOptions()
    self:BuildMinimapButton()
end

function FF:SetSettingsOpen(isOpen)
    if self.state.settingsOpen == isOpen then
        return
    end
    self.state.settingsOpen = isOpen
    if isOpen then
        self:CancelTimer()
    elseif self.state.pending then
        self:TryShowExercise()
    elseif not self.state.currentExercise then
        self:StartTimer()
    end
end

function FF:OpenSettings()
    if self.category then
        Settings.OpenToCategory(self.category:GetID())
    end
end

-- Shows or hides the button immediately when the General setting changes.
-- Input: FF.db.showMinimapButton. Output: minimap button visibility.
function FF:UpdateMinimapButtonVisibility()
    if self.minimapButton then
        self.minimapButton:SetShown(self.db.showMinimapButton)
    end
end

-- Creates a LibDBIcon-style minimap button with its standard round border and orbit drag.
-- Input: FF.db.minimapPos and minimap visibility preference. Output: movable settings shortcut.
function FF:BuildMinimapButton()
    local button = CreateFrame("Button", "ForeverFitMinimapButton", Minimap)
    self.minimapButton = button
    button:SetSize(31, 31)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(20, 20)
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetPoint("TOPLEFT", 7, -5)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(20, 20)
    icon:SetTexture("Interface\\Icons\\Ability_Warrior_StrengthOfArms.blp")
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    icon:SetPoint("TOPLEFT", 7, -5)

    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetSize(53, 53)
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetPoint("TOPLEFT")

    -- LibDBIcon perimeter offsets support both circular and square-shaped minimaps.
    local minimapShapes = {
        ROUND = { true, true, true, true },
        SQUARE = { false, false, false, false },
        ["CORNER-TOPLEFT"] = { true, false, false, false },
        ["CORNER-TOPRIGHT"] = { false, false, true, false },
        ["CORNER-BOTTOMLEFT"] = { false, true, false, false },
        ["CORNER-BOTTOMRIGHT"] = { false, false, false, true },
        ["SIDE-LEFT"] = { true, true, false, false },
        ["SIDE-RIGHT"] = { false, false, true, true },
        ["SIDE-TOP"] = { true, false, true, false },
        ["SIDE-BOTTOM"] = { false, true, false, true },
        ["TRICORNER-TOPLEFT"] = { true, true, true, false },
        ["TRICORNER-TOPRIGHT"] = { true, false, true, true },
        ["TRICORNER-BOTTOMLEFT"] = { true, true, false, true },
        ["TRICORNER-BOTTOMRIGHT"] = { false, true, true, true },
    }
    -- Input: saved orbit angle and current minimap shape. Output: button placement on rim.
    local function UpdateMinimapPosition()
        local angle = math.rad(FF.db.minimapPos or 225)
        local x, y, quadrant = math.cos(angle), math.sin(angle), 1
        if x < 0 then quadrant = quadrant + 1 end
        if y > 0 then quadrant = quadrant + 2 end
        local shape = GetMinimapShape and GetMinimapShape() or "ROUND"
        local curvedQuadrants = minimapShapes[shape] or minimapShapes.ROUND
        if curvedQuadrants[quadrant] then
            x, y = x * 105, y * 105
        else
            x = math.max(-80, math.min(x * 103.13708498985, 80))
            y = math.max(-80, math.min(y * 103.13708498985, 80))
        end
        button:ClearAllPoints()
        button:SetPoint("CENTER", Minimap, "CENTER", x, y)
    end
    UpdateMinimapPosition()
    self:UpdateMinimapButtonVisibility()

    button:SetScript("OnClick", function()
        if SettingsPanel and SettingsPanel:IsShown() and FF.state.settingsOpen then
            HideUIPanel(SettingsPanel)
        else
            FF:OpenSettings()
        end
    end)
    button:SetScript("OnMouseDown", function()
        icon:SetTexCoord(0, 1, 0, 1)
    end)
    button:SetScript("OnMouseUp", function()
        icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
    end)
    button:SetScript("OnDragStart", function(self)
        self:LockHighlight()
        self:SetScript("OnUpdate", function()
            local minimapCenterX, minimapCenterY = Minimap:GetCenter()
            if not minimapCenterX then return end
            local cursorX, cursorY = GetCursorPosition()
            local minimapScale = Minimap:GetEffectiveScale()
            FF.db.minimapPos = math.deg(math.atan2(cursorY / minimapScale - minimapCenterY, cursorX / minimapScale - minimapCenterX)) % 360
            UpdateMinimapPosition()
        end)
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        self:UnlockHighlight()
    end)
end
