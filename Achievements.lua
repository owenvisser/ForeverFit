local _, FF = ...

-- Completed sessions per exercise; the native Legacy system remains unaffected.
FF.achievementTiers = {
    { name = "Bronze", target = 1, color = { 0.76, 0.47, 0.24 } },
    { name = "Silver", target = 10, color = { 0.72, 0.76, 0.81 } },
    { name = "Gold", target = 50, color = { 0.98, 0.77, 0.20 } },
    { name = "Platinum", target = 250, color = { 0.35, 0.85, 0.80 } },
    { name = "Diamond", target = 1000, color = { 0.55, 0.70, 1.0 } },
}

-- Five progressively more ridiculous titles per exercise.
FF.achievementNames = {
    pushups = { "Northshire Push-up Recruit", "Scarlet Monastery Press Corps", "Arms Like Anduin", "Mogging Thrall", "The Push-up Lich King" },
    wallpushups = { "Goldshire Wall Leaner", "Stormwind Wall Inspector", "Keeper of Hellfire Ramparts", "Blackrock Wall Brawler", "The Great Wall of Gilneas" },
    squats = { "Dun Morogh Squat Recruit", "Dwarven Leg Day", "Thunder Bluff Thunder Thighs", "Sargeras Skips Leg Day", "Titanforged Quads" },
    lunges = { "Lordaeron Lunge Recruit", "A Peon's First Step", "The Stride of Stratholme", "Lunging Through the Dark Portal", "Illidan's Unprepared Leg Day" },
    calfraises = { "Elwynn Tiptoe Apprentice", "Gadgetzan Calf Cartel", "Mount Hyjal High Heels", "Calves of the Old Gods", "Archimonde's Ankle Day" },
    jumpingjacks = { "Dun Morogh Jumping Recruit", "Gnomeregan Jump Jet", "Murloc Evasion Maneuver", "Leaper of the Dark Portal", "Jacked by the Light" },
    plank = { "Stormwind Floor Sentinel", "Darnassus Bridge Plank", "Shield Wall of Ironforge", "The Unmoving Blackrock", "The Plank King of Northrend" },
    curls = { "Goldshire Curl Initiate", "Biceps for the Horde", "Gains of Ironforge", "Thrall's Training Partner", "Swole of the Titans" },
    press = { "Stormwind Shoulder Squire", "Gryphon Rider Press", "Karazhan Overhead Overlord", "Pressing Sulfuras Skyward", "The Shoulders of Sargeras" },
    rows = { "Booty Bay Rowboat Rookie", "Pulling Aggro in Ragefire", "Oar Master of Booty Bay", "Tug-of-War with Deathwing", "Row, Row, Row Your Raid" },
    gobletsquats = { "Gadgetzan Goblet Goblin", "Squat and Loot in the Deadmines", "Ironforge Tavern's Strongest Legs", "The Goblet of the Old Gods", "The Squatfather of Stormwind" },
    laterals = { "Darnassus Little Wings", "Flight Form Apprentice", "Delts of the Argent Dawn", "Wings of the Val'kyr", "Shoulders of the Pantheon" },
    deadlifts = { "Elwynn Loot Lifter", "Ironforge Inventory Overweight", "Blackrock Epic Loot Hauler", "Azeroth's Moving Company", "Lifting the Dark Portal" },
    easywalk = { "First Steps in Elwynn", "Goldshire Stroller", "Road to Redridge", "Stormwind Footman of the Year", "The Eternal Wanderer of Azeroth" },
    briskwalk = { "Brisk Stormwind Recruit", "Outrunning a Murloc", "Boots of Minor Speed", "Strider of Stranglethorn", "Faster Than Your Hearthstone" },
    inclineeasy = { "Dun Morogh Hillwalker", "Climbing the Wetlands Pass", "Footman of Alterac", "Trailblazer of Mount Hyjal", "Summiting Icecrown on Foot" },
    inclinebrisk = { "Brisk Dun Morogh Climber", "Hustling up Thunder Bluff", "Race to Blackrock Spire", "Sprint to the Peaks of Hyjal", "Outrunning the Storm Peaks" },
    shrugs = { "Ironforge Trap Recruit", "Shoulders up for the King", "Traps of Blackrock", "Shrugging Off Deathwing", "The Titanforged Trapezius" },
    triceps = { "Silvermoon Triceps Initiate", "Triceps of the Scarlet Crusade", "Triceps for the Argent Tournament", "Elbows of the Naaru", "The Lich King's Overhead Lockout" },
}

-- General achievements include cumulative prescribed walking minutes and zero-point shame tiers.
FF.generalAchievements = {
    { id = "firstfit", name = "Quest Accepted: Leg Day", kind = "total", target = 1, points = 1,
      description = "Complete your first Forever Fit session.", icon = "Interface\\Icons\\Achievement_Quests_Completed_01" },
    { id = "fit100", name = "The Barrens Grind Is Real", kind = "total", target = 100, points = 1,
      description = "Complete 100 workouts.", icon = "Interface\\Icons\\Achievement_Quests_Completed_06" },
    { id = "fit1000", name = "No Rest XP", kind = "total", target = 1000, points = 1,
      description = "Complete 1,000 workouts.", icon = "Interface\\Icons\\Spell_Holy_Renew" },
    { id = "walk60", name = "Goldshire Is That Way", kind = "walking", target = 60, points = 1,
      description = "Complete 60 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
    { id = "walk600", name = "Walked the Barrens", kind = "walking", target = 600, points = 1,
      description = "Complete 600 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\INV_Boots_05" },
    { id = "walk6000", name = "The Long Walk to Silithus", kind = "walking", target = 6000, points = 1,
      description = "Complete 6,000 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\Ability_Rogue_Sprint" },
    { id = "skip5", name = "AFK in Orgrimmar", kind = "skipped", target = 5, points = 0,
      description = "Skip 5 workouts. The innkeeper is impressed.", icon = "Interface\\Icons\\INV_Misc_PocketWatch_01" },
    { id = "skip50", name = "Professional Stormwind Benchwarmer", kind = "skipped", target = 50, points = 0,
      description = "Skip 50 workouts. You have mastered the art of sitting.", icon = "Interface\\Icons\\INV_Misc_PocketWatch_02" },
    { id = "skip500", name = "Illidan Was Not Prepared for Leg Day", kind = "skipped", target = 500, points = 0,
      description = "Skip 500 workouts. A truly questionable feat of strength.", icon = "Interface\\Icons\\Ability_Rogue_FeignDeath" },
    { id = "inventor", name = "Gnomeregan Patent Pending", kind = "inventor", target = 1, points = 1, hidden = true,
      description = "Invent your first custom workout. The patent office has some questions.",
      icon = "Interface\\Icons\\INV_Gizmo_02" },
    { id = "cheater11", name = "The Forever Fit Cheater", kind = "cheater", target = 1, points = 0, hidden = true,
      description = "Even the Bronze Dragonflight doubts your rep speed!",
      icon = "Interface\\Icons\\Ability_Rogue_Sprint" },
}

-- Progression challenges count distinct exercise achievements within each track.
-- Any four bodyweight or free-weight exercises, or any two walking-pad exercises,
-- can satisfy a tier; the enabled-checkbox settings never alter achievement rules.
local milestoneTracks = {
    { group = "No Equipment", target = 4, icon = "Interface\\Icons\\Ability_Warrior_Charge" },
    { group = "Free Weights", target = 4, icon = "Interface\\Icons\\Ability_Warrior_StrengthOfArms" },
    { group = "Walking Pad", target = 2, icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
}
FF.milestoneAchievements = {}
local otherNames = {
    "Goblin-Made Training Wheels", "Ogre-Approved Gym Routine",
    "Gnomeregan's Unlicensed Gym", "Bilgewater's Questionable Masterpiece",
}
for rank, entry in ipairs({
    { group = "Beginner", required = 1, names = {
        "Beginner Body Fitness", "Initiate Lifter", "The Road to Goldshire" } },
    { group = "Intermediate", required = 10, names = {
        "Stormwind Training Veteran", "Ironforge Iron-Pumper", "The Long Road Through Westfall" } },
    { group = "Expert", required = 50, names = {
        "Champion of the Argent Gym", "Swole of the Titans", "The Wanderer of Azeroth" } },
    { group = "Godly", required = 250, names = {
        "Might of the Titans", "Forged in Blackrock Mountain", "Walking with the Old Gods" } },
}) do
    FF.milestoneAchievements[#FF.milestoneAchievements + 1] = {
        id = "other:" .. rank, name = otherNames[rank], group = entry.group,
        kind = "other", target = entry.required, points = 1,
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        description = "Complete " .. entry.required .. " custom workouts in the Other category.",
    }
    for track, spec in ipairs(milestoneTracks) do
        local exerciseIDs = {}
        for _, exercise in ipairs(FF.exercises) do
            if exercise.group == spec.group then
                exerciseIDs[#exerciseIDs + 1] = exercise.id
            end
        end
        FF.milestoneAchievements[#FF.milestoneAchievements + 1] = {
            id = "milestone:" .. rank .. ":" .. track, name = entry.names[track],
            group = entry.group, kind = "milestone", exerciseIDs = exerciseIDs,
            rank = rank, required = entry.required, target = spec.target, points = 1,
            icon = spec.icon,
            description = string.format("Earn any %d of these %d exercise achievements.", spec.target, #exerciseIDs),
        }
    end
end

function FF:GetExerciseAchievement(exercise, index)
    local tier = self.achievementTiers[index]
    if exercise.custom then return nil end
    return { id = exercise.id .. ":" .. index, name = self.achievementNames[exercise.id][index],
        kind = "exercise", exerciseID = exercise.id, target = tier.target, points = 1,
        icon = exercise.icon, description = "Complete " .. tier.target .. " " .. exercise.name .. " sessions.", index = index }
end

function FF:GetAchievementProgress(achievement)
    if achievement.kind == "other" then
        return self.accountStats.customOtherSessions or 0
    elseif achievement.kind == "inventor" then
        return self.accountStats.inventor and 1 or 0
    elseif achievement.kind == "exercise" then
        return self.accountStats.lifetime[achievement.exerciseID] or 0
    elseif achievement.kind == "milestone" then
        local completed = 0
        for _, id in ipairs(achievement.exerciseIDs) do
            local prerequisite = self:GetAchievementByID(id .. ":" .. achievement.rank)
            if prerequisite and self:GetAchievementProgress(prerequisite) >= prerequisite.target then
                completed = completed + 1
            end
        end
        return completed
    elseif achievement.kind == "cheater" then
        return self.accountStats.cheater and 1 or 0
    elseif achievement.kind == "skipped" then
        local total = 0
        for _, count in pairs(self.accountStats.skipsLifetime) do total = total + count end
        return total
    elseif achievement.kind == "walking" then
        return self.accountStats.walkingMinutes or 0
    end
    local total = 0
    for _, count in pairs(self.accountStats.lifetime) do total = total + count end
    return total
end

function FF:GetAchievementByID(id)
    for _, achievement in ipairs(self.milestoneAchievements) do
        if achievement.id == id then return achievement end
    end
    for _, achievement in ipairs(self.generalAchievements) do
        if achievement.id == id then return achievement end
    end
    for _, exercise in ipairs(self.exercises) do
        if not exercise.custom then for i = 1, #self.achievementTiers do
            if id == exercise.id .. ":" .. i then
                return self:GetExerciseAchievement(exercise, i)
            end
        end end
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

-- Award the faction-flavored inventor achievement once per account.
function FF:AwardInventorAchievement()
    local achievement = self:GetAchievementByID("inventor")
    if not achievement or not self.accountStats.inventor or self.accountStats.cheater
        or self.accountStats.achievementDates.inventor then return end
    self.accountStats.achievementDates.inventor = time()
    self:AnnounceAchievement(achievement)
end

-- Award the secret achievement once, as soon as the cheater lock activates.
function FF:AwardCheaterAchievement()
    if not self.accountStats.cheater or self.accountStats.achievementDates.cheater11 then return end
    self.accountStats.achievementDates.cheater11 = time()
    self:AnnounceAchievement(self:GetAchievementByID("cheater11"))
end

function FF:CheckAchievementUnlocks(exercise, completed, cheatedNow)
    if cheatedNow then
        self:AwardCheaterAchievement()
        return
    end
    -- Do not award any additional achievements after the cheater flag is set.
    if self.accountStats.cheater then return end
    local achievements = {}
    if completed and not exercise.custom then
        for i, tier in ipairs(self.achievementTiers) do
            local after = self.accountStats.lifetime[exercise.id] or 0
            if after == tier.target then
                achievements[#achievements + 1] = self:GetExerciseAchievement(exercise, i)
            end
        end
    end
    for _, achievement in ipairs(self.generalAchievements) do
        local delta = 0
        if completed and achievement.kind == "total" then
            delta = 1
        elseif completed and achievement.kind == "walking" then
            delta = exercise.durationMinutes or 0
        elseif not completed and achievement.kind == "skipped" then
            delta = 1
        end
        local current = self:GetAchievementProgress(achievement)
        if delta > 0 and current >= achievement.target and current - delta < achievement.target then
            achievements[#achievements + 1] = achievement
        end
    end
    if completed then
        for _, achievement in ipairs(self.milestoneAchievements) do
            if achievement.kind == "other" and exercise.custom and exercise.group == "Other"
                and self:GetAchievementProgress(achievement) == achievement.target
                and not self.accountStats.achievementDates[achievement.id] then
                achievements[#achievements + 1] = achievement
            end
            for _, id in ipairs(achievement.exerciseIDs or {}) do
                if id == exercise.id and (self.accountStats.lifetime[id] or 0) == achievement.required
                    and self:GetAchievementProgress(achievement) == achievement.target
                    and not self.accountStats.achievementDates[achievement.id] then
                    achievements[#achievements + 1] = achievement
                    break
                end
            end
        end
    end
    for _, achievement in ipairs(achievements) do
        if not self.accountStats.achievementDates[achievement.id] then
            self.accountStats.achievementDates[achievement.id] = time()
            self:AnnounceAchievement(achievement)
        end
    end
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

function FF:RefreshInventorName()
    for _, achievement in ipairs(self.generalAchievements) do
        if achievement.id == "inventor" then
            achievement.name = UnitFactionGroup("player") == "Horde"
                and "Bilgewater Patent Pending" or "Gnomeregan Patent Pending"
            return
        end
    end
end
