local _, FF = ...

-- Main page spacing (UI units). Each settings page has independent values.
local DESCRIPTION_SKIP = 15
local TITLE_SKIP = 20
local INTRO_SKIP = 35
local CHECKBOX_SKIP = 35
local FIELD_SKIP = 15
local SECTION_SKIP = 50

local function AddText(parent, text, template, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", template or "GameFontNormal")
    label:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    label:SetText(text)
    return label
end

function FF:BuildOptions()
    local panel = CreateFrame("Frame", "ForeverFitSettingsPanel")
    panel.name = "Forever Fit"
    panel:Hide()
    panel.OnCommit = function() end
    panel.OnDefault = function()
        FF.db.minutes = 30
        FF.db.guildLevelAnnounce = false
        FF.db.guildAchievementAnnounce = true
        FF.db.partyBreakAnnounce = true
        FF.db.partyInviteAnnounce = false
        FF.db.taxiBreak = false
        FF.db.campfireBreak = false
        FF.db.soundEnabled = true
        FF.db.soundHumanMaleOnly = false
        for _, group in ipairs({ "No Equipment", "Free Weights", "Walking Pad", "Other" }) do
            FF.db.enabledGroups[group] = true
        end
        for _, exercise in ipairs(FF.exercises) do
            if not exercise.custom then
                FF.db.enabled[exercise.id] = exercise.group == "No Equipment"
            end
        end
        FF:OnExerciseSelectionChanged()
        FF:RefreshOptions()
        FF:RefreshDefaultOptions()
        FF:RefreshCustomOptions()
    end
    panel.OnRefresh = function() FF:RefreshOptions() end
    panel:SetScript("OnShow", function()
        FF:SetSettingsOpen(true)
        FF:RefreshOptions()
    end)
    panel:SetScript("OnHide", function()
        FF:HidePopupPreview()
        FF:SetSettingsOpen(false)
    end)

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -30, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(555, 955)
    scroll:SetScrollChild(content)

    -- Move y downward to position each line and control.
    local y = -16
    AddText(content, "Forever Fit", "GameFontNormalHuge", 20, y)
    y = y - TITLE_SKIP
    local subtitle = AddText(content, "Your character will be fit forever, and so should you.", "GameFontHighlightSmall", 20, y)
    subtitle:SetWidth(505)
    subtitle:SetJustifyH("LEFT")
    self.settingsSubtitle = subtitle

    y = y - INTRO_SKIP
    AddText(content, "Reminder interval", "GameFontNormal", 20, y)
    self.intervalLabel = AddText(content, "", "GameFontHighlight", 385, y)
    y = y - FIELD_SKIP
    local slider = CreateFrame("Slider", "ForeverFitIntervalSlider", content, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 38, y)
    slider:SetSize(410, 18)
    slider:SetMinMaxValues(10, 60)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText("10 min")
    slider.High:SetText("60 min")
    slider.Text:SetText("")
    slider:SetScript("OnValueChanged", function(_, value)
        if FF.settingControls then return end
        FF.db.minutes = math.floor(value + 0.5)
        FF:RefreshIntervalLabel()
    end)
    self.intervalSlider = slider

    local settings = {
        { "guildLevelAnnounce", "Announce your exercise count and most completed exercise in guild chat." },
        { "guildAchievementAnnounce", "Announce earned achievements in guild chat." },
        { "partyBreakAnnounce", "Tell party members when you're taking an exercise break" },
        { "partyInviteAnnounce", "Invite party members to join your exercise! ForeverFit together!" },
        { "taxiBreak", "Trigger an exercise when boarding a flight-path taxi; unless, you need a bathroom break." },
        { "campfireBreak", "Trigger an exercise when Welcoming Campfire begins." },
        { "soundEnabled", "Play race-specific voice sounds for Completed (/cheer) and Skip (/chicken)." },
    }
    self.announceChecks = {}
    y = y - SECTION_SKIP
    for _, entry in ipairs(settings) do
        local checkbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 18, y)
        checkbox.Text:SetText(entry[2])
        checkbox.Text:SetWidth(465)
        checkbox.Text:SetJustifyH("LEFT")
        checkbox:SetScript("OnClick", function(self)
            FF.db[entry[1]] = self:GetChecked() == true
            if entry[1] == "taxiBreak" then FF:UpdateTaxiWatcher() end
            if entry[1] == "campfireBreak" then FF.state.wasWelcomingCampfire = FF:HasWelcomingCampfire() end
            if entry[1] == "soundEnabled" then FF:RefreshOptions() end
        end)
        self.announceChecks[entry[1]] = checkbox
        y = y - CHECKBOX_SKIP
    end
    local humanOnly = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    humanOnly:SetPoint("TOPLEFT", 38, y + 8)
    humanOnly.Text:SetText("Human Male Only (override race and gender)")
    humanOnly.Text:SetWidth(425)
    humanOnly.Text:SetJustifyH("LEFT")
    humanOnly:SetScript("OnClick", function(self)
        FF.db.soundHumanMaleOnly = self:GetChecked() == true
    end)
    self.soundHumanMaleOnlyCheck = humanOnly
    y = y - CHECKBOX_SKIP
    y = y - DESCRIPTION_SKIP
    AddText(content, "Party options work independently and only for parties, not raids. Don't make the raid wait, workout before or after!", "GameFontHighlightSmall", 20, y)
    y = y - DESCRIPTION_SKIP
    AddText(content, "Flight-path reminders are optional; their timer restarts either Complete or Skip.", "GameFontHighlightSmall", 20, y)

    y = y - SECTION_SKIP
    AddText(content, "View your Achievements in the Fitness Challenges tab!", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    AddText(content, "Additionally, use /ffit stats for exercise totals.", "GameFontHighlightSmall", 20, y)
    y = y - FIELD_SKIP
    local achievements = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    achievements:SetPoint("TOPLEFT", 20, y)
    achievements:SetSize(185, 28)
    achievements:SetText("View Fit Challenges")
    achievements:SetScript("OnClick", function()
        -- Settings otherwise covers the embedded Legacy Challenges page.
        if SettingsPanel and SettingsPanel:IsShown() then
            HideUIPanel(SettingsPanel)
        end
        C_Timer.After(0, function() FF:OpenFitChallenges() end)
    end)

    y = y - SECTION_SKIP
    AddText(content, "Exercise Selection", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    AddText(content, "Select built-in exercises on the Default Exercises page.",
        "GameFontHighlightSmall", 20, y)
    y = y - FIELD_SKIP
    local selectExercises = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    selectExercises:SetPoint("TOPLEFT", 20, y)
    selectExercises:SetSize(185, 27)
    selectExercises:SetText("Default Exercises")
    selectExercises:SetScript("OnClick", function()
        Settings.OpenToCategory(FF.defaultCategory:GetID())
    end)

    y = y - SECTION_SKIP
    AddText(content, "Workout Popup Layout", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    local layoutHelp = AddText(content,
        "Move the preview by dragging it, or resize from its bottom-right corner. Changes save for this character.",
        "GameFontHighlightSmall", 20, y)
    layoutHelp:SetWidth(500)
    layoutHelp:SetJustifyH("LEFT")
    y = y - INTRO_SKIP
    local previewButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    previewButton:SetPoint("TOPLEFT", 20, y)
    previewButton:SetSize(240, 27)
    previewButton:SetText("Preview / Move / Resize")
    previewButton:SetScript("OnClick", function() FF:ShowPopupPreview() end)
    local resetLayoutButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetLayoutButton:SetPoint("TOPLEFT", 274, y)
    resetLayoutButton:SetSize(171, 27)
    resetLayoutButton:SetText("Reset Popup Layout")
    resetLayoutButton:SetScript("OnClick", function() FF:ResetPopupLayout() end)

    y = y - SECTION_SKIP
    AddText(content, "Reset Workout Statistics", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    AddText(content, "Resets this character; other characters keep their achievement progress.", "GameFontHighlightSmall", 20, y)
    y = y - FIELD_SKIP
    AddText(content, "Type RESET to confirm:", "GameFontHighlight", 20, y)
    local resetButton = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", 316, y + 5)
    resetButton:SetSize(166, 27)
    resetButton:SetText("Reset Statistics")
    resetButton:Disable()
    local field = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    field:SetPoint("TOPLEFT", 197, y + 2)
    field:SetSize(100, 22)
    field:SetAutoFocus(false)
    field:SetMaxLetters(5)
    field:SetScript("OnTextChanged", function(self)
        resetButton:SetEnabled(self:GetText() == "RESET")
    end)
    field:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    field:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    resetButton:SetScript("OnClick", function()
        if field:GetText() ~= "RESET" then return end
        FF:ResetStatistics()
        field:SetText("")
        field:ClearFocus()
        FF.Print("Character statistics reset; other characters' achievement progress preserved.")
    end)
    self.resetField = field

    y = y - SECTION_SKIP
    AddText(content, "Cheater Apology", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    AddText(content, "Removes only the Cheater lockout. All workout statistics remain.", "GameFontHighlightSmall", 20, y)
    y = y - FIELD_SKIP
    AddText(content, "Type exactly: Whoops, I'm a cheater", "GameFontHighlight", 20, y)
    y = y - FIELD_SKIP
    local apology = CreateFrame("EditBox", nil, content, "InputBoxTemplate")
    apology:SetPoint("TOPLEFT", 20, y)
    apology:SetSize(230, 22)
    apology:SetAutoFocus(false)
    apology:SetMaxLetters(21)
    local forgive = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    forgive:SetPoint("LEFT", apology, "RIGHT", 15, 0)
    forgive:SetSize(165, 27)
    forgive:SetText("Remove Cheater Status")
    forgive:Disable()
    apology:SetScript("OnTextChanged", function(self)
        forgive:SetEnabled(FF.stats.cheater and self:GetText() == "Whoops, I'm a cheater")
    end)
    apology:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    apology:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    forgive:SetScript("OnClick", function()
        if apology:GetText() ~= "Whoops, I'm a cheater" or not FF.stats.cheater then return end
        FF:ForgiveCheater()
        apology:SetText("")
        apology:ClearFocus()
        FF:RefreshOptions()
        FF.Print("The Bronze Dragonflight accepts your apology. Workout history preserved.")
    end)
    self.forgiveButton = forgive
    self.apologyField = apology
    content:SetHeight(-y + 70)

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Forever Fit")
    Settings.RegisterAddOnCategory(category)
    self.category = category
    self.settingsPanel = panel
    self:BuildDefaultOptions()
    self:BuildCustomOptions()
    self:BuildInfoOptions()
    self:RefreshOptions()
end

function FF:RefreshIntervalLabel()
    self.intervalLabel:SetText(self.db.minutes .. " minutes")
end

function FF:RefreshOptions()
    if not self.db or not self.intervalSlider then return end
    self.forgiveButton:SetEnabled(self.stats.cheater and self.apologyField:GetText() == "Whoops, I'm a cheater")
    self.settingsSubtitle:SetText(self.stats.cheater
        and "WORKOUTS LOCKED: Apologize below or reset statistics to resume."
        or (#self:EnabledExercises() == 0
            and "No exercises enabled. Reminders are paused until you select one."
            or "Your character will be fit forever, and so will you."))
    self.settingsSubtitle:SetTextColor(self.stats.cheater and 1 or 0.95, self.stats.cheater and 0.35 or 0.86, self.stats.cheater and 0.30 or 0.74)
    self.settingControls = true
    self.intervalSlider:SetValue(self.db.minutes)
    for key, checkbox in pairs(self.announceChecks) do
        checkbox:SetChecked(self.db[key])
    end
    self.soundHumanMaleOnlyCheck:SetChecked(self.db.soundHumanMaleOnly)
    self.soundHumanMaleOnlyCheck:SetEnabled(self.db.soundEnabled)
    self.soundHumanMaleOnlyCheck.Text:SetTextColor(
        self.db.soundEnabled and 1 or 0.5,
        self.db.soundEnabled and 0.82 or 0.5,
        self.db.soundEnabled and 0 or 0.5)
    self.settingControls = false
    self:RefreshIntervalLabel()
end
