local _, FF = ...
local theme = FF.OptionsTheme.COMMON
FF.OptionsWidgets = {}
local UI = FF.OptionsWidgets

-- Returns a layout value, using the page override when provided and the common value otherwise.
-- Inputs: page configuration table and parameter key. Output: the configured UI value.
function UI.Value(page, key)
    return page[key] ~= nil and page[key] or theme[key]
end

-- Creates an options page with Blizzard's normal settings lifecycle handlers.
-- Inputs: global frame name, displayed name, refresh/default functions, optional hide callback and initial hidden flag.
-- Output: the settings panel frame; registration remains in each page's controller.
function UI.Page(frameName, pageName, onRefresh, onDefault, onHide, initiallyHidden)
    local panel = CreateFrame("Frame", frameName)
    panel.name = pageName
    panel.OnCommit = function() end
    panel.OnDefault = onDefault or function() end
    panel.OnRefresh = onRefresh or function() end
    panel:SetScript("OnShow", function()
        FF:SetSettingsOpen(true)
        if onRefresh then onRefresh() end
    end)
    panel:SetScript("OnHide", function()
        if onHide then onHide() end
        FF:SetSettingsOpen(false)
    end)
    if initiallyHidden then panel:Hide() end
    return panel
end

-- Creates a vertically scrollable settings page using shared viewport insets.
-- Inputs: page frame, page-specific content height and optional content width.
-- Outputs: scroll frame and scroll child used by labels and controls.
function UI.ScrollContent(panel, contentHeight, contentWidth)
    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", theme.SCROLL_LEFT, theme.SCROLL_TOP)
    scroll:SetPoint("BOTTOMRIGHT", theme.SCROLL_RIGHT, theme.SCROLL_BOTTOM)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(contentWidth or theme.CONTENT_WIDTH, contentHeight)
    scroll:SetScrollChild(content)
    return scroll, content
end

-- Creates a text label at the supplied settings-page position.
-- Inputs: parent, caption, font object, X, Y and optional text width/justification. Output: font string.
function UI.Label(parent, caption, font, x, y, width, justify)
    local label = parent:CreateFontString(nil, "ARTWORK", font or theme.LABEL_FONT)
    label:SetPoint("TOPLEFT", x or theme.LABEL_X, y)
    label:SetText(caption)
    if width then label:SetWidth(width) end
    if justify then label:SetJustifyH(justify) end
    return label
end

-- Adds the common title/subtitle pair and returns the next Y cursor and the subtitle label.
-- Inputs: scroll child, title, subtitle and page-specific overrides. Output: next Y, subtitle.
function UI.Header(content, title, subtitle, page)
    local y = theme.INITIAL_Y
    UI.Label(content, title, theme.TITLE_FONT, theme.LABEL_X, y)
    y = y - UI.Value(page, "TITLE_SKIP")
    local sub = UI.Label(content, subtitle, theme.SUBTITLE_FONT, theme.LABEL_X, y,
        page.SUBTITLE_WIDTH, page.SUBTITLE_WIDTH and "LEFT" or nil)
    return y, sub
end

-- Creates a consistent checkbox without altering Blizzard's native size unless CHECKBOX_SIZE is set.
-- Inputs: parent, caption, X, Y, click callback, optional text width/justification. Output: checkbox.
function UI.Checkbox(parent, caption, x, y, onClick, textWidth, justify)
    local checkbox = CreateFrame("CheckButton", nil, parent, theme.CHECKBOX_TEMPLATE)
    checkbox:SetPoint("TOPLEFT", x or theme.CHECKBOX_X, y)
    if theme.CHECKBOX_SIZE then checkbox:SetSize(theme.CHECKBOX_SIZE, theme.CHECKBOX_SIZE) end
    checkbox.Text:SetText(caption)
    checkbox.Text:SetFontObject(theme.CHECKBOX_FONT)
    if textWidth then checkbox.Text:SetWidth(textWidth) end
    if justify then checkbox.Text:SetJustifyH(justify) end
    if onClick then checkbox:SetScript("OnClick", onClick) end
    return checkbox
end

-- Creates a Blizzard settings button at a page-local coordinate.
-- Inputs: parent, caption, X, Y, width, optional height and click handler. Output: button.
function UI.Button(parent, caption, x, y, width, height, onClick)
    local button = CreateFrame("Button", nil, parent, theme.BUTTON_TEMPLATE)
    button:SetPoint("TOPLEFT", x, y)
    button:SetSize(width, height or theme.BUTTON_HEIGHT)
    button:SetText(caption)
    if onClick then button:SetScript("OnClick", onClick) end
    return button
end

-- Creates an editable text box with consistent keyboard handling.
-- Inputs: parent, X, Y, width, height, limit and optional font. Output: edit box.
function UI.Field(parent, x, y, width, height, maxLetters, font)
    local field = CreateFrame("EditBox", nil, parent, theme.INPUT_TEMPLATE)
    field:SetPoint("TOPLEFT", x, y)
    field:SetSize(width, height)
    if font or theme.INPUT_FONT then field:SetFontObject(font or theme.INPUT_FONT) end
    field:SetAutoFocus(false)
    field:SetMaxLetters(maxLetters)
    field:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    field:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    return field
end
