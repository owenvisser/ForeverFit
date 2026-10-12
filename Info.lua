local _, FF = ...

-- Info page spacing (independent of the other settings pages).
local TITLE_SKIP = 36
local SHORT_LINE_SKIP = 8
local BIG_LINE_SKIP = 18
local SECTION_SKIP = 32
local CHANGELOG_LINE_SKIP = 7
local MIN_LINE_HEIGHT = 18

local description =
    "Forever Fit turns the downtime between quests into short exercise breaks. " ..
    "Choose your workouts, set a reminder, and earn your own Fitness Challenges " ..
    "as you adventure through Azeroth."

local encouragement =
    "Heroes come in every shape, class, and level. Whether you lift like an orc, " ..
    "stroll like a leisurely tauren, or stretch between raids, there's a way to move " ..
    "that works for you. No epic gear required—every small step earns its place in Azeroth!"

local changelog = {
    "v0.1.31 - Added campfire reminders, five-minute login protection, and account-wide achievements.",
    "v0.1.30 - Fixed a login Lua error when custom exercises were included in achievement chat-link registration.",
    "v0.1.29 - Matched cheer/chicken voices to race and gender; added Human Male Only sound option.",
    "v0.1.28 - Moved instructions beside the exercise icon; locked regular popups against moving and resizing.",
    "v0.1.27 - Added a movable, resizable popup preview with per-character saved layout.",
    "v0.1.26 - Independent vertical spacing controls for each settings page; streamlined Info page.",
    "v0.1.25 - Organized main, Default Exercises, Custom Exercises, and Info settings pages.",
    "v0.1.24 - Fixed settings refresh errors after creating custom exercises.",
    "v0.1.23 - Added custom exercises, Other challenges, and the Cheater apology.",
    "v0.1.22 - Switched workout sounds to native cheer and chicken audio.",
    "v0.1.21 - Allowed all exercises to be disabled, pausing reminders automatically.",
    "v0.1.20 - Flexible milestone requirements and settings-to-challenges navigation.",
    "v0.1.18 - Taxi workout triggers, exercise updates, and the Cheater lockout.",
    "v0.1.16 - Linked exercise achievements across Beginner, Intermediate, Expert, and Godly.",
    "v0.1.13 - Achievement-link tooltips, earned dates, and icon improvements.",
}

local function Label(parent, text, font, y)
    local label = parent:CreateFontString(nil, "ARTWORK", font)
    label:SetPoint("TOPLEFT", 20, y)
    label:SetWidth(490)
    label:SetJustifyH("LEFT")
    label:SetText(text)
    return label
end

function FF:BuildInfoOptions()
    local panel = CreateFrame("Frame", "ForeverFitInfoPanel")
    panel.name = "Info"
    panel.OnCommit = function() end
    panel.OnDefault = function() end
    panel.OnRefresh = function() end
    panel:SetScript("OnShow", function() FF:SetSettingsOpen(true) end)
    panel:SetScript("OnHide", function() FF:SetSettingsOpen(false) end)

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 6, -6)
    scroll:SetPoint("BOTTOMRIGHT", -30, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(535, 820)
    scroll:SetScrollChild(content)

    local y = -16
    Label(content, "Forever Fit", "GameFontNormalHuge", y)
    y = y - TITLE_SKIP
    Label(content, "About", "GameFontNormalLarge", y)
    y = y - SECTION_SKIP
    local intro = Label(content, description, "GameFontHighlight", y)
    y = y - math.max(intro:GetStringHeight(), 52) - BIG_LINE_SKIP
    local inclusive = Label(content, encouragement, "GameFontHighlight", y)
    y = y - math.max(inclusive:GetStringHeight(), 70) - BIG_LINE_SKIP

    Label(content, "Changelog", "GameFontNormalLarge", y)
    y = y - SECTION_SKIP
    for _, entry in ipairs(changelog) do
        local line = Label(content, entry, "GameFontHighlightSmall", y)
        y = y - math.max(line:GetStringHeight(), MIN_LINE_HEIGHT) - CHANGELOG_LINE_SKIP
    end
    y = y - SHORT_LINE_SKIP
    content:SetHeight(-y + 25)
    self.infoCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Info")
end
