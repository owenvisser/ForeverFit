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
    y = y - P.SHORT_LINE_SKIP
    content:SetHeight(-y + P.CONTENT_BOTTOM_PADDING)
    self.infoCategory = Settings.RegisterCanvasLayoutSubcategory(self.category, panel, "Info")
end
