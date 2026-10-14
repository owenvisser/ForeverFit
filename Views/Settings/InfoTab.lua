local _, FF = ...

-- Info uses shared typography, scroll widgets and label placement with a small number of page overrides.
local UI = FF.OptionsWidgets
local COMMON = FF.OptionsTheme.COMMON
local P = FF.OptionsTheme.INFO

local description =
    "Forever Fit turns the downtime between quests into short exercise breaks. " ..
    "Choose your workouts, set a reminder, and earn your own Fitness Challenges " ..
    "as you adventure through Azeroth."

local encouragement =
    "Heroes come in every shape, class, and level. Whether you lift like an orc, " ..
    "stroll like a leisurely tauren, or stretch between raids, there's a way to move " ..
    "that works for you. No epic gear required—every small step earns its place in Azeroth!"

local changelog = {
    "v1.1.0 - Shared settings layouts and widgets; centralized editable options theme.",
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

-- Builds the addon description and changelog page using shared formatting.
-- Inputs: Info text, shared theme and measured font heights. Output: registered Info page.
function FF:BuildInfoOptions()
    local panel = UI.Page("ForeverFitInfoPanel", "Info")
    local scroll, content = UI.ScrollContent(panel, P.CONTENT_HEIGHT, P.CONTENT_WIDTH)

    local y = COMMON.INITIAL_Y
    UI.Label(content, "Forever Fit", COMMON.TITLE_FONT, COMMON.LABEL_X, y, P.TEXT_WIDTH, "LEFT")
    y = y - COMMON.TITLE_SKIP
    UI.Label(content, "About", COMMON.SECTION_FONT, COMMON.LABEL_X, y, P.TEXT_WIDTH, "LEFT")
    y = y - COMMON.SECTION_SKIP
    local intro = UI.Label(content, description, "GameFontHighlight", COMMON.LABEL_X, y,
        P.TEXT_WIDTH, "LEFT")
    y = y - math.max(intro:GetStringHeight(), P.DESCRIPTION_MIN_HEIGHT) - P.BIG_LINE_SKIP
    local inclusive = UI.Label(content, encouragement, "GameFontHighlight", COMMON.LABEL_X, y,
        P.TEXT_WIDTH, "LEFT")
    y = y - math.max(inclusive:GetStringHeight(), P.ENCOURAGEMENT_MIN_HEIGHT) - P.BIG_LINE_SKIP

    UI.Label(content, "Changelog", COMMON.SECTION_FONT, COMMON.LABEL_X, y, P.TEXT_WIDTH, "LEFT")
    y = y - COMMON.SECTION_SKIP
    for _, entry in ipairs(changelog) do
        local line = UI.Label(content, entry, COMMON.SUBTITLE_FONT, COMMON.LABEL_X, y,
            P.TEXT_WIDTH, "LEFT")
        y = y - math.max(line:GetStringHeight(), P.MIN_LINE_HEIGHT) - P.CHANGELOG_LINE_SKIP
    end
    y = y - P.SHORT_LINE_SKIP
    content:SetHeight(-y + P.CONTENT_BOTTOM_PADDING)
    self.infoCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Info")
end
