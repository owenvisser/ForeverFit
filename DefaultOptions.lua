local _, FF = ...

-- Default Exercises page spacing, independent of other pages.
local DESCRIPTION_SKIP = 25
local EXERCISE_ROW_SKIP = 30
local SMALL_TEXT_SKIP = 10
local TITLE_SKIP = 20
local INTRO_SKIP = 35
local FIELD_SKIP = 15
local NORMAL_SKIP = 25

local groups = {
    { name = "No Equipment", description = "Bodyweight movement and strength; no gear required." },
    { name = "Free Weights", description = "Short dumbbell-based strength sessions." },
    { name = "Walking Pad", description = "Five-minute walks; incline workouts require incline support." },
}

local function Label(parent, text, font, x, y)
    local label = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    label:SetPoint("TOPLEFT", x, y)
    label:SetText(text)
    return label
end

function FF:BuildDefaultOptions()
    local panel = CreateFrame("Frame", "ForeverFitDefaultExercisesPanel")
    panel.name = "Default Exercises"
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() FF:RefreshDefaultOptions() end
    panel:SetScript("OnShow", function()
        FF:SetSettingsOpen(true)
        FF:RefreshDefaultOptions()
    end)
    panel:SetScript("OnHide", function() FF:SetSettingsOpen(false) end)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -30, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(555, 750)
    scroll:SetScrollChild(content)

    local y = -16
    Label(content, "Default Exercises", "GameFontNormalHuge", 20, y)
    y = y - TITLE_SKIP
    Label(content, "Enable a category or individual exercise for the normal workout rotation.",
        "GameFontHighlightSmall", 20, y)
    local groupChecks, exerciseChecks = {}, {}
    y = y - INTRO_SKIP
    for _, group in ipairs(groups) do
        local checkbox = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 18, y)
        checkbox.Text:SetText(group.name)
        checkbox.Text:SetFontObject("GameFontNormal")
        -- checkbox.Text:SetTextColor(0.95, 0.76, 0.40)
        checkbox:SetScript("OnClick", function(self)
            FF.db.enabledGroups[group.name] = self:GetChecked() == true
            FF:OnExerciseSelectionChanged()
            FF:RefreshDefaultOptions()
        end)
        groupChecks[group.name] = checkbox
        local help = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        help:SetSize(22, 21)
        help:SetPoint("TOPLEFT", 140, y - 4)
        help:SetText("?")
        help:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:AddLine(group.name, 1, 0.82, 0.2)
            GameTooltip:AddLine(group.description, 0.86, 0.86, 0.86, true)
            GameTooltip:Show()
        end)
        help:SetScript("OnLeave", function() GameTooltip:Hide() end)
        y = y - DESCRIPTION_SKIP - 5
        Label(content, group.description, "GameFontHighlightSmall", 52, y)
        local matching = {}
        for _, exercise in ipairs(self.baseExercises) do
            if exercise.group == group.name then matching[#matching + 1] = exercise end
        end
        y = y - TITLE_SKIP
        local rows = math.ceil(#matching / 2)
        for i, exercise in ipairs(matching) do
            local col = math.floor((i - 1) / rows)
            local row = (i - 1) % rows
            local x = 20 + col * 264
            local rowY = y - row * EXERCISE_ROW_SKIP
            local item = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
            item:SetPoint("TOPLEFT", x, rowY)
            item.Text:SetText(exercise.name)
            item.Text:SetWidth(191)
            item.Text:SetJustifyH("LEFT")
            item:SetScript("OnClick", function(self)
                FF.db.enabled[exercise.id] = self:GetChecked() == true
                FF:OnExerciseSelectionChanged()
            end)
            exerciseChecks[exercise.id] = item
            local exerciseHelp = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
            exerciseHelp:SetSize(23, 22)
            exerciseHelp:SetPoint("TOPLEFT", x + 220, rowY - 5)
            exerciseHelp:SetText("?")
            exerciseHelp:SetScript("OnEnter", function(button)
                GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
                GameTooltip:AddLine(exercise.name, 1, 0.82, 0.2)
                GameTooltip:AddLine("Goal: " .. exercise.target, 1, 1, 1)
                GameTooltip:AddLine(exercise.instructions, 0.86, 0.86, 0.86, true)
                GameTooltip:Show()
            end)
            exerciseHelp:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
        y = y - rows * EXERCISE_ROW_SKIP - NORMAL_SKIP
    end

    Label(content, "Other", "GameFontNormalLarge", 20, y)
    y = y - TITLE_SKIP
    Label(content, "Controls custom workouts assigned to Other; custom entries are edited on Custom Exercises.",
        "GameFontHighlightSmall", 20, y)
    y = y - FIELD_SKIP
    local other = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    other:SetPoint("TOPLEFT", 18, y)
    other.Text:SetText("Enable Other Category")
    other:SetScript("OnClick", function(self)
        FF.db.enabledGroups.Other = self:GetChecked() == true
        FF:OnExerciseSelectionChanged()
        FF:RefreshCustomOptions()
    end)
    
    content:SetHeight(-y + 70)

    self.defaultOptions = { groupChecks = groupChecks, exerciseChecks = exerciseChecks, other = other }
    self.defaultCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Default Exercises")
end

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
