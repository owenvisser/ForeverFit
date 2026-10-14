local _, FF = ...

-- Form and list geometry use the shared theme with explicit Custom-only parameters.
local UI = FF.OptionsWidgets
local COMMON = FF.OptionsTheme.COMMON
local P = FF.OptionsTheme.CUSTOM

local categories = { "No Equipment", "Free Weights", "Walking Pad", "Other" }

-- Builds the custom-workout editor, category selector and saved-exercise list.
-- Inputs: account exercise catalog and shared settings parameters. Output: the Custom Exercises page.
function FF:BuildCustomOptions()
    local panel = UI.Page("ForeverFitCustomSettingsPanel", "Custom Exercises",
        function() FF:RefreshCustomOptions() end)
    local scroll, content = UI.ScrollContent(panel, P.CONTENT_HEIGHT)

    local y, explanation = UI.Header(content, "Custom Exercises",
        "Create personal workouts for the normal exercise rotation. Custom workouts\ncount toward statistics; Other sessions unlock four special challenges.", P)

    y = y - COMMON.INTRO_SKIP
    local enabledOther = UI.Checkbox(content, "Enable Other Category", COMMON.CHECKBOX_X, y, function(self)
        FF.db.enabledGroups.Other = self:GetChecked() == true
        FF:OnExerciseSelectionChanged()
        FF:RefreshDefaultOptions()
    end)

    y = y - COMMON.CHECKBOX_SKIP
    UI.Label(content, "New Exercise", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - P.NORMAL_SKIP
    UI.Label(content, "Exercise Name", COMMON.LABEL_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local name = UI.Field(content, P.FORM_X, y, P.NAME_FIELD_WIDTH,
        COMMON.TEXT_FIELD_HEIGHT, P.NAME_FIELD_MAX_LETTERS)
    y = y - P.BIG_LINE_SKIP
    UI.Label(content, "Description / Instructions", COMMON.LABEL_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local description = UI.Field(content, P.FORM_X, y, P.DESCRIPTION_FIELD_WIDTH,
        P.DESCRIPTION_FIELD_HEIGHT, P.DESCRIPTION_FIELD_MAX_LETTERS)
    description:SetMultiLine(true)
    description:SetTextInsets(P.DESCRIPTION_INSET_LEFT, P.DESCRIPTION_INSET_RIGHT,
        P.DESCRIPTION_INSET_TOP, P.DESCRIPTION_INSET_BOTTOM)
    y = y - P.BIG_LINE_SKIP
    UI.Label(content, "Rep Range / Workout Target", COMMON.LABEL_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local target = UI.Field(content, P.FORM_X, y, P.TARGET_FIELD_WIDTH,
        COMMON.TEXT_FIELD_HEIGHT, P.TARGET_FIELD_MAX_LETTERS)
    y = y - P.BIG_LINE_SKIP
    UI.Label(content, "Exercise Category", COMMON.LABEL_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.FIELD_SKIP
    local group = "No Equipment"
    local dropdown = CreateFrame("Frame", "ForeverFitCustomGroupDropdown", content, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", P.DROPDOWN_X, y)
    UIDropDownMenu_SetWidth(dropdown, P.DROPDOWN_WIDTH)
    -- Changes the draft exercise category and updates its dropdown caption.
    -- Input: a built-in category name or Other.
    local function SetGroup(value)
        group = value
        UIDropDownMenu_SetText(dropdown, value)
    end
    UIDropDownMenu_Initialize(dropdown, function(_, level)
        for _, value in ipairs(categories) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.checked = group == value
            info.func = function() SetGroup(value) end
            UIDropDownMenu_AddButton(info, level)
        end
    end)
    SetGroup(group)

    y = y - COMMON.FIELD_SKIP
    local status = UI.Label(content, "", COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y,
        P.STATUS_WIDTH, "LEFT")
    y = y - P.BIG_LINE_SKIP
    local save = UI.Button(content, "Add Exercise", P.FORM_X, y, P.SAVE_BUTTON_WIDTH)
    local clear = CreateFrame("Button", nil, content, COMMON.BUTTON_TEMPLATE)
    clear:SetPoint("LEFT", save, "RIGHT", P.CLEAR_BUTTON_GAP, 0)
    clear:SetSize(P.CLEAR_BUTTON_WIDTH, COMMON.BUTTON_HEIGHT)
    clear:SetText("New / Clear")
    local editingID
    -- Clears the draft editor without changing any saved custom exercise.
    -- Inputs: current form values. Output: a blank Add Exercise form.
    local function ClearForm()
        editingID = nil
        name:SetText("")
        description:SetText("")
        target:SetText("")
        SetGroup("No Equipment")
        save:SetText("Add Exercise")
    end
    clear:SetScript("OnClick", function() ClearForm(); status:SetText("") end)
    save:SetScript("OnClick", function()
        local exercise, message = FF:SaveCustomExercise(editingID, name:GetText(),
            description:GetText(), target:GetText(), group)
        if not exercise then status:SetText(message); return end
        ClearForm()
        status:SetText("Saved: " .. exercise.name .. ". Existing workout counts are preserved.")
        FF:RefreshCustomOptions()
    end)
    y = y - COMMON.SECTION_SKIP
    UI.Label(content, "Saved Custom Exercises", COMMON.SECTION_FONT, COMMON.LABEL_X, y)
    y = y - COMMON.TITLE_SKIP
    local note = UI.Label(content,
        "Checkboxes control rotation; category switches in Default Exercises also apply.\nRemoving an exercise hides it but retains its historical workout statistics.",
        COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y, P.SAVED_NOTE_WIDTH, "LEFT")

    y = y - COMMON.INTRO_SKIP
    local listScroll = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", P.LIST_X, y)
    listScroll:SetSize(P.LIST_WIDTH, P.LIST_HEIGHT)
    local list = CreateFrame("Frame", nil, listScroll)
    list:SetSize(P.LIST_CONTENT_WIDTH, P.LIST_HEIGHT)
    listScroll:SetScrollChild(list)
    content:SetHeight(-y + P.LIST_HEIGHT + P.LIST_BOTTOM_PADDING)
    local rows = {}
    -- Returns the indexed saved-exercise row, creating its controls only once.
    -- Input: one-based row index. Output: existing or newly created row frame.
    local function GetRow(i)
        if rows[i] then return rows[i] end
        local row = CreateFrame("Frame", nil, list)
        row:SetSize(P.LIST_CONTENT_WIDTH, P.NORMAL_SKIP - P.ROW_RIGHT_PADDING)
        row:SetPoint("TOPLEFT", 0, -((i - 1) * P.NORMAL_SKIP))
        row.check = CreateFrame("CheckButton", nil, row, COMMON.CHECKBOX_TEMPLATE)
        row.check:SetPoint("LEFT", P.ROW_CHECKBOX_X, 0)
        if COMMON.CHECKBOX_SIZE then row.check:SetSize(COMMON.CHECKBOX_SIZE, COMMON.CHECKBOX_SIZE) end
        row.check.Text:SetFontObject(COMMON.CHECKBOX_FONT)
        row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        row.name:SetPoint("LEFT", P.ROW_LABEL_X, 0)
        row.name:SetWidth(P.ROW_LABEL_WIDTH)
        row.name:SetJustifyH("LEFT")
        row.edit = CreateFrame("Button", nil, row, COMMON.BUTTON_TEMPLATE)
        row.edit:SetPoint("LEFT", P.ROW_EDIT_X, 0)
        row.edit:SetSize(P.ROW_EDIT_WIDTH, P.ROW_BUTTON_HEIGHT)
        row.edit:SetText("Edit")
        row.delete = CreateFrame("Button", nil, row, COMMON.BUTTON_TEMPLATE)
        row.delete:SetPoint("LEFT", P.ROW_DELETE_X, 0)
        row.delete:SetSize(P.ROW_DELETE_WIDTH, P.ROW_BUTTON_HEIGHT)
        row.delete:SetText("Remove")
        rows[i] = row
        return row
    end
    self.customOptions = { panel = panel, enabledOther = enabledOther, refresh = function()
        local visible = {}
        for _, exercise in ipairs(FF.db.customExercises) do
            if not exercise.deleted then visible[#visible + 1] = exercise end
        end
        enabledOther:SetChecked(FF.db.enabledGroups.Other == true)
        for i, exercise in ipairs(visible) do
            local row = GetRow(i)
            row:Show()
            row.name:SetText(exercise.name .. " (" .. exercise.group .. ")")
            row.check:SetChecked(FF.db.enabled[exercise.id] == true)
            row.check:SetScript("OnClick", function(self)
                FF.db.enabled[exercise.id] = self:GetChecked() == true
                FF:OnExerciseSelectionChanged()
            end)
            row.edit:SetScript("OnClick", function()
                editingID = exercise.id
                name:SetText(exercise.name)
                description:SetText(exercise.instructions)
                target:SetText(exercise.target)
                SetGroup(exercise.group)
                save:SetText("Save Changes")
                scroll:SetVerticalScroll(0)
                status:SetText("Editing " .. exercise.name .. ". Its workout history will be retained.")
            end)
            row.delete:SetScript("OnClick", function()
                StaticPopupDialogs.FOREVERFIT_REMOVE_EXERCISE = {
                    text = "Remove " .. exercise.name .. "? Existing workout statistics will remain saved.",
                    button1 = YES, button2 = NO, timeout = 0, whileDead = true, hideOnEscape = true,
                    OnAccept = function()
                        FF:DeleteCustomExercise(exercise.id)
                        if editingID == exercise.id then ClearForm() end
                        FF:RefreshCustomOptions()
                    end,
                }
                StaticPopup_Show("FOREVERFIT_REMOVE_EXERCISE")
            end)
        end
        for i = #visible + 1, #rows do rows[i]:Hide() end
        list:SetHeight(math.max(P.LIST_HEIGHT, #visible * P.NORMAL_SKIP))
    end }
    self.customCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Custom Exercises")
end

-- Refreshes editable custom-exercise rows from the account database.
-- Input: FF.db.customExercises. Output: current list rows.
function FF:RefreshCustomOptions()
    if self.customOptions and self.db then self.customOptions.refresh() end
end
