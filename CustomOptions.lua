local _, FF = ...

-- Custom Exercises page spacing. Change these independently of other pages.
local TITLE_SKIP = 20
local INTRO_SKIP = 35
local CHECKBOX_SKIP = 35
local FIELD_SKIP = 15
local NORMAL_SKIP = 25
local BIG_LINE_SKIP = 35
local SECTION_SKIP = 50
local LIST_HEIGHT = 250


local categories = { "No Equipment", "Free Weights", "Walking Pad", "Other" }

local function Label(parent, text, y, font)
    local label = parent:CreateFontString(nil, "ARTWORK", font or "GameFontNormal")
    label:SetPoint("TOPLEFT", 20, y)
    label:SetText(text)
    return label
end

local function Field(parent, x, y, width, height, maxLetters)
    local field = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    field:SetPoint("TOPLEFT", x, y)
    field:SetSize(width, height)
    field:SetFontObject("ChatFontNormal")
    field:SetMaxLetters(maxLetters)
    field:SetAutoFocus(false)
    field:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    field:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return field
end

function FF:BuildCustomOptions()
    local panel = CreateFrame("Frame", "ForeverFitCustomSettingsPanel")
    panel.name = "Custom Exercises"
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() FF:RefreshCustomOptions() end
    panel:SetScript("OnShow", function()
        FF:SetSettingsOpen(true)
        FF:RefreshCustomOptions()
    end)
    panel:SetScript("OnHide", function() FF:SetSettingsOpen(false) end)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -30, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(555, 900)
    scroll:SetScrollChild(content)

    local y = -16
    Label(content, "Custom Exercises", y, "GameFontNormalHuge")
    y = y - TITLE_SKIP
    local explanation = Label(content,
        "Create personal workouts for the normal exercise rotation. Custom workouts\ncount toward statistics; Other sessions unlock four special challenges.",
        y, "GameFontHighlightSmall")
    explanation:SetWidth(505)
    explanation:SetJustifyH("LEFT")

    y = y - INTRO_SKIP
    local enabledOther = CreateFrame("CheckButton", nil, content, "UICheckButtonTemplate")
    enabledOther:SetPoint("TOPLEFT", 18, y)
    enabledOther.Text:SetText("Enable Other Category")
    enabledOther:SetScript("OnClick", function(self)
        FF.db.enabledGroups.Other = self:GetChecked() == true
        FF:OnExerciseSelectionChanged()
        FF:RefreshDefaultOptions()
    end)

    y = y - CHECKBOX_SKIP
    Label(content, "New Exercise", y, "GameFontNormalLarge")
    y = y - NORMAL_SKIP
    Label(content, "Exercise Name", y)
    y = y - FIELD_SKIP
    local name = Field(content, 22, y, 425, 25, 44)
    y = y - BIG_LINE_SKIP
    Label(content, "Description / Instructions", y)
    y = y - FIELD_SKIP
    local description = Field(content, 22, y, 440, 55, 180)
    description:SetMultiLine(true)
    description:SetTextInsets(2, 2, 3, 2)
    y = y - BIG_LINE_SKIP
    Label(content, "Rep Range / Workout Target", y)
    y = y - FIELD_SKIP
    local target = Field(content, 22, y, 250, 25, 40)
    y = y - BIG_LINE_SKIP
    Label(content, "Exercise Category", y)
    y = y - FIELD_SKIP
    local group = "No Equipment"
    local dropdown = CreateFrame("Frame", "ForeverFitCustomGroupDropdown", content, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 2, y)
    UIDropDownMenu_SetWidth(dropdown, 230)
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

    y = y - FIELD_SKIP
    local status = Label(content, "", y, "GameFontHighlightSmall")
    status:SetWidth(510)
    y = y - BIG_LINE_SKIP
    local save = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    save:SetPoint("TOPLEFT", 22, y)
    save:SetSize(156, 27)
    save:SetText("Add Exercise")
    local clear = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    clear:SetPoint("LEFT", save, "RIGHT", 12, 0)
    clear:SetSize(115, 27)
    clear:SetText("New / Clear")
    local editingID
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
    y = y - SECTION_SKIP
    Label(content, "Saved Custom Exercises", y, "GameFontNormalLarge")
    y = y - TITLE_SKIP
    local note = Label(content,
        "Checkboxes control rotation; category switches in Default Exercises also apply.\nRemoving an exercise hides it but retains its historical workout statistics.",
        y, "GameFontHighlightSmall")
    note:SetWidth(510)
    note:SetJustifyH("LEFT")

    y = y - INTRO_SKIP
    local listScroll = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    listScroll:SetPoint("TOPLEFT", 18, y)
    listScroll:SetSize(480, LIST_HEIGHT)
    local list = CreateFrame("Frame", nil, listScroll)
    list:SetSize(455, LIST_HEIGHT)
    listScroll:SetScrollChild(list)
    content:SetHeight(-y + LIST_HEIGHT + 40)
    local rows = {}
    local function GetRow(i)
        if rows[i] then return rows[i] end
        local row = CreateFrame("Frame", nil, list)
        row:SetSize(455, NORMAL_SKIP - 1)
        row:SetPoint("TOPLEFT", 0, -((i - 1) * NORMAL_SKIP))
        row.check = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
        row.check:SetPoint("LEFT", 1, 0)
        row.name = row:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
        row.name:SetPoint("LEFT", 36, 0)
        row.name:SetWidth(245)
        row.name:SetJustifyH("LEFT")
        row.edit = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.edit:SetPoint("LEFT", 290, 0)
        row.edit:SetSize(68, 25)
        row.edit:SetText("Edit")
        row.delete = CreateFrame("Button", nil, row, "UIPanelButtonTemplate")
        row.delete:SetPoint("LEFT", 365, 0)
        row.delete:SetSize(76, 25)
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
        list:SetHeight(math.max(LIST_HEIGHT, #visible * NORMAL_SKIP))
    end }
    self.customCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Custom Exercises")
end

function FF:RefreshCustomOptions()
    if self.customOptions and self.db then self.customOptions.refresh() end
end
