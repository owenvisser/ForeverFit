local _, FF = ...

-- Native AchievementAlertFrameTemplate dimensions; scale and screen position are independent.
local ALERT_WIDTH = 300
local ALERT_HEIGHT = 101
local ALERT_SCALE = 1.0
local ALERT_BOTTOM_OFFSET = 195

-- Separate parameters for text placement inside Blizzard's achievement banner.
local ALERT_TEXT_CENTER_X = 7
local ALERT_TEXT_TOP = 23
local ALERT_TEXT_WIDTH = 155
local ALERT_NAME_HEIGHT = 36

-- Timing and sound remain unchanged.
local ALERT_DURATION = 5
local ALERT_FADE_IN = 0.25
local ALERT_FADE_OUT = 0.75
local ACHIEVEMENT_EARNED_SOUND = 12891

FF.achievementAlertQueue = FF.achievementAlertQueue or {}

-- Creates the reusable popup using Blizzard's achievement alert atlas and native anchors.
function FF:BuildAchievementAlert()
    if self.achievementAlertFrame then return end

    local alert = CreateFrame("Frame", nil, UIParent)
    alert:SetSize(ALERT_WIDTH, ALERT_HEIGHT)
    alert:SetScale(ALERT_SCALE)
    alert:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, ALERT_BOTTOM_OFFSET)
    alert:SetFrameStrata("DIALOG")
    alert:EnableMouse(true)
    -- Open the actual earned achievement, not merely the default achievement page.
    alert:SetScript("OnMouseUp", function(frame, mouseButton)
        if mouseButton == "LeftButton" and frame.achievementID then
            FF:OpenAchievement(frame.achievementID)
        end
    end)
    alert:Hide()

    -- The atlas includes the correct crop and native size; do not stretch the old texture file.
    alert.background = alert:CreateTexture(nil, "BACKGROUND")
    alert.background:SetAtlas("ui-achievement-alert-background", true)
    alert.background:SetPoint("CENTER", alert, "CENTER")

    -- Blizzard's icon frame is a separate 78x75 element at the banner's left edge.
    alert.iconFrame = CreateFrame("Frame", nil, alert)
    alert.iconFrame:SetSize(78, 75)
    alert.iconFrame:SetPoint("TOPLEFT", alert, "TOPLEFT", -4, -15)

    alert.icon = alert.iconFrame:CreateTexture(nil, "ARTWORK")
    alert.icon:SetSize(52, 52)
    alert.icon:SetPoint("CENTER", alert.iconFrame, "CENTER")

    alert.iconBorder = alert.iconFrame:CreateTexture(nil, "OVERLAY")
    alert.iconBorder:SetAtlas("ui-achievement-iconframe", true)
    alert.iconBorder:SetPoint("CENTER", alert.iconFrame, "CENTER", -1, 2)

    -- Place all text against the actual, centered parchment instead of the uncropped image.
    alert.unlocked = alert:CreateFontString(nil, "OVERLAY", "GameFontBlackTiny")
    alert.unlocked:SetSize(200, 12)
    alert.unlocked:SetPoint("TOP", alert, "TOP", ALERT_TEXT_CENTER_X, -ALERT_TEXT_TOP)
    alert.unlocked:SetJustifyH("CENTER")
    alert.unlocked:SetText("Achievement Earned!")

    alert.name = alert:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    alert.name:SetSize(ALERT_TEXT_WIDTH, ALERT_NAME_HEIGHT)
    alert.name:SetPoint("TOP", alert.unlocked, "BOTTOM")
    alert.name:SetJustifyH("CENTER")
    alert.name:SetJustifyV("MIDDLE")

    -- Keep ForeverFit's explicit Fitness Point message below the achievement name.
    -- alert.points = alert:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    -- alert.points:SetSize(ALERT_TEXT_WIDTH, 12)
    -- alert.points:SetPoint("TOP", alert.name, "BOTTOM", 0, 0)
    -- alert.points:SetJustifyH("CENTER")

    -- Blizzard's built-in achievement shield displays points at the banner's right edge.
    alert.shield = CreateFrame("Frame", nil, alert)
    alert.shield:SetSize(64, 64)
    alert.shield:SetPoint("TOPRIGHT", alert, "TOPRIGHT", -8, -15)

    alert.shieldIcon = alert.shield:CreateTexture(nil, "BACKGROUND")
    alert.shieldIcon:SetAtlas("ui-achievement-shield-1", true)
    alert.shieldIcon:SetPoint("TOPRIGHT", alert.shield, "TOPRIGHT", 1, -6)

    alert.shieldPoints = alert.shield:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    alert.shieldPoints:SetPoint("CENTER", alert.shield, "CENTER", 1, -4)

    alert:SetScript("OnUpdate", function(frame, elapsed)
        frame.elapsed = frame.elapsed + elapsed
        if frame.elapsed >= ALERT_DURATION then
            frame:Hide()
            FF:ShowNextAchievementAlert()
        elseif frame.elapsed < ALERT_FADE_IN then
            frame:SetAlpha(frame.elapsed / ALERT_FADE_IN)
        elseif frame.elapsed > ALERT_DURATION - ALERT_FADE_OUT then
            frame:SetAlpha((ALERT_DURATION - frame.elapsed) / ALERT_FADE_OUT)
        else
            frame:SetAlpha(1)
        end
    end)
    self.achievementAlertFrame = alert
end

-- Displays one queued achievement and starts the existing alert timing and optional sound.
function FF:ShowNextAchievementAlert()
    local nextAchievement = table.remove(self.achievementAlertQueue, 1)
    if not nextAchievement then return end
    self:BuildAchievementAlert()

    local alert = self.achievementAlertFrame
    local points = nextAchievement.points or 1
    alert.icon:SetTexture(self:ResolveIcon(nextAchievement.icon))
    alert.name:SetText(nextAchievement.name)
    alert.achievementID = nextAchievement.id
    -- alert.points:SetText("+" .. points .. " Fitness Point" .. (points == 1 and "" or "s"))
    alert.shieldPoints:SetText(points)
    alert.elapsed = 0
    alert:SetAlpha(0)
    alert:Show()
    if self.db and self.db.soundEnabled then
        PlaySound(ACHIEVEMENT_EARNED_SOUND, "SFX")
    end
end

-- Adds an earned achievement to the FIFO alert queue without modifying its progress.
function FF:QueueAchievementAlert(achievement)
    if not achievement then return end
    self.achievementAlertQueue[#self.achievementAlertQueue + 1] = {
        id = achievement.id,
        name = achievement.name,
        icon = achievement.icon,
        points = achievement.points or 1,
    }
    if not self.achievementAlertFrame or not self.achievementAlertFrame:IsShown() then
        self:ShowNextAchievementAlert()
    end
end
