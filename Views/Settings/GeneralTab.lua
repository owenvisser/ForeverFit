local _, FF = ...

-- The same theme controls all settings pages; MAIN contains only deliberate page exceptions.
local UI = FF.OptionsWidgets
local COMMON = FF.OptionsTheme.COMMON
local P = FF.OptionsTheme.MAIN
local AddText = UI.Label

-- Builds the General settings tab; category registration is handled by SettingsController.lua.
-- Inputs: FF database, statistics, and the shared options theme. Output: registered settings controls.
function FF:BuildGeneralTab()
    local panel = UI.Page("ForeverFitSettingsPanel", "Forever Fit",
        function() FF:RefreshOptions() end,
        function()
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
        end,
        function() FF:HidePopupPreview() end, true)
    local scroll, content = UI.ScrollContent(panel, P.CONTENT_HEIGHT)

    local y = COMMON.INITIAL_Y
    AddText(content, "Forever Fit", COMMON.TITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    local subtitle = AddText(content, "Your character will be fit forever, and so should you.", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    subtitle:SetWidth(P.SUBTITLE_WIDTH)
    subtitle:SetJustifyH("LEFT")
    self.settingsSubtitle = subtitle

    y = y - COMMON.INTRO_SKIP
    AddText(content, "Reminder interval", COMMON.LABEL_FONT, COMMON.LABEL_X, y)
    self.intervalLabel = AddText(content, "", "GameFontHighlight", P.SLIDER_LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local slider = CreateFrame("Slider", "ForeverFitIntervalSlider", content, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", P.SLIDER_X, y)
    slider:SetSize(P.SLIDER_WIDTH, P.SLIDER_HEIGHT)
    slider:SetMinMaxValues(P.SLIDER_MINUTES_MIN, P.SLIDER_MINUTES_MAX)
    slider:SetValueStep(P.SLIDER_MINUTES_STEP)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText(P.SLIDER_MINUTES_MIN .. " min")
    slider.High:SetText(P.SLIDER_MINUTES_MAX .. " min")
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
        { "partyBreakAnnounce", "Tell party members when you're taking an exercise break." },
        { "partyInviteAnnounce", "Invite party members to join your exercise! ForeverFit together!" },
        { "taxiBreak", "Trigger an exercise when boarding a flight-path taxi." },
        { "campfireBreak", "Trigger an exercise when Welcoming Campfire begins (never twice in a row)." },
        { "soundEnabled", "Play race-specific voice sounds for Completed and Skip." },
    }
    self.announceChecks = {}
    y = y - COMMON.SECTION_SKIP
    for _, entry in ipairs(settings) do
        local checkbox = UI.Checkbox(content, entry[2], COMMON.CHECKBOX_X, y, function(self)
            FF.db[entry[1]] = self:GetChecked() == true
            if entry[1] == "taxiBreak" then FF:UpdateTaxiWatcher() end
            if entry[1] == "campfireBreak" then FF.state.wasWelcomingCampfire = FF:HasWelcomingCampfire() end
            if entry[1] == "soundEnabled" then FF:RefreshOptions() end
        end, P.CHECKBOX_TEXT_WIDTH, "LEFT")
        self.announceChecks[entry[1]] = checkbox
        y = y - COMMON.CHECKBOX_SKIP
    end
    local humanOnly = UI.Checkbox(content, "Human Male Only (override race and gender)",
        P.SOUND_OVERRIDE_X, y + P.SOUND_OVERRIDE_Y_OFFSET, function(self)
            FF.db.soundHumanMaleOnly = self:GetChecked() == true
        end, P.SOUND_OVERRIDE_TEXT_WIDTH, "LEFT")
    self.soundHumanMaleOnlyCheck = humanOnly
    y = y - COMMON.CHECKBOX_SKIP
    y = y - P.DESCRIPTION_SKIP
    AddText(content, "Party options work independently and only for parties, not raids. Don't make the raid wait, workout before or after!", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    y = y - P.DESCRIPTION_SKIP
    AddText(content, "The timer will stay paused until Complete or Skip is selected.", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)

    y = y - COMMON.SECTION_SKIP
    AddText(content, "View your Achievements in the Fitness Challenges tab!", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    AddText(content, "Additionally, use /ffit stats for exercise totals.", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local achievements = UI.Button(content, "View Fit Challenges", COMMON.LABEL_X, y, P.CHALLENGES_BUTTON_WIDTH, P.CHALLENGES_BUTTON_HEIGHT)
    achievements:SetScript("OnClick", function()
        -- Settings otherwise covers the embedded Legacy Challenges page.
        if SettingsPanel and SettingsPanel:IsShown() then
            HideUIPanel(SettingsPanel)
        end
        C_Timer.After(0, function() FF:OpenFitChallenges() end)
    end)

    y = y - COMMON.SECTION_SKIP
    AddText(content, "Exercise Selection", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    AddText(content, "Select built-in exercises on the Default Exercises page.",
        COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local selectExercises = UI.Button(content, "Default Exercises", COMMON.LABEL_X, y, P.DEFAULTS_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
    selectExercises:SetScript("OnClick", function()
        Settings.OpenToCategory(FF.defaultCategory:GetID())
    end)

    y = y - COMMON.SECTION_SKIP
    AddText(content, "Workout Popup Layout", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    local layoutHelp = AddText(content,
        "Move the preview by dragging it, or resize from its bottom-right corner. Changes save for this character.",
        COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    layoutHelp:SetWidth(P.LAYOUT_HELP_WIDTH)
    layoutHelp:SetJustifyH("LEFT")
    y = y - COMMON.INTRO_SKIP
    local previewButton = UI.Button(content, "Preview / Move / Resize", COMMON.LABEL_X, y, P.PREVIEW_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
    previewButton:SetScript("OnClick", function() FF:ShowPopupPreview() end)
    local resetLayoutButton = UI.Button(content, "Reset Popup Layout", P.RESET_LAYOUT_BUTTON_X, y, P.RESET_LAYOUT_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
    resetLayoutButton:SetScript("OnClick", function() FF:ResetPopupLayout() end)

    y = y - COMMON.SECTION_SKIP
    local apologyStartY = y
    local apologyTitle = AddText(content, "Cheater Apology", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    local apologyDescription = AddText(content, "Removes only the Cheater lockout. All workout statistics remain.", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local apologyInstruction = AddText(content, "Type exactly: Whoops, I'm a cheater", "GameFontHighlight", COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local apology = UI.Field(content, COMMON.LABEL_X, y,
        P.APOLOGY_FIELD_WIDTH, COMMON.CONFIRM_FIELD_HEIGHT, P.APOLOGY_FIELD_MAX_LETTERS)
    local forgive = CreateFrame("Button", nil, content, COMMON.BUTTON_TEMPLATE)
    forgive:SetPoint("LEFT", apology, "RIGHT", P.APOLOGY_BUTTON_OFFSET, 0)
    forgive:SetSize(P.APOLOGY_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
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
    self.apologyControls = { apologyTitle, apologyDescription, apologyInstruction, apology, forgive }
    self.apologyContent = content
    self.apologyStartY = apologyStartY
    self.apologyEndY = y
    content:SetHeight(-y + P.CONTENT_BOTTOM_PADDING)

    return panel
end

-- Displays the saved reminder interval on the main page.
-- Input: FF.db.minutes. Output: updated label text.
function FF:RefreshIntervalLabel()
    self.intervalLabel:SetText(self.db.minutes .. " minutes")
end

-- Refreshes main-page controls from saved preferences and current account state.
-- Inputs: saved settings, active exercise count and Cheater state. Output: current UI values.
function FF:RefreshOptions()
    if not self.db or not self.intervalSlider then return end
    local showApology = self.stats.cheater == true
    for _, control in ipairs(self.apologyControls) do control:SetShown(showApology) end
    self.apologyContent:SetHeight(-(showApology and self.apologyEndY or self.apologyStartY) + P.CONTENT_BOTTOM_PADDING)
    self.forgiveButton:SetEnabled(showApology and self.apologyField:GetText() == "Whoops, I'm a cheater")
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
