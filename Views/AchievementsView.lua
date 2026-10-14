local _, FF = ...

-- Resolve Blizzard icon paths to client file IDs, with a visible fallback.
-- Missing assets return temporary/nonpositive IDs on Forever.
function FF:ResolveIcon(path)
    if type(path) == "number" and path > 0 then return path end
    local id = type(path) == "string" and GetFileIDFromPath(path) or nil
    return (id and id > 0) and id or 134400 -- INV_Misc_QuestionMark
end

-- Present addon achievements through WoW's native clickable-link tooltip.
-- The receiver cannot know another player's exact unlock date from guild text.
function FF:ShowAchievementTooltip(id, sender)
    local achievement = self:GetAchievementByID(id)
    if not achievement then return end
    local player = UnitName("player")
    local character = sender and sender:match("^[^-]+") or player
    local isOwn = character == player
    local timestamp = isOwn and self.accountStats.achievementDates[id] or nil
    ShowUIPanel(ItemRefTooltip)
    if not ItemRefTooltip:IsShown() then
        ItemRefTooltip:SetOwner(UIParent, "ANCHOR_PRESERVE")
    end
    ItemRefTooltip:SetPadding(0, 0)
    ItemRefTooltip:ClearLines()
    ItemRefTooltip:AddLine(achievement.name, 1, 1, 1)
    ItemRefTooltip:AddLine(" ")
    if timestamp then
        ItemRefTooltip:AddLine(string.format("Achievement earned by %s on %s",
            character, date("%m/%d/%y", timestamp)), 0, 1, 0)
    else
        ItemRefTooltip:AddLine("Achievement earned by " .. character, 0, 1, 0)
        ItemRefTooltip:AddLine("Earned date unavailable", 0.6, 0.6, 0.6)
    end
    ItemRefTooltip:AddLine(" ")
    ItemRefTooltip:AddLine(achievement.description, 1, 1, 1, true)
    ItemRefTooltip:AddLine(" ")
    ItemRefTooltip:AddLine(achievement.name, 0, 1, 0)
    ItemRefTooltip:Show()
    if ItemRefTooltipTextLeft1 and ItemRefTooltip.CloseButton and
        ItemRefTooltipTextLeft1:GetRight() and ItemRefTooltip.CloseButton:GetLeft() and
        ItemRefTooltipTextLeft1:GetRight() > ItemRefTooltip.CloseButton:GetLeft() then
        ItemRefTooltip:SetPadding(16, 0)
    end
end

function FF:RefreshFitnessPoints()
    local frame = self.achievementsFrame
    if not frame then return end
    local earned, possible = 0, #self.baseExercises * #self.achievementTiers
    for _, exercise in ipairs(self.baseExercises) do
        local completed = self.accountStats.lifetime[exercise.id] or 0
        for _, tier in ipairs(self.achievementTiers) do
            if completed >= tier.target then earned = earned + 1 end
        end
    end
    for _, collection in ipairs({ self.generalAchievements, self.milestoneAchievements }) do
        for _, achievement in ipairs(collection) do
            possible = possible + achievement.points
            if self:GetAchievementProgress(achievement) >= achievement.target then
                earned = earned + achievement.points
            end
        end
    end
    if self.accountStats.cheater then earned = -999 end
    frame.fitnessSummary.bar:SetMinMaxValues(0, possible)
    frame.fitnessSummary.bar:SetValue(math.max(0, earned))
    frame.fitnessSummary.bar.Text:SetText(string.format("Fitness Points %d / %d", earned, possible))
    frame.fitnessSummary.shield.Points:SetText(earned)
end

local groups = { "General", "Beginner", "Intermediate", "Expert", "Godly", "No Equipment", "Free Weights", "Walking Pad", "Other" }
local directGroups = { General = true, Beginner = true, Intermediate = true, Expert = true, Godly = true, Other = true }

local function Text(parent, font, point, relative, x, y)
    local text = parent:CreateFontString(nil, "OVERLAY", font)
    text:SetPoint(point, parent, relative, x, y)
    return text
end

local function BuildCard(card)
    if card.built then return end
    card.built = true
    card:SetWidth(516)
    card.background = card:CreateTexture(nil, "BACKGROUND")
    card.background:SetAllPoints()
    card.backgroundMiddle = card:CreateTexture(nil, "BACKGROUND", nil, -1)
    card.backgroundMiddle:SetPoint("TOPLEFT", 0, -10)
    card.backgroundMiddle:SetPoint("BOTTOMRIGHT", 0, 10)
    card.backgroundTop = card:CreateTexture(nil, "BACKGROUND")
    card.backgroundTop:SetPoint("TOPLEFT")
    card.backgroundTop:SetPoint("TOPRIGHT")
    card.backgroundBottom = card:CreateTexture(nil, "BACKGROUND")
    card.backgroundBottom:SetPoint("BOTTOMLEFT")
    card.backgroundBottom:SetPoint("BOTTOMRIGHT")
    card.selected = card:CreateTexture(nil, "BORDER")
    card.selected:SetAllPoints()
    card.selected:SetAtlas("Legacy-Challenge-Cards-selected")
    card.ribbon = card:CreateTexture(nil, "ARTWORK")
    card.ribbon:SetPoint("TOPLEFT", 5, -4)
    card.ribbon:SetPoint("TOPRIGHT", -80, -4)
    card.icon = CreateFrame("Frame", nil, card, "LegacyChallengeIconFrameTemplate")
    card.icon:SetPoint("TOPLEFT", 12, -18)
    card.name = Text(card, "GameFontHighlightLarge", "TOPLEFT", "TOPLEFT", 82, -21)
    card.plusMinus = card:CreateTexture(nil, "OVERLAY")
    card.plusMinus:SetSize(20, 20)
    card.plusMinus:SetPoint("TOPLEFT", 76, -49)
    card.description = card:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    card.description:SetPoint("TOPLEFT", card.ribbon, "BOTTOMLEFT", 95, -2)
    card.description:SetWidth(400)
    card.description:SetJustifyH("LEFT")
    card.shield = card:CreateTexture(nil, "OVERLAY")
    card.shield:SetAtlas("Legacy-Tree-Frame-Points-Icon", true)
    card.shield:SetScale(0.7)
    card.shield:SetPoint("TOPRIGHT", -14, -24)
    card.badgeNumber = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    card.badgeNumber:SetPoint("CENTER", card.shield, "CENTER", 0, -4)
    card.check = card:CreateTexture(nil, "OVERLAY")
    card.check:SetAtlas("worldquest-tracker-checkmark", true)
    card.check:SetScale(0.5)
    card.check:SetPoint("TOPRIGHT", -4, -4)
    card.earnedDate = card:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
    card.earnedDate:SetPoint("TOPRIGHT", card.check, "TOPLEFT", -4, -1)
    card.earnedDate:SetTextColor(1, 0.82, 0)
    -- Native counted-criteria row, shown only when the card is expanded.
    card.criteria = CreateFrame("Frame", nil, card, "LegacyChallengeCriteriaTemplate")
    card.criteria:SetPoint("BOTTOMLEFT", 20, 6)
    card.criteria:SetPoint("BOTTOMRIGHT", -20, 6)
    card.criteria:SetHeight(30)
    card.criteria.Background:Hide()
    card.criteria.Name:Hide()
    card.criteria.Check:Hide()
    card.criteria.ProgressBarBackground:Show()
    card.criteria.ProgressBar:Show()
    -- Native objectives begin 23 units below the description and use two 233-unit columns.
    card.objectivesFrame = CreateFrame("Frame", nil, card)
    card.objectivesFrame:SetPoint("TOP", card.description, "BOTTOM", 0, -23)
    card.objectivesFrame:SetPoint("LEFT", card, "LEFT")
    card.objectivesFrame:SetPoint("RIGHT", card, "RIGHT")
    card.objectives = {}
    local maxCriteria = 0
    for _, milestone in ipairs(FF.milestoneAchievements) do
        maxCriteria = math.max(maxCriteria, #(milestone.exerciseIDs or {}))
    end
    card.objectivesFrame:SetHeight(math.ceil(maxCriteria / 2) * 35 - 5)
    for i = 1, maxCriteria do
        local objective = CreateFrame("Frame", nil, card, "LegacyChallengeCriteriaTemplate")
        local col = (i - 1) % 2
        local row = math.floor((i - 1) / 2)
        objective:SetSize(233, 30)
        if col == 0 then
            objective:SetPoint("TOPLEFT", card.objectivesFrame, "TOPLEFT", 20, -35 * row)
        else
            objective:SetPoint("TOPRIGHT", card.objectivesFrame, "TOPRIGHT", -20, -35 * row)
        end
        objective.ProgressBarBackground:Hide()
        objective.ProgressBar:Hide()
        card.objectives[i] = objective
    end
end

-- Reuse Forever's own native ScrollBox, scroll bar, filter, and challenge atlases.
function FF:BuildAchievements(legacy)
    local frame = CreateFrame("Frame", "ForeverFitAchievementsFrame", legacy.ChallengesPage)
    frame:SetPoint("TOPLEFT", legacy.ChallengesPage, "TOPLEFT", 0, -80)
    frame:SetPoint("BOTTOMRIGHT", legacy.ChallengesPage, "BOTTOMRIGHT", 0, 8)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(550)
    frame:EnableMouse(true)
    -- Reuse the native ChallengesPage background in place. Drawing its atlas
    -- again from the sub-pane created a second horizontal trim near the top.
    local divider = frame:CreateTexture(nil, "ARTWORK")
    divider:SetPoint("TOPLEFT", legacy.ChallengesPage.VerticalDivider, "TOPLEFT")
    divider:SetPoint("BOTTOMRIGHT", legacy.ChallengesPage.VerticalDivider, "BOTTOMRIGHT")
    divider:SetAtlas("Legacy-Tree-Frame-divider-Vertical")

    -- Match LegacyChallengePointSummaryTemplate; completed challenge tiers earn points.
    local summary = CreateFrame("Frame", nil, legacy.ChallengesPage)
    summary:SetFrameStrata("DIALOG")
    summary:SetFrameLevel(551)
    summary:SetSize(520, 36)
    summary:SetPoint("TOPLEFT", legacy.ChallengesPage, "TOPLEFT", 280, -25)
    summary.background = summary:CreateTexture(nil, "ARTWORK")
    summary.background:SetAtlas("Legacy-Progressbar-BG")
    summary.background:SetHeight(16)
    summary.background:SetPoint("LEFT", -6, -3)
    summary.background:SetPoint("RIGHT", 0, -3)
    summary.bar = CreateFrame("StatusBar", nil, summary, "LegacyProgressBarTemplate")
    summary.bar:SetPoint("TOPLEFT", summary.background, "TOPLEFT")
    summary.bar:SetPoint("BOTTOMRIGHT", summary.background, "BOTTOMRIGHT", 0, 3)
    summary.bar:SetMinMaxValues(0, 1)
    summary.bar:SetValue(0)
    summary.bar.Text:SetText("Fitness Points")
    summary.shield = CreateFrame("Button", nil, summary, "LegacyPointShield")
    summary.shield:SetPoint("RIGHT", summary, "LEFT", 14, 4)
    summary.shield:SetFrameLevel(800)
    summary.shield.Points:SetText("0")
    frame.fitnessSummary = summary
    summary:Hide()

    frame.selectedExercise = self.exercises[1]
    frame.selectedTier = nil
    frame.selectedMilestone = nil
    frame.selectedGroup = nil
    frame.expandedGroups = { Beginner = false, Intermediate = false,
        Expert = false, Godly = false, ["No Equipment"] = true, ["Free Weights"] = false, ["Walking Pad"] = false }
    frame.tierFilter = "all"
    local _, descriptionHeight = SystemFont_Shadow_Med1:GetFont()
    frame.expandedHeight = 122 + 30 + descriptionHeight - ACHIEVEMENTBUTTON_DESCRIPTIONHEIGHT

    local nav = CreateFrame("Frame", nil, frame)
    nav:SetPoint("TOPLEFT", legacy.ChallengesPage.CategoryList, "TOPLEFT")
    nav:SetPoint("BOTTOMRIGHT", legacy.ChallengesPage.CategoryList, "BOTTOMRIGHT")
    local filter = CreateFrame("DropdownButton", nil, nav, "WowStyle1FilterDropdownTemplate")
    filter:SetPoint("TOPRIGHT", -8, -9)
    filter:SetupMenu(function(_, root)
        for _, item in ipairs({ { "All tiers", "all" }, { "Completed tiers", "completed" }, { "Incomplete tiers", "incomplete" } }) do
            root:CreateRadio(item[1], function() return frame.tierFilter == item[2] end, function()
                frame.tierFilter = item[2]
                FF:RefreshAchievements()
            end)
        end
    end)
    local search = CreateFrame("EditBox", nil, nav, "SearchBoxTemplate")
    search:SetAutoFocus(false)
    search:SetMaxLetters(40)
    search:SetHeight(20)
    search:SetPoint("TOPLEFT", 13, -8)
    search:SetPoint("RIGHT", filter, "LEFT", -4, 0)
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    search:HookScript("OnTextChanged", function() FF:RefreshAchievementNavigation() end)
    frame.search = search

    local list = CreateFrame("Frame", nil, nav, "WowScrollBoxList")
    list:SetPoint("TOPLEFT", 8, -35)
    list:SetPoint("BOTTOMRIGHT", -20, 5)
    local listBar = CreateFrame("EventFrame", nil, nav, "MinimalScrollBar")
    listBar:SetPoint("TOPLEFT", list, "TOPRIGHT")
    listBar:SetPoint("BOTTOMLEFT", list, "BOTTOMRIGHT")
    local listView = CreateScrollBoxListLinearView(5, 5, 0, 5, 1)
    listView:SetElementExtent(25)
    listView:SetElementFactory(function(factory, row)
        if row.isGroup then
            factory("ListHeaderVisualTemplate", function(button, data)
                local direct = directGroups[data.name]
                local selected = direct and frame.selectedGroup == data.name
                button:SetHeaderText(data.name)
                button:GetCollapseButton():SetShown(not direct)
                if not direct then
                    button:GetCollapseButton():UpdateCollapsedState(not frame.expandedGroups[data.name])
                end
                local color = (selected or not direct and frame.expandedGroups[data.name])
                    and WHITE_FONT_COLOR or NORMAL_FONT_COLOR
                button:SetTitleColor(false, color)
                button:SetTitleColor(true, color)
                local atlas = direct and (selected and "Legacy-Challenge-Left-Sub-Tab-selected"
                    or "Legacy-Challenge-Left-Sub-Tab") or "common-button-list-collapseExpand"
                button:GetNormalTexture():SetAtlas(atlas, true)
                button:GetHighlightTexture():SetAtlas(direct and "Legacy-Challenge-Left-Sub-Tab-selected"
                    or "common-button-list-collapseExpand", true)
                button:SetScript("OnClick", function()
                    if direct then
                        frame.selectedGroup = data.name
                        frame.selectedExercise = nil
                        frame.selectedMilestone = nil
                        frame.selectedTier = nil
                        FF:RefreshAchievements()
                    else
                        frame.expandedGroups[data.name] = not frame.expandedGroups[data.name]
                        FF:RefreshAchievementNavigation()
                    end
                end)
            end)
        else
            factory("Button", function(button, data)
                if not button.art then
                    button.art = button:CreateTexture(nil, "BACKGROUND")
                    button.art:SetPoint("TOPLEFT", 10, 0)
                    button.art:SetPoint("BOTTOMRIGHT")
                    button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalMed3")
                    button.label:SetPoint("LEFT", 19, 0)
                    button.label:SetPoint("RIGHT", -6, 0)
                    button.label:SetJustifyH("LEFT")
                end
                button:SetHeight(25)
                local selected = data.exercise and data.exercise == frame.selectedExercise
                button.art:SetAtlas(selected and "Legacy-Challenge-Left-Sub-Tab-selected" or "Legacy-Challenge-Left-Sub-Tab")
                local label = data.exercise
                button.label:SetText(label.name)
                local color = selected and WHITE_FONT_COLOR or NORMAL_FONT_COLOR
                button.label:SetTextColor(color:GetRGBA())
                button:SetScript("OnClick", function()
                    frame.selectedExercise = data.exercise
                    frame.selectedMilestone = nil
                    frame.selectedGroup = nil
                    frame.selectedTier = nil
                    FF:RefreshAchievements()
                end)
                button:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    local entry = data.exercise
                    GameTooltip:AddLine(entry.name, 1, 0.82, 0.2)
                    GameTooltip:AddLine(entry.instructions or entry.description, 1, 1, 1, true)
                    GameTooltip:Show()
                end)
                button:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end)
        end
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(list, listBar, listView)
    frame.list = list

    local pane = CreateFrame("Frame", nil, frame)
    pane:SetPoint("TOPLEFT", legacy.ChallengesPage.DetailPane, "TOPLEFT")
    pane:SetPoint("BOTTOMRIGHT", legacy.ChallengesPage.DetailPane, "BOTTOMRIGHT")
    local detail = CreateFrame("Frame", nil, pane, "WowScrollBoxList")
    detail:SetPoint("TOPLEFT", 4, -3)
    detail:SetPoint("BOTTOMRIGHT", 0, 5)
    detail:SetEdgeFadeLength(30)
    local detailBar = CreateFrame("EventFrame", nil, pane, "MinimalScrollBar")
    detailBar:SetPoint("TOPLEFT", pane, "TOPRIGHT", 6, -8)
    detailBar:SetPoint("BOTTOMLEFT", pane, "BOTTOMRIGHT", 6, 6)
    local detailView = CreateScrollBoxListLinearView()
    detailView:SetPadding(2, 0, 0, 4, 5)
    detailView:SetElementExtentCalculator(function(_, data)
        if data.index ~= frame.selectedTier then return 122 end
        if data.achievement.kind == "milestone" then
            local rows = math.ceil(#data.achievement.exerciseIDs / 2)
            return frame.expandedHeight - 30 + rows * 30 + (rows - 1) * 5
        end
        return frame.expandedHeight
    end)
    detailView:SetElementInitializer("Button", function(card, data)
        BuildCard(card)
        if data.index == frame.selectedTier and data.achievement.kind == "milestone" then
            local rows = math.ceil(#data.achievement.exerciseIDs / 2)
            card:SetHeight(frame.expandedHeight - 30 + rows * 30 + (rows - 1) * 5)
        else
            card:SetHeight(data.index == frame.selectedTier and frame.expandedHeight or 122)
        end
        FF:ConfigureAchievementCard(card, data.achievement, data.index)
        card:SetScript("OnClick", function()
            if frame.selectedTier == data.index then
                frame.selectedTier = nil
            else
                frame.selectedTier = data.index
            end
            FF:RefreshAchievements()
        end)
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(detail, detailBar, detailView)
    frame.detail = detail
    frame.detailView = detailView
    frame:Hide()
    self.achievementsFrame = frame
    self:RefreshAchievements()
end

function FF:RefreshAchievementNavigation()
    local frame = self.achievementsFrame
    if not frame then return end
    local filter = frame.search:GetText():lower()
    local provider = CreateDataProvider()
    for _, groupName in ipairs(groups) do
        local matches = {}
        if groupName == "General" then
            for _, achievement in ipairs(self.generalAchievements) do
                if (not achievement.hidden or self:GetAchievementProgress(achievement) >= achievement.target)
                    and (filter == "" or achievement.name:lower():find(filter, 1, true)) then
                    matches[#matches + 1] = { general = achievement }
                end
            end
        elseif directGroups[groupName] then
            for _, achievement in ipairs(self.milestoneAchievements) do
                if (achievement.group == groupName or (groupName == "Other" and achievement.kind == "other")) and (filter == "" or achievement.name:lower():find(filter, 1, true)) then
                    matches[#matches + 1] = { milestone = achievement }
                end
            end
        else
            for _, exercise in ipairs(self.exercises) do
                if not exercise.custom and exercise.group == groupName
                    and (filter == "" or exercise.name:lower():find(filter, 1, true)) then
                    matches[#matches + 1] = { exercise = exercise }
                end
            end
        end
        if filter == "" or #matches > 0 or groupName:lower():find(filter, 1, true) then
            provider:Insert({ isGroup = true, name = groupName })
            if not directGroups[groupName] and (frame.expandedGroups[groupName] or filter ~= "") then
                for _, entry in ipairs(matches) do
                    provider:Insert(entry)
                end
            end
        end
    end
    frame.list:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)
end

function FF:ConfigureAchievementCard(card, achievement, i)
    local frame = self.achievementsFrame
    local count = self:GetAchievementProgress(achievement)
    local reached = count >= achievement.target
    local expanded = i == frame.selectedTier
    local variant = reached and "" or "-Disable"
    card.background:SetAtlas(reached and "Legacy-Challenge-Cards" or "Legacy-Challenge-Cards-Disable")
    card.background:SetShown(not expanded)
    card.backgroundTop:SetAtlas("Legacy-Challenge-Cards-tiled-top" .. variant, true)
    card.backgroundMiddle:SetAtlas("Legacy-Challenge-Cards-tiled-vertical" .. variant)
    card.backgroundMiddle:SetVertTile(true)
    card.backgroundBottom:SetAtlas("Legacy-Challenge-Cards-tiled-bottom" .. variant, true)
    card.backgroundTop:SetShown(expanded)
    card.backgroundMiddle:SetShown(expanded)
    card.backgroundBottom:SetShown(expanded)
    card.selected:SetShown(expanded)
    card.ribbon:SetAtlas(reached and "Legacy-Challenge-Cards-Ribbon-Brown" or "Legacy-Challenge-Cards-Ribbon-Brown-Disable", true)
    card.icon.texture:SetTexture(self:ResolveIcon(achievement.icon))
    card.icon.texture:SetDesaturated(not reached)
    card.name:SetText(achievement.name)
    local textColor = (reached or expanded) and WHITE_FONT_COLOR or GRAY_FONT_COLOR
    card.name:SetTextColor(textColor:GetRGBA())
    card.plusMinus:SetAtlas(expanded and "128-redbutton-minus" or "128-redbutton-plus")
    card.description:SetText(achievement.description)
    card.description:SetTextColor(textColor:GetRGBA())
    card.shield:SetDesaturated(not reached)
    card.badgeNumber:SetText(achievement.points)
    card.check:SetShown(reached)
    local timestamp = reached and self.accountStats.achievementDates[achievement.id]
    card.earnedDate:SetText(timestamp and date("%m/%d/%y", timestamp) or "")
    local isMilestone = achievement.kind == "milestone"
    card.criteria:SetShown(expanded and not isMilestone)
    card.objectivesFrame:SetShown(expanded and isMilestone)
    if isMilestone then
        local rows = math.ceil(#achievement.exerciseIDs / 2)
        card.objectivesFrame:SetHeight(rows * 30 + (rows - 1) * 5)
    end
    for n, objective in ipairs(card.objectives) do
        local id = isMilestone and achievement.exerciseIDs[n] or nil
        objective:SetShown(expanded and isMilestone and id ~= nil)
        if id then
            local prerequisite = self:GetAchievementByID(id .. ":" .. achievement.rank)
            local passed = prerequisite and self:GetAchievementProgress(prerequisite) >= prerequisite.target
            objective.Name:SetText(prerequisite and prerequisite.name or id)
            objective.Name:SetTextColor((passed and WHITE_FONT_COLOR or GRAY_FONT_COLOR):GetRGBA())
            objective.Check:SetShown(not not passed)
        end
    end
    card.criteria.ProgressBar:SetMinMaxValues(0, achievement.target)
    card.criteria.ProgressBar:SetValue(math.min(count, achievement.target))
    card.criteria.ProgressBar.Text:SetText(string.format("%d / %d", math.min(count, achievement.target), achievement.target))
end

function FF:RefreshAchievements()
    local frame = self.achievementsFrame
    if not frame or not self.stats then return end
    local provider = CreateDataProvider()
    if frame.selectedGroup == "General" then
        local index = 0
        for _, achievement in ipairs(self.generalAchievements) do
            if not achievement.hidden or self:GetAchievementProgress(achievement) >= achievement.target then
                index = index + 1
                local reached = self:GetAchievementProgress(achievement) >= achievement.target
                if frame.tierFilter == "all" or reached == (frame.tierFilter == "completed") then
                    provider:Insert({ index = index, achievement = achievement })
                end
            end
        end
    elseif frame.selectedGroup then
        local index = 0
        for _, achievement in ipairs(self.milestoneAchievements) do
            if achievement.group == frame.selectedGroup or (frame.selectedGroup == "Other" and achievement.kind == "other") then
                index = index + 1
                local reached = self:GetAchievementProgress(achievement) >= achievement.target
                if frame.tierFilter == "all" or reached == (frame.tierFilter == "completed") then
                    provider:Insert({ index = index, achievement = achievement })
                end
            end
        end
    elseif frame.selectedExercise and not frame.selectedExercise.custom then
        local count = self.accountStats.lifetime[frame.selectedExercise.id] or 0
        for i, tier in ipairs(self.achievementTiers) do
            if frame.tierFilter == "all" or (count >= tier.target) == (frame.tierFilter == "completed") then
                provider:Insert({ index = i, achievement = self:GetExerciseAchievement(frame.selectedExercise, i) })
            end
        end
    end
    frame.detail:SetDataProvider(provider, ScrollBoxConstants.RetainScrollPosition)
    self:RefreshFitnessPoints()
    self:RefreshAchievementNavigation()
end

function FF:OpenAchievement(id)
    local achievement = self:GetAchievementByID(id)
    if not achievement then return end
    if achievement.kind == "milestone" or achievement.kind == "other" then
        self.pendingAchievement = { milestone = achievement }
    elseif achievement.kind == "exercise" then
        for _, exercise in ipairs(self.exercises) do
            if exercise.id == achievement.exerciseID then
                self.pendingAchievement = { exercise = exercise, tier = achievement.index }
                break
            end
        end
    else
        self.pendingAchievement = { general = achievement }
    end
    self:ToggleAchievementDetails()
end

function FF:ToggleAchievementDetails()
    self.openAchievementsWhenReady = true
    if self:TryAttachLegacyButton() and self.legacyHost:IsVisible() then
        self:ShowAchievements()
    elseif type(ToggleLegacySystemUI) == "function" then
        ToggleLegacySystemUI()
        C_Timer.After(0.1, function() FF:TryAttachLegacyButton() end)
    end
end

-- The native category/detail controls must not remain active under the overlay.
-- Restore them exactly when leaving Forever Fit or opening another Legacy tab.
function FF:HideAchievements()
    if self.achievementsFrame then
        self.achievementsFrame:Hide()
        self.achievementsFrame.fitnessSummary:Hide()
    end
    if self.legacyHost and self.legacyHost.ChallengesPage then
        local page = self.legacyHost.ChallengesPage
        page.CategoryList:Show()
        page.DetailPane:Show()
        page.VerticalDivider:Show()
        page.LegacyChallengePointSummary:Show()
        if self.legacyHost.currentPage == 2 then
            self.legacyHost:SetTitle(LEGACY_CHALLENGE_FRAME_TITLE)
        end
    end
    if self.legacyButton then self.legacyButton:SetChecked(false) end
    self.openAchievementsWhenReady = false
end

function FF:ShowAchievements()
    local frame = self.achievementsFrame
    if not frame then return false end
    if self.legacyHost.currentPage ~= 2 then
        EventRegistry:TriggerEvent("Legacy.SelectPage", 2)
    end
    local page = self.legacyHost.ChallengesPage
    if self.pendingAchievement then
        frame.selectedExercise = self.pendingAchievement.exercise
        frame.selectedMilestone = nil
        frame.selectedGroup = self.pendingAchievement.general and "General"
            or self.pendingAchievement.milestone and self.pendingAchievement.milestone.group or nil
        frame.selectedTier = self.pendingAchievement.tier
        if self.pendingAchievement.general then
            local index = 0
            for _, achievement in ipairs(self.generalAchievements) do
                if not achievement.hidden or self:GetAchievementProgress(achievement) >= achievement.target then
                    index = index + 1
                    if achievement.id == self.pendingAchievement.general.id then
                        frame.selectedTier = index
                        break
                    end
                end
            end
        elseif self.pendingAchievement.milestone then
            local index = 0
            for _, achievement in ipairs(self.milestoneAchievements) do
                if achievement.group == frame.selectedGroup then
                    index = index + 1
                    if achievement.id == self.pendingAchievement.milestone.id then
                        frame.selectedTier = index
                        break
                    end
                end
            end
        end
        self.pendingAchievement = nil
        if frame.selectedExercise then
            frame.expandedGroups[frame.selectedExercise.group] = true
        end
        frame.search:SetText("")
    end
    page.CategoryList:Hide()
    page.DetailPane:Hide()
    page.VerticalDivider:Hide()
    page.LegacyChallengePointSummary:Hide()
    self.legacyHost:SetTitle("Fitness Challenges")
    self:RefreshAchievements()
    frame:Show()
    frame.fitnessSummary:Show()
    self.legacyButton:SetChecked(true)
    self.openAchievementsWhenReady = false
    return true
end

-- Settings always opens the embedded Fitness Challenges page, never toggles it closed.
function FF:OpenFitChallenges()
    self.openAchievementsWhenReady = true
    if self:TryAttachLegacyButton() and self.legacyHost:IsVisible() then
        self:ShowAchievements()
        return
    end
    local legacy = _G.LegacySystemFrame
    if type(ToggleLegacySystemUI) == "function" and (not legacy or not legacy:IsShown()) then
        ToggleLegacySystemUI()
    end
    C_Timer.After(0.1, function()
        if FF:TryAttachLegacyButton() and FF.legacyHost:IsVisible() then
            FF:ShowAchievements()
        else
            FF.Print("Could not open Fitness Challenges. Please open Legacy Challenges and click the Forever Challenges tab.")
        end
    end)
end

function FF:ToggleAchievements()
    if self.achievementsFrame and self.achievementsFrame:IsVisible() then
        self:HideAchievements()
        return
    end
    self.openAchievementsWhenReady = true
    if self:TryAttachLegacyButton() and self.legacyHost:IsVisible() then
        self:ShowAchievements()
        return
    end
    if type(ToggleLegacySystemUI) == "function" then
        ToggleLegacySystemUI()
        C_Timer.After(0.1, function() FF:TryAttachLegacyButton() end)
    else
        self.Print("Open Legacy Challenges, then click the Forever Challenges tab on the right.")
    end
end

local function VisibleLegacyFrame()
    local legacy = _G.LegacySystemFrame
    if legacy and legacy:IsShown() and legacy.ChallengesPage then
        return legacy
    end
end

function FF:TryAttachLegacyButton()
    if self.legacyButton then
        if self.openAchievementsWhenReady and self.legacyHost:IsVisible() then
            self:ShowAchievements()
        end
        return true
    end
    if InCombatLockdown() then return false end
    local legacy = VisibleLegacyFrame()
    if not legacy then return false end
    self.legacyHost = legacy
    self:BuildAchievements(legacy)
    -- The exact side-tab template, rather than a resized UIPanelButton.
    local button = CreateFrame("Frame", "ForeverFitLegacyButton", legacy, "LegacySystemTabTemplate")
    button:SetPoint("TOPLEFT", legacy.LegacyTreeTab, "BOTTOMLEFT", 0, -2)
    button:SetFrameLevel(legacy:GetFrameLevel() + 30)
    button.iconTexture = "Interface\\Icons\\Ability_Warrior_StrengthOfArms"
    button.Icon:SetTexture(button.iconTexture)
    button.tooltipText = "Forever Challenges"
    button:SetCustomOnMouseUpHandler(function(_, mouseButton, upInside)
        if mouseButton == "LeftButton" and upInside then FF:ToggleAchievements() end
    end)
    button:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine("Forever Challenges", 1, 0.82, 0.2)
        GameTooltip:Show()
    end)
    button:HookScript("OnLeave", function() GameTooltip:Hide() end)
    legacy:HookScript("OnHide", function() FF:HideAchievements() end)
    -- Native tabs use Legacy.SelectPage from their mouse-up handler, not OnClick.
    EventRegistry:RegisterCallback("Legacy.SelectPage", function() FF:HideAchievements() end, self)
    self.legacyButton = button
    if self.legacyWatcher then
        self.legacyWatcher:Cancel()
        self.legacyWatcher = nil
    end
    if self.openAchievementsWhenReady then self:ShowAchievements() end
    return true
end

function FF:StartLegacyButtonWatcher()
    if self:TryAttachLegacyButton() then return end
    if not self.legacyWatcher then
        self.legacyWatcher = C_Timer.NewTicker(2, function() FF:TryAttachLegacyButton() end)
    end
end
