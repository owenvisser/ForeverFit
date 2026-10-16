local _, FF = ...
local UI = FF.OptionsWidgets
local COMMON = FF.OptionsTheme.COMMON

-- Statistics layout parameters (WoW UI units); keep styling separate from saved-data logic.
local L = {
    CONTENT_WIDTH = 555,
    MIN_CONTENT_HEIGHT = 560,
    LEFT = 20,
    TITLE_Y = -16,
    SUBTITLE_Y = -48,
    SUMMARY_Y = -91,
    SUMMARY_WIDTH = 246,
    SUMMARY_HEIGHT = 103,
    SUMMARY_RIGHT_X = 284,
    SUMMARY_INSET = 13,
    FIRST_SECTION_Y = -229,
    TABLE_WIDTH = 510,
    SECTION_HEIGHT = 30,
    COLUMN_HEIGHT = 27,
    ROW_HEIGHT = 25,
    SECTION_GAP = 17,
    BOTTOM_PADDING = 38,
    RESET_SECTION_HEIGHT = 133,
    RESET_INPUT_WIDTH = 157,
    RESET_BUTTON_WIDTH = 185,
    NAME_X = 11,
    NAME_WIDTH = 255,
    DONE_X = 272,
    SKIP_X = 347,
    TOTAL_X = 422,
    NUMBER_WIDTH = 63,
}
local STATISTICS_GROUPS = { "No Equipment", "Free Weights", "Walking Pad", "Custom Exercises" }

-- Creates the read-only Statistics tab, its summaries, and reusable category/table elements.
-- Inputs: shared settings widgets and the layout parameters above. Output: registered Settings tab.
function FF:BuildStatisticsTab()
    local panel = UI.Page("ForeverFitStatisticsPanel", "Statistics",
        function() FF:RefreshStatisticsTab() end)
    local _, content = UI.ScrollContent(panel, L.MIN_CONTENT_HEIGHT, L.CONTENT_WIDTH)

    UI.Label(content, "Statistics", COMMON.TITLE_FONT, L.LEFT, L.TITLE_Y)
    UI.Label(content, "Completed and skipped workouts for this character.",
        COMMON.SUBTITLE_FONT, L.LEFT, L.SUBTITLE_Y)
    UI.Button(content, "Refresh", 420, L.TITLE_Y, 95, COMMON.BUTTON_HEIGHT,
        function() FF:RefreshStatisticsTab() end)

    local summaries = {}
    for _, definition in ipairs({
        { key = "level", title = "Current Level", x = L.LEFT },
        { key = "lifetime", title = "Lifetime", x = L.SUMMARY_RIGHT_X },
    }) do
        local background = content:CreateTexture(nil, "BACKGROUND")
        background:SetColorTexture(0.31, 0.23, 0.12, 0.30)
        background:SetPoint("TOPLEFT", definition.x, L.SUMMARY_Y)
        background:SetSize(L.SUMMARY_WIDTH, L.SUMMARY_HEIGHT)
        UI.Label(content, definition.title, COMMON.SECTION_FONT,
            definition.x + L.SUMMARY_INSET, L.SUMMARY_Y - 12)
        summaries[definition.key] = {
            completed = UI.Label(content, "", "GameFontHighlight", definition.x + L.SUMMARY_INSET,
                L.SUMMARY_Y - 44),
            skipped = UI.Label(content, "", "GameFontHighlight", definition.x + L.SUMMARY_INSET,
                L.SUMMARY_Y - 69),
        }
    end

    local sections = {}
    for _, groupName in ipairs(STATISTICS_GROUPS) do
        local heading = CreateFrame("Frame", nil, content)
        heading:SetSize(L.TABLE_WIDTH, L.SECTION_HEIGHT)
        local headingBackground = heading:CreateTexture(nil, "BACKGROUND")
        headingBackground:SetAllPoints()
        headingBackground:SetColorTexture(0.42, 0.30, 0.11, 0.40)
        local title = heading:CreateFontString(nil, "ARTWORK", COMMON.SECTION_FONT)
        title:SetPoint("LEFT", L.NAME_X, 0)
        title:SetText(groupName)

        local columns = CreateFrame("Frame", nil, content)
        columns:SetSize(L.TABLE_WIDTH, L.COLUMN_HEIGHT)
        for _, definition in ipairs({
            { name = "Exercise", x = L.NAME_X, width = L.NAME_WIDTH, align = "LEFT" },
            { name = "Done", x = L.DONE_X, width = L.NUMBER_WIDTH, align = "CENTER" },
            { name = "Skipped", x = L.SKIP_X, width = L.NUMBER_WIDTH, align = "CENTER" },
            { name = "Total", x = L.TOTAL_X, width = L.NUMBER_WIDTH, align = "CENTER" },
        }) do
            local label = columns:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
            label:SetPoint("LEFT", definition.x, 0)
            label:SetWidth(definition.width)
            label:SetJustifyH(definition.align)
            label:SetText(definition.name)
        end
        sections[groupName] = { heading = heading, columns = columns }
    end
    -- This reset applies to account totals and every character, not just the active one.
    local reset = CreateFrame("Frame", nil, content)
    reset:SetSize(L.TABLE_WIDTH, L.RESET_SECTION_HEIGHT)
    UI.Label(reset, "Reset Workout Statistics", COMMON.SECTION_FONT, 0, 0)
    local warning = UI.Label(reset,
        "Permanently clears all characters' workout history, achievements, and Cheater status.",
        COMMON.SUBTITLE_FONT, 0, -28)
    warning:SetWidth(L.TABLE_WIDTH)
    UI.Label(reset, "Type RESET ALL to confirm:", "GameFontHighlight", 0, -54)
    local confirmation = UI.Field(reset, 195, -50, L.RESET_INPUT_WIDTH, COMMON.CONFIRM_FIELD_HEIGHT, 9)
    local resetButton = UI.Button(reset, "Reset Everything", 0, -84,
        L.RESET_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
    resetButton:Disable()
    confirmation:SetScript("OnTextChanged", function(field)
        resetButton:SetEnabled(field:GetText() == "RESET ALL")
    end)
    confirmation:SetScript("OnEscapePressed", function(field) field:ClearFocus() end)
    confirmation:SetScript("OnEnterPressed", function(field) field:ClearFocus() end)
    resetButton:SetScript("OnClick", function()
        if confirmation:GetText() ~= "RESET ALL" then return end
        FF:ResetStatistics()
        confirmation:SetText("")
        confirmation:ClearFocus()
        FF.Print("All account and character workout statistics and achievements reset. Settings preserved.")
    end)
    self.statisticsTab = { content = content, summary = summaries, sections = sections, rows = {}, reset = reset }
    self.statisticsCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Statistics")
    self:RefreshStatisticsTab()
end

-- Builds grouped exercise records, keeping every built-in exercise and all retired custom history.
-- Inputs: live exercise catalog, SavedVariables custom definitions/history and per-character totals.
-- Output: ordered category tables for the read-only Statistics display.
function FF:GetStatisticsExerciseGroups()
    local groups = {}
    for _, groupName in ipairs(STATISTICS_GROUPS) do groups[groupName] = {} end
    local seen = {}
    for _, exercise in ipairs(self.baseExercises) do
        groups[exercise.group][#groups[exercise.group] + 1] = exercise
        seen[exercise.id] = true
    end
    local completed, skipped = self.stats.lifetime, self.stats.skipsLifetime
    local history = self.stats.exerciseHistory or {}
    for _, exercise in ipairs(self.db.customExercises) do
        if not exercise.deleted or (completed[exercise.id] or 0) > 0
            or (skipped[exercise.id] or 0) > 0 or history[exercise.id] then
            groups["Custom Exercises"][#groups["Custom Exercises"] + 1] = exercise
        end
        seen[exercise.id] = true
    end
    -- Retain saved character history even if a definition no longer exists in the account DB.
    local retired = {}
    for id, exercise in pairs(history) do
        if not seen[id] then
            retired[#retired + 1] = { id = id, name = exercise.name or id, deleted = true }
            seen[id] = true
        end
    end
    for _, counts in ipairs({ completed, skipped }) do
        for id in pairs(counts) do
            if not seen[id] then
                retired[#retired + 1] = { id = id, name = id .. " (retired)", deleted = true }
                seen[id] = true
            end
        end
    end
    table.sort(retired, function(a, b) return a.id < b.id end)
    for _, exercise in ipairs(retired) do
        groups["Custom Exercises"][#groups["Custom Exercises"] + 1] = exercise
    end
    return groups
end

-- Refreshes summaries and four-column tables without changing the stored session counts.
-- Inputs: character SavedVariables and grouped exercise definitions. Output: positioned UI rows.
function FF:RefreshStatisticsTab()
    local view = self.statisticsTab
    if not view or not self.stats then return end

    local level = UnitLevel("player")
    local currentDone = self.stats.levels[level] or {}
    local currentSkipped = self.stats.skipsLevels[level] or {}
    local lifetimeDone, lifetimeSkipped = self.stats.lifetime, self.stats.skipsLifetime
    local levelDoneTotal, levelSkippedTotal, lifetimeDoneTotal, lifetimeSkippedTotal = 0, 0, 0, 0
    for _, count in pairs(currentDone) do levelDoneTotal = levelDoneTotal + count end
    for _, count in pairs(currentSkipped) do levelSkippedTotal = levelSkippedTotal + count end
    for _, count in pairs(lifetimeDone) do lifetimeDoneTotal = lifetimeDoneTotal + count end
    for _, count in pairs(lifetimeSkipped) do lifetimeSkippedTotal = lifetimeSkippedTotal + count end

    local groups = self:GetStatisticsExerciseGroups()
    local y, rowIndex = L.FIRST_SECTION_Y, 0
    for _, groupName in ipairs(STATISTICS_GROUPS) do
        local section = view.sections[groupName]
        section.heading:ClearAllPoints()
        section.heading:SetPoint("TOPLEFT", view.content, "TOPLEFT", L.LEFT, y)
        y = y - L.SECTION_HEIGHT
        section.columns:ClearAllPoints()
        section.columns:SetPoint("TOPLEFT", view.content, "TOPLEFT", L.LEFT, y)
        y = y - L.COLUMN_HEIGHT

        for _, exercise in ipairs(groups[groupName]) do
            rowIndex = rowIndex + 1
            local row = view.rows[rowIndex]
            if not row then
                row = CreateFrame("Frame", nil, view.content)
                row:SetSize(L.TABLE_WIDTH, L.ROW_HEIGHT)
                row.stripe = row:CreateTexture(nil, "BACKGROUND")
                row.stripe:SetAllPoints()
                row.stripe:SetColorTexture(1, 0.82, 0.40, 0.055)
                row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                row.name:SetPoint("LEFT", L.NAME_X, 0)
                row.name:SetWidth(L.NAME_WIDTH)
                row.name:SetJustifyH("LEFT")
                row.values = {}
                for _, x in ipairs({ L.DONE_X, L.SKIP_X, L.TOTAL_X }) do
                    local value = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
                    value:SetPoint("LEFT", x, 0)
                    value:SetWidth(L.NUMBER_WIDTH)
                    value:SetJustifyH("CENTER")
                    row.values[#row.values + 1] = value
                end
                view.rows[rowIndex] = row
            end
            local done = lifetimeDone[exercise.id] or 0
            local skipped = lifetimeSkipped[exercise.id] or 0
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", view.content, "TOPLEFT", L.LEFT, y)
            row.name:SetText(exercise.name)
            row.values[1]:SetText(done)
            row.values[2]:SetText(skipped)
            row.values[3]:SetText(done + skipped)
            row.stripe:SetShown(rowIndex % 2 == 0)
            row:Show()
            y = y - L.ROW_HEIGHT
        end
        y = y - L.SECTION_GAP
    end
    for i = rowIndex + 1, #view.rows do view.rows[i]:Hide() end
    view.reset:ClearAllPoints()
    view.reset:SetPoint("TOPLEFT", view.content, "TOPLEFT", L.LEFT, y - 16)
    y = y - L.RESET_SECTION_HEIGHT - 16
    view.summary.level.completed:SetText(levelDoneTotal .. " completed (level " .. level .. ")")
    view.summary.level.skipped:SetText(levelSkippedTotal .. " skipped")
    view.summary.lifetime.completed:SetText(lifetimeDoneTotal .. " completed")
    view.summary.lifetime.skipped:SetText(lifetimeSkippedTotal .. " skipped")
    view.content:SetHeight(math.max(L.MIN_CONTENT_HEIGHT, -y + L.BOTTOM_PADDING))
end
