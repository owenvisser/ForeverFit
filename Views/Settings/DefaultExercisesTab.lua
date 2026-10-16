local _, FF = ...

-- Page-specific controls use the same widgets and spacing definitions as the other settings pages.
local UI = FF.OptionsWidgets
local COMMON = FF.OptionsTheme.COMMON
local P = FF.OptionsTheme.DEFAULT
local groups = {
    { name = "No Equipment", description = "Bodyweight movement and strength; no gear required." },
    { name = "Free Weights", description = "Short dumbbell-based strength sessions." },
    { name = "Walking Pad", description = "Five-minute walks; incline workouts require incline support." },
}

-- Builds category and built-in exercise controls using the shared settings widgets.
-- Input: FF.baseExercises and shared parameters. Output: the Default Exercises page.
function FF:BuildDefaultOptions()
    local panel = UI.Page("ForeverFitDefaultExercisesPanel", "Default Exercises",
        function() FF:RefreshDefaultOptions() end)
    local scroll, content = UI.ScrollContent(panel, P.CONTENT_HEIGHT)

    local y = COMMON.INITIAL_Y
    UI.Label(content, "Default Exercises", COMMON.TITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    UI.Label(content, "Enable a category or individual exercise for the normal workout rotation.",
        COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    local groupChecks, exerciseChecks = {}, {}
    y = y - COMMON.INTRO_SKIP
    for _, group in ipairs(groups) do
        local checkbox = UI.Checkbox(content, group.name, COMMON.CHECKBOX_X, y, function(self)
            FF.db.enabledGroups[group.name] = self:GetChecked() == true
            FF:OnExerciseSelectionChanged()
            FF:RefreshDefaultOptions()
        end)
        groupChecks[group.name] = checkbox
        local help = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        help:SetSize(P.CATEGORY_HELP_WIDTH, P.CATEGORY_HELP_HEIGHT)
        help:SetPoint("TOPLEFT", P.CATEGORY_HELP_X, y + P.CATEGORY_HELP_Y_OFFSET)
        help:SetText("?")
        help:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:AddLine(group.name, 1, 0.82, 0.2)
            GameTooltip:AddLine(group.description, 0.86, 0.86, 0.86, true)
            GameTooltip:Show()
        end)
        help:SetScript("OnLeave", function() GameTooltip:Hide() end)
        y = y - P.DESCRIPTION_SKIP - P.CATEGORY_DESCRIPTION_EXTRA_GAP
        UI.Label(content, group.description, COMMON.SUBTITLE_FONT, P.CATEGORY_DESCRIPTION_X, y)
        local matching = {}
        for _, exercise in ipairs(self.baseExercises) do
            if exercise.group == group.name then matching[#matching + 1] = exercise end
        end
        y = y - COMMON.TITLE_SKIP
        local rows = math.ceil(#matching / 2)
        for i, exercise in ipairs(matching) do
            local col = math.floor((i - 1) / rows)
            local row = (i - 1) % rows
            local x = P.COLUMN_LEFT_X + col * P.COLUMN_DISTANCE
            local rowY = y - row * P.EXERCISE_ROW_SKIP
            local item = UI.Checkbox(content, exercise.name, x, rowY, function(self)
                FF.db.enabled[exercise.id] = self:GetChecked() == true
                FF:OnExerciseSelectionChanged()
            end, P.EXERCISE_TEXT_WIDTH, "LEFT")
            exerciseChecks[exercise.id] = item
            local exerciseHelp = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            exerciseHelp:SetSize(P.EXERCISE_HELP_WIDTH, P.EXERCISE_HELP_HEIGHT)
            exerciseHelp:SetPoint("TOPLEFT", x + P.EXERCISE_HELP_X_OFFSET,
                rowY + P.EXERCISE_HELP_Y_OFFSET)
            exerciseHelp:SetText("?")
            exerciseHelp:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:AddLine(exercise.name, 1, 0.82, 0.2)
                GameTooltip:AddLine(exercise.instructions, 0.86, 0.86, 0.86, true)
                GameTooltip:Show()
            end)
            exerciseHelp:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        y = y - rows * P.EXERCISE_ROW_SKIP - P.NORMAL_SKIP
    end

    UI.Label(content, "Other", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    UI.Label(content, "Controls custom workouts assigned to Other; custom entries are edited on Custom Exercises.",
        COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local other = UI.Checkbox(content, "Enable Other Category", COMMON.CHECKBOX_X, y, function(self)
        FF.db.enabledGroups.Other = self:GetChecked() == true
        FF:OnExerciseSelectionChanged()
        FF:RefreshCustomOptions()
    end)
    
    content:SetHeight(-y + P.CONTENT_BOTTOM_PADDING)

    self.defaultOptions = { groupChecks = groupChecks, exerciseChecks = exerciseChecks, other = other }
    self.defaultCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Default Exercises")
end

-- Synchronizes category and exercise checkboxes from saved enabled states.
-- Input: FF.db.enabledGroups and FF.db.enabled. Output: refreshed page controls.
function FF:RefreshDefaultOptions()
    if not self.defaultOptions or not self.db then return end
    local opts = self.defaultOptions
    for group, checkbox in pairs(opts.groupChecks) do
        checkbox:SetChecked(self.db.enabledGroups[group] == true)
    end
    for _, exercise in ipairs(self.baseExercises) do
        local checkbox = opts.exerciseChecks[exercise.id]
        local active = self.db.enabledGroups[exercise.group] == true
        checkbox:SetChecked(self.db.enabled[exercise.id] == true)
        checkbox:SetEnabled(active)
        checkbox:SetAlpha(active and 1 or 0.45)
    end
    opts.other:SetChecked(self.db.enabledGroups.Other == true)
end
