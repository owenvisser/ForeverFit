local ADDON_NAME, FF = ...

FF.state = {
    timer = nil,
    timerVersion = 0,
    settingsOpen = false,
    pending = false,
    currentExercise = nil,
    partyAnnounced = false,
    noExercises = false,
    graceUntil = 0,
    loggedIn = false,
}

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd4af37Forever Fit:|r " .. message)
end
FF.Print = Print

function FF:EnabledExercises()
    local enabled = {}
    for _, exercise in ipairs(self.exercises) do
        if self.db.enabledGroups[exercise.group] and self.db.enabled[exercise.id] then
            enabled[#enabled + 1] = exercise
        end
    end
    return enabled
end

-- Built-in IDs are immutable. Custom entries use monotonic account-wide IDs.
function FF:ReloadExerciseCatalog()
    self.exercises = {}
    for _, exercise in ipairs(self.baseExercises) do
        self.exercises[#self.exercises + 1] = exercise
    end
    for _, exercise in ipairs(self.db.customExercises) do
        if not exercise.deleted then
            self.exercises[#self.exercises + 1] = exercise
        end
    end
end

local function CleanCustomText(value, maxLength)
    value = tostring(value or ""):gsub("[%c|]", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return value:sub(1, maxLength)
end

function FF:SaveCustomExercise(id, name, description, target, group)
    name = CleanCustomText(name, 44)
    description = CleanCustomText(description, 180)
    target = CleanCustomText(target, 40)
    local valid = { ["No Equipment"] = true, ["Free Weights"] = true, ["Walking Pad"] = true, Other = true }
    if name == "" or description == "" or target == "" or not valid[group] then
        return nil, "Enter a name, description, target/rep range, and category."
    end
    local exercise
    if id then
        for _, item in ipairs(self.db.customExercises) do
            if item.id == id and not item.deleted then exercise = item; break end
        end
        if not exercise then return nil, "The selected custom exercise no longer exists." end
    else
        local active = 0
        for _, item in ipairs(self.db.customExercises) do
            if not item.deleted then active = active + 1 end
        end
        if active >= 100 then return nil, "Maximum of 100 active custom exercises reached." end
        self.db.customNextID = self.db.customNextID + 1
        exercise = { id = "custom_" .. self.db.customNextID, custom = true }
        self.db.customExercises[#self.db.customExercises + 1] = exercise
        self.db.enabled[exercise.id] = true
        self.db.cycleCounts[exercise.id] = 0
    end
    exercise.name, exercise.instructions, exercise.target, exercise.group = name, description, target, group
    exercise.icon = "Interface\\Icons\\INV_Misc_Note_01"
    exercise.quip = "A custom quest from the finest trainers of Azeroth!"
    self:ReloadExerciseCatalog()
    self:OnExerciseSelectionChanged()
    if not id and not self.accountStats.inventor and not self.accountStats.cheater then
        self.stats.inventor = true
        self.accountStats.inventor = true
        self:AwardInventorAchievement()
    end
    if self.achievementsFrame and self.achievementsFrame:IsShown() then self:RefreshAchievements() end
    return exercise
end

function FF:DeleteCustomExercise(id)
    for _, item in ipairs(self.db.customExercises) do
        if item.id == id and not item.deleted then
            item.deleted = true -- Preserve stable ID and historical workout counters.
            self:ReloadExerciseCatalog()
            self:OnExerciseSelectionChanged()
            if self.achievementsFrame and self.achievementsFrame:IsShown() then self:RefreshAchievements() end
            return true
        end
    end
end

function FF:InitializeDatabase()
    if type(ForeverFitDB) ~= "table" then
        ForeverFitDB = {}
    end
    self.db = ForeverFitDB
    local db = self.db

    if type(db.minutes) ~= "number" or db.minutes ~= db.minutes then
        db.minutes = 30
    end
    db.minutes = math.floor(math.max(10, math.min(60, db.minutes)) + 0.5)
    -- Retire the 10-second developer override while preserving all other settings.
    db.developer = nil
    -- Migrate the former combined switches without changing existing preferences.
    if db.guildLevelAnnounce == nil then db.guildLevelAnnounce = db.guildAnnounce == true end
    if db.guildAchievementAnnounce == nil then db.guildAchievementAnnounce = db.guildAnnounce ~= false end
    if db.partyBreakAnnounce == nil then db.partyBreakAnnounce = db.partyAnnounce ~= false end
    if db.partyInviteAnnounce == nil then db.partyInviteAnnounce = false end
    db.guildLevelAnnounce = db.guildLevelAnnounce == true
    db.guildAchievementAnnounce = db.guildAchievementAnnounce == true
    db.partyBreakAnnounce = db.partyBreakAnnounce == true
    db.partyInviteAnnounce = db.partyInviteAnnounce == true
    db.taxiBreak = db.taxiBreak == true
    db.campfireBreak = db.campfireBreak == true
    if db.soundEnabled == nil then db.soundEnabled = true end
    db.soundEnabled = db.soundEnabled == true
    db.soundHumanMaleOnly = db.soundHumanMaleOnly == true
    if type(db.customExercises) ~= "table" then db.customExercises = {} end
    db.customNextID = tonumber(db.customNextID) or 0
    self.baseExercises = self.baseExercises or self.exercises
    self:ReloadExerciseCatalog()
    if type(db.enabledGroups) ~= "table" then db.enabledGroups = {} end
    for _, group in ipairs({ "No Equipment", "Free Weights", "Walking Pad", "Other" }) do
        if db.enabledGroups[group] == nil then db.enabledGroups[group] = true end
    end
    if type(db.lastExerciseID) ~= "string" then
        db.lastExerciseID = nil
    end

    -- Save whether each exercise has already appeared in the current rotation.
    -- Migrate existing v0.1.1 users by marking their last pick as already used.
    local firstRotation = type(db.cycleCounts) ~= "table"
    if firstRotation then
        db.cycleCounts = {}
    end
    for _, exercise in ipairs(self.exercises) do
        local id = exercise.id
        db.cycleCounts[id] = (db.cycleCounts[id] == 1) and 1 or 0
        if firstRotation and id == db.lastExerciseID then
            db.cycleCounts[id] = 1
        end
    end

    if type(db.enabled) ~= "table" then
        db.enabled = {}
        for _, exercise in ipairs(self.exercises) do
            db.enabled[exercise.id] = (exercise.group == "No Equipment" or exercise.custom == true)
        end
    end
    for _, exercise in ipairs(self.exercises) do
        if exercise.custom and db.enabled[exercise.id] == nil then db.enabled[exercise.id] = true end
    end
    self.state.noExercises = #self:EnabledExercises() == 0
end

-- Level-up records and popup layout remain per-character; achievement progress is account-wide.
function FF:InitializeStatistics()
    if type(ForeverFitCharDB) ~= "table" then ForeverFitCharDB = {} end
    self.stats = ForeverFitCharDB
    self:RefreshInventorName()
    local stats = self.stats
    stats.lifetime = stats.lifetime or {}
    stats.levels = stats.levels or {}
    stats.skipsLifetime = stats.skipsLifetime or {}
    stats.skipsLevels = stats.skipsLevels or {}
    stats.achievementDates = stats.achievementDates or {}
    stats.completionTimes = stats.completionTimes or {}
    stats.cheater = stats.cheater == true
    stats.inventor = stats.inventor == true
    stats.customOtherSessions = stats.customOtherSessions or 0
    if type(stats.walkingMinutes) ~= "number" then
        local durations = { easywalk = 3, briskwalk = 2, recoverywalk = 4, steadywalk = 5 }
        local minutes = 0
        for id, duration in pairs(durations) do
            minutes = minutes + (stats.lifetime[id] or 0) * duration
        end
        stats.walkingMinutes = minutes
    end
    local account = self.db.accountStats
    if type(account) ~= "table" then account = {}; self.db.accountStats = account end
    account.lifetime = account.lifetime or {}
    account.skipsLifetime = account.skipsLifetime or {}
    account.achievementDates = account.achievementDates or {}
    account.walkingMinutes = account.walkingMinutes or 0
    account.customOtherSessions = account.customOtherSessions or 0
    account.inventor = account.inventor == true
    account.cheater = account.cheater == true
    account.migratedCharacters = account.migratedCharacters or {}
    self.accountStats = account
end

-- Merge v0.1.30 character histories once, when player identity is available.
-- A different character contributes its own history on its first login after updating.
function FF:MigrateAccountStatistics()
    local account, stats = self.accountStats, self.stats
    local key = GetRealmName() .. ":" .. UnitName("player")
    if not account.migratedCharacters[key] then
        for id, count in pairs(stats.lifetime) do
            account.lifetime[id] = (account.lifetime[id] or 0) + count
        end
        for id, count in pairs(stats.skipsLifetime) do
            account.skipsLifetime[id] = (account.skipsLifetime[id] or 0) + count
        end
        account.walkingMinutes = account.walkingMinutes + stats.walkingMinutes
        account.customOtherSessions = account.customOtherSessions + stats.customOtherSessions
        account.inventor = account.inventor or stats.inventor
        account.cheater = account.cheater or stats.cheater
        for id, stamp in pairs(stats.achievementDates) do
            local existing = account.achievementDates[id]
            if not existing or stamp < existing then account.achievementDates[id] = stamp end
        end
        account.migratedCharacters[key] = true
    end
    -- After migration, the account owns the lockout and earned achievements.
    stats.cheater = account.cheater
    stats.inventor = account.inventor
end

function FF:InLoginGrace()
    return not self.state.loggedIn or GetTime() < self.state.graceUntil
end

-- Detect eleven completed workouts within any rolling 60-second window.
-- Wall-clock timestamps persist across reloads, unlike GetTime().
function FF:CheckCompletionRate()
    if self.stats.cheater then return false end
    local now = time()
    local recent = {}
    for _, stamp in ipairs(self.stats.completionTimes) do
        if stamp >= now - 60 and stamp <= now then
            recent[#recent + 1] = stamp
        end
    end
    recent[#recent + 1] = now
    self.stats.completionTimes = recent
    if #recent > 10 then
        self.stats.cheater = true
        self.accountStats.cheater = true
        self:AwardCheaterAchievement()
        self:StopForCheater()
        return true
    end
    return false
end

function FF:RecordCompletion(exercise)
    if self.stats.cheater then return end
    local id = exercise.id
    local level = UnitLevel("player")
    local lifetime = self.stats.lifetime
    local perLevel = self.stats.levels
    perLevel[level] = perLevel[level] or {}
    lifetime[id] = (lifetime[id] or 0) + 1
    self.accountStats.lifetime[id] = (self.accountStats.lifetime[id] or 0) + 1
    perLevel[level][id] = (perLevel[level][id] or 0) + 1
    self.stats.walkingMinutes = self.stats.walkingMinutes + (exercise.durationMinutes or 0)
    self.accountStats.walkingMinutes = self.accountStats.walkingMinutes + (exercise.durationMinutes or 0)
    if exercise.custom and exercise.group == "Other" then
        self.stats.customOtherSessions = self.stats.customOtherSessions + 1
        self.accountStats.customOtherSessions = self.accountStats.customOtherSessions + 1
    end
    local cheatedNow = self:CheckCompletionRate()
    self:CheckAchievementUnlocks(exercise, true, cheatedNow)
    if self.achievementsFrame and self.achievementsFrame:IsShown() then
        self:RefreshAchievements()
    end
end

function FF:RecordSkip(exercise)
    if self.stats.cheater then return end
    local id = exercise.id
    local level = UnitLevel("player")
    local lifetime = self.stats.skipsLifetime
    local perLevel = self.stats.skipsLevels
    perLevel[level] = perLevel[level] or {}
    lifetime[id] = (lifetime[id] or 0) + 1
    self.accountStats.skipsLifetime[id] = (self.accountStats.skipsLifetime[id] or 0) + 1
    perLevel[level][id] = (perLevel[level][id] or 0) + 1
    self:CheckAchievementUnlocks(exercise, false)
    if self.achievementsFrame and self.achievementsFrame:IsShown() then
        self:RefreshAchievements()
    end
end

function FF:ResetStatistics()
    -- Reset only this character's contribution, retaining other characters' progress.
    local account = self.accountStats
    for id, count in pairs(self.stats.lifetime) do
        account.lifetime[id] = math.max(0, (account.lifetime[id] or 0) - count)
    end
    for id, count in pairs(self.stats.skipsLifetime) do
        account.skipsLifetime[id] = math.max(0, (account.skipsLifetime[id] or 0) - count)
    end
    account.walkingMinutes = math.max(0, account.walkingMinutes - self.stats.walkingMinutes)
    account.customOtherSessions = math.max(0, account.customOtherSessions - self.stats.customOtherSessions)
    account.cheater = false
    account.achievementDates.cheater11 = nil
    self.stats.lifetime = {}
    self.stats.levels = {}
    self.stats.skipsLifetime = {}
    self.stats.skipsLevels = {}
    self.stats.achievementDates = {}
    self.stats.completionTimes = {}
    self.stats.cheater = false
    self.stats.inventor = false
    self.stats.customOtherSessions = 0
    self.stats.walkingMinutes = 0
    self.stats.lastAnnouncedLevel = nil
    -- Drop dates for achievements no longer earned; keep other characters' dates.
    for _, group in ipairs({ self.generalAchievements, self.milestoneAchievements }) do
        for _, achievement in ipairs(group) do
            if self:GetAchievementProgress(achievement) < achievement.target then
                account.achievementDates[achievement.id] = nil
            end
        end
    end
    for _, exercise in ipairs(self.baseExercises) do
        for i = 1, #self.achievementTiers do
            local achievement = self:GetExerciseAchievement(exercise, i)
            if self:GetAchievementProgress(achievement) < achievement.target then
                account.achievementDates[achievement.id] = nil
            end
        end
    end
    self:UpdateTaxiWatcher()
    if not self.state.settingsOpen then self:StartTimer() end
    if self.achievementsFrame and self.achievementsFrame:IsShown() then
        self:RefreshAchievements()
    end
end

-- Confirmed apology restores reminders without altering workout statistics.
function FF:ForgiveCheater()
    if not self.stats.cheater then return end
    self.stats.cheater = false
    self.accountStats.cheater = false
    self.accountStats.achievementDates.cheater11 = nil
    self.stats.completionTimes = {}
    self.state.pending = false
    self:UpdateTaxiWatcher()
    if not self.state.settingsOpen then self:StartTimer() end
    if self.achievementsFrame and self.achievementsFrame:IsShown() then self:RefreshAchievements() end
end

-- Announce only total completed sessions and the most frequent exercise for the completed level.
-- Ties follow the stable exercise ordering in Exercises.lua.
function FF:AnnounceLevelWorkouts(newLevel)
    if not self.db.guildLevelAnnounce or not IsInGuild() then return end
    local previousLevel = newLevel - 1
    local completions = self.stats.levels[previousLevel] or {}
    local total, most, mostCount = 0, nil, 0
    local names = {}
    for _, exercise in ipairs(self.exercises) do names[exercise.id] = exercise.name end
    local ids = {}
    for id in pairs(completions) do ids[#ids + 1] = id end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local count = completions[id] or 0
        total = total + count
        if count > mostCount then
            most, mostCount = names[id] or id, count
        end
    end
    local favorite = most and (most .. " x" .. mostCount) or "none"
    C_ChatInfo.SendChatMessage(string.format(
        "[Forever Fit] %s reached level %d! Level %d: %d workouts completed. Most common: %s.",
        UnitName("player") or "An adventurer", newLevel, previousLevel, total, favorite
    ), "GUILD")
end

-- Addon achievements are announced as plain text in guild chat. The receiving
-- Forever Fit addon renders the title as a locally clickable link.
-- Invite the party only when a real popup appears; never announce in a raid.
function FF:AnnouncePartyExercise(exercise)
    if not IsInGroup() or IsInRaid() then return false end
    if not self.db.partyBreakAnnounce and not self.db.partyInviteAnnounce then return false end
    local player = UnitName("player") or "An adventurer"
    if self.db.partyBreakAnnounce then
        C_ChatInfo.SendChatMessage(string.format(
            "[Forever Fit] BRB, heroes! %s got a real-life quest: %s (%s). Give me a moment to grind some Strength!",
            player, exercise.name, exercise.target
        ), "PARTY")
    end
    if self.db.partyInviteAnnounce then
        C_ChatInfo.SendChatMessage(string.format(
            "[Forever Fit] Bonus party quest: join me for %s (%s)! Rewards: +1 IRL Stamina and bragging rights.",
            exercise.name, exercise.target
        ), "PARTY")
    end
    return true
end

function FF:AnnounceAchievement(achievement)
    if not self.db.guildAchievementAnnounce or not IsInGuild() then return end
    C_ChatInfo.SendChatMessage(string.format(
        "[Forever Fit] %s has earned [%s]!",
        UnitName("player") or "An adventurer", achievement.name
    ), "GUILD")
end

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

function FF:RegisterAchievementChatLinks()
    local byTitle = {}
    for _, collection in ipairs({ self.generalAchievements, self.milestoneAchievements }) do
        for _, achievement in ipairs(collection) do
            byTitle[achievement.name] = achievement.id
        end
    end
    -- Custom workouts do not have individual tier achievements.
    for _, exercise in ipairs(self.baseExercises) do
        for i = 1, #self.achievementTiers do
            local achievement = self:GetExerciseAchievement(exercise, i)
            byTitle[achievement.name] = achievement.id
        end
    end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", function(_, _, message, sender, ...)
        local title = message:match("%[Forever Fit%] .- has earned %[(.-)%]!")
        local id = title and byTitle[title]
        if not id then return false end
        local from = (sender or ""):gsub("[|@]", "")
        local link = "|cffffff00|Haddon:ForeverFit:" .. id .. "@" .. from .. "|h[" .. title .. "]|h|r"
        local modified = message:gsub("%[" .. title:gsub("([^%w])", "%%%1") .. "%]", link, 1)
        return false, modified, sender, ...
    end)
    EventRegistry:RegisterCallback("SetItemRef", function(_, link)
        local id, sender = link and link:match("^addon:ForeverFit:([^@]+)@(.+)$")
        if id then FF:ShowAchievementTooltip(id, sender) end
    end, self)
end

function FF:OnPlayerLevelUp(newLevel)
    if type(newLevel) ~= "number" or newLevel < 2 then
        return
    end
    if self.stats.lastAnnouncedLevel == newLevel then
        return
    end
    self.stats.lastAnnouncedLevel = newLevel
    self:AnnounceLevelWorkouts(newLevel)
end

function FF:PrintStatistics()
    local level = UnitLevel("player")
    local current = self.stats.levels[level] or {}
    local skipped = self.stats.skipsLevels[level] or {}
    local levelCompleted, levelSkipped, lifetimeCompleted, lifetimeSkipped = 0, 0, 0, 0
    local names = {}
    for _, exercise in ipairs(self.exercises) do names[exercise.id] = exercise.name end
    local ids = {}
    local seen = {}
    for _, counts in ipairs({ self.stats.lifetime, self.stats.skipsLifetime }) do
        for id in pairs(counts) do
            if not seen[id] then ids[#ids + 1] = id; seen[id] = true end
        end
    end
    table.sort(ids)
    for _, id in ipairs(ids) do
        local countLevel = current[id] or 0
        local countLifetime = self.stats.lifetime[id] or 0
        local skipsLevel = skipped[id] or 0
        local skipsLifetime = self.stats.skipsLifetime[id] or 0
        levelCompleted = levelCompleted + countLevel
        levelSkipped = levelSkipped + skipsLevel
        lifetimeCompleted = lifetimeCompleted + countLifetime
        lifetimeSkipped = lifetimeSkipped + skipsLifetime
        if countLifetime > 0 or skipsLifetime > 0 then
            Print((names[id] or id .. " (retired)") .. ": level " .. level .. " (" .. countLevel .. " completed, " .. skipsLevel .. " skipped); lifetime (" .. countLifetime .. " completed, " .. skipsLifetime .. " skipped)")
        end
    end
    Print("Level " .. level .. ": " .. levelCompleted .. " completed, " .. levelSkipped .. " skipped. Lifetime: " .. lifetimeCompleted .. " completed, " .. lifetimeSkipped .. " skipped.")
end

-- SoundKit IDs for the Classic race and sex /cheer and /chicken voices.
-- Play the audio locally; do not perform a public emote.
local workoutVoices = {
    Human = {
        Male = { completed = 2677, skipped = 6919 },
        Female = { completed = 2689, skipped = 6914 },
    },
    Orc = {
        Male = { completed = 2701, skipped = 6939 },
        Female = { completed = 2713, skipped = 6934 },
    },
    Dwarf = {
        Male = { completed = 2725, skipped = 6899 },
        Female = { completed = 2737, skipped = 6894 },
    },
    NightElf = {
        Male = { completed = 2749, skipped = 6929 },
        Female = { completed = 2761, skipped = 6924 },
    },
    Scourge = {
        Male = { completed = 2773, skipped = 6949 },
        Female = { completed = 2785, skipped = 6944 },
    },
    Tauren = {
        Male = { completed = 2797, skipped = 6959 },
        Female = { completed = 2809, skipped = 6954 },
    },
    Gnome = {
        Male = { completed = 2821, skipped = 6909 },
        Female = { completed = 2833, skipped = 6904 },
    },
    Troll = {
        Male = { completed = 2859, skipped = 6969 },
        Female = { completed = 2871, skipped = 6964 },
    },
}

function FF:PlayWorkoutSound(completed)
    if not self.db.soundEnabled then return end
    local _, race = UnitRace("player")
    local voices = self.db.soundHumanMaleOnly and workoutVoices.Human or workoutVoices[race]
    -- New races without Classic emote kits use the corresponding Human voice.
    local voice = (voices or workoutVoices.Human)[self.db.soundHumanMaleOnly and "Male" or (UnitSex("player") == 3 and "Female" or "Male")]
    PlaySound(completed and voice.completed or voice.skipped, "SFX")
end

-- Called when exercise or group checkboxes change. A zero-selection state is
-- valid and pauses reminders; re-enabling starts a fresh timer interval.
function FF:OnExerciseSelectionChanged()
    local empty = #self:EnabledExercises() == 0
    if empty then
        self:CancelTimer()
        self.state.pending = false
    elseif self.state.noExercises then
        self.state.pending = false
        if not self.state.settingsOpen and not self.state.currentExercise then
            self:StartTimer()
        end
    end
    self.state.noExercises = empty
    self:UpdateTaxiWatcher()
end

function FF:StopForCheater()
    -- Recover the hidden achievement for any migrated account lockout.
    self:AwardCheaterAchievement()
    self:CancelTimer()
    if self.state.taxiTicker then
        self.state.taxiTicker:Cancel()
        self.state.taxiTicker = nil
    end
    self.state.pending = false
    self.state.currentExercise = nil
    self.state.partyAnnounced = false
    if self.popup then self.popup:Hide() end
end

function FF:CancelTimer()
    local state = self.state
    state.timerVersion = state.timerVersion + 1
    if state.timer then
        state.timer:Cancel()
        state.timer = nil
    end
end

-- A one-second poll avoids the race between PLAYER_CONTROL_LOST and UnitOnTaxi.
-- Seed the state when enabled, so enabling it mid-flight does not generate a false boarding.
-- Welcoming Campfire is spell 1289723 and 1229739, the one-minute campsite resting aura.
local WELCOMING_CAMPFIRE_STARTING = 1229739
local WELCOMING_CAMPFIRE_PLAYER = 1289723

function FF:HasWelcomingCampfire()
    return C_UnitAuras.GetPlayerAuraBySpellID(WELCOMING_CAMPFIRE_STARTING) ~= nil
        or C_UnitAuras.GetPlayerAuraBySpellID(WELCOMING_CAMPFIRE_PLAYER) ~= nil
end

function FF:OnCampfireAuraChanged()
    local active = self:HasWelcomingCampfire()
    local newlyGained = active and not self.state.wasWelcomingCampfire
    self.state.wasWelcomingCampfire = active
    if not newlyGained or not self.db.campfireBreak or self:InLoginGrace()
        or self.stats.cheater or #self:EnabledExercises() == 0
        or self.state.pending or self.state.currentExercise then return end
    self:CancelTimer()
    self.state.pending = true
    self:TryShowExercise()
end

function FF:UpdateTaxiWatcher()
    local state = self.state
    if state.taxiTicker then
        state.taxiTicker:Cancel()
        state.taxiTicker = nil
    end
    if not self.db.taxiBreak or self.stats.cheater or #self:EnabledExercises() == 0 then return end
    state.wasOnTaxi = UnitOnTaxi("player") == true
    state.taxiTicker = C_Timer.NewTicker(1, function()
        local onTaxi = UnitOnTaxi("player") == true
        if not FF.stats.cheater and not FF:InLoginGrace() and onTaxi and not FF.state.wasOnTaxi and not FF.state.pending and not FF.state.currentExercise then
            FF:CancelTimer()
            FF.state.pending = true
            FF:TryShowExercise()
        end
        FF.state.wasOnTaxi = onTaxi
    end)
end

function FF:StartTimer()
    self:CancelTimer()
    if self.stats.cheater or #self:EnabledExercises() == 0 then return end
    local state = self.state
    if state.settingsOpen or state.pending or state.currentExercise then
        return
    end

    local seconds = math.max(self.db.minutes * 60, math.ceil(self.state.graceUntil - GetTime()))
    local version = state.timerVersion
    state.timer = C_Timer.NewTimer(seconds, function()
        if FF.state.timerVersion ~= version then
            return
        end
        FF.state.timer = nil
        FF.state.pending = true
        FF:TryShowExercise()
    end)
end

-- Random rotation: used exercises have weight 0, unused exercises weight 1.
-- Once all currently enabled exercises have been selected, start a new cycle.
-- Excluding the last pick also prevents repeats across cycle boundaries.
function FF:ChooseExercise(enabled)
    local counts = self.db.cycleCounts
    local choices = {}
    for _, exercise in ipairs(enabled) do
        if counts[exercise.id] ~= 1 then
            choices[#choices + 1] = exercise
        end
    end

    if #choices == 0 then
        -- Every enabled exercise has been used: clear the entire cycle.
        for _, exercise in ipairs(self.exercises) do
            counts[exercise.id] = 0
        end
        choices = enabled
    end

    if #enabled > 1 then
        local nonRepeats = {}
        for _, exercise in ipairs(choices) do
            if exercise.id ~= self.db.lastExerciseID then
                nonRepeats[#nonRepeats + 1] = exercise
            end
        end
        if #nonRepeats == 0 then
            -- Safety for exercise checkbox changes halfway through a cycle.
            for _, exercise in ipairs(self.exercises) do
                counts[exercise.id] = 0
            end
            for _, exercise in ipairs(enabled) do
                if exercise.id ~= self.db.lastExerciseID then
                    nonRepeats[#nonRepeats + 1] = exercise
                end
            end
        end
        choices = nonRepeats
    end

    local exercise = choices[math.random(#choices)]
    counts[exercise.id] = 1
    self.db.lastExerciseID = exercise.id
    return exercise
end

function FF:TryShowExercise()
    if self.stats.cheater then
        self:StopForCheater()
        return
    end
    local state = self.state
    if self:InLoginGrace() then
        state.pending = false
        self:StartTimer()
        return
    end
    local enabled = self:EnabledExercises()
    if #enabled == 0 then
        state.pending = false
        return
    end
    if not state.pending or state.settingsOpen or InCombatLockdown() then
        return
    end
    if not state.currentExercise then
        state.currentExercise = self:ChooseExercise(enabled)
        state.partyAnnounced = false
    end
    state.pending = false
    self:ShowExercisePopup(state.currentExercise)
    if not state.partyAnnounced then
        state.partyAnnounced = self:AnnouncePartyExercise(state.currentExercise)
    end
end

function FF:DismissExercise(completed)
    if self.stats.cheater then
        self:StopForCheater()
        return
    end
    if not self.state.currentExercise then
        return
    end
    self:PlayWorkoutSound(completed)
    if completed then
        self:RecordCompletion(self.state.currentExercise)
    else
        self:RecordSkip(self.state.currentExercise)
    end
    self.popup:Hide()
    self.state.currentExercise = nil
    self.state.partyAnnounced = false
    self.state.pending = false
    self:StartTimer()
end

function FF:SetSettingsOpen(isOpen)
    if self.state.settingsOpen == isOpen then
        return
    end
    self.state.settingsOpen = isOpen
    if isOpen then
        self:CancelTimer()
    elseif self.state.pending then
        self:TryShowExercise()
    elseif not self.state.currentExercise then
        self:StartTimer()
    end
end

function FF:OpenSettings()
    if self.category then
        Settings.OpenToCategory(self.category:GetID())
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_LEVEL_UP")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterUnitEvent("UNIT_AURA", "player")
eventFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == ADDON_NAME then
        FF:InitializeDatabase()
        FF:InitializeStatistics()
        FF:BuildPopup()
        FF:BuildOptions()
    elseif event == "PLAYER_LOGIN" then
        if FF.db then
            FF:RefreshInventorName()
            FF:MigrateAccountStatistics()
            FF.state.loggedIn = true
            FF.state.graceUntil = GetTime() + 10
            FF.state.wasWelcomingCampfire = FF:HasWelcomingCampfire()
            FF:StartTimer()
            FF:UpdateTaxiWatcher()
            FF:StartLegacyButtonWatcher()
            FF:RegisterAchievementChatLinks()
        end
    elseif event == "ADDON_LOADED" then
        if FF.db then
            FF:TryAttachLegacyButton()
        end
    elseif event == "UNIT_AURA" and addonName == "player" then
        if FF.db then FF:OnCampfireAuraChanged() end
    elseif event == "PLAYER_LEVEL_UP" then
        if FF.db and FF.stats then
            FF:OnPlayerLevelUp(addonName)
        end
    elseif event == "PLAYER_REGEN_DISABLED" then
        if FF.popup and FF.popup:IsShown() then
            FF.popup:Hide()
            FF.state.pending = true
        end
    elseif event == "PLAYER_REGEN_ENABLED" then
        FF:TryShowExercise()
    end
end)

SLASH_FOREVERFIT1 = "/ffit"
SLASH_FOREVERFIT2 = "/foreverfit"
SlashCmdList.FOREVERFIT = function(message)
    if not FF.db then
        return
    end
    local cmd = (message or ""):lower():match("^%s*(.-)%s*$")
    if cmd == "test" then
        if FF:InLoginGrace() then
            Print("Workouts are disabled during the first ten seconds after login or /reload.")
            return
        end
        if FF.stats.cheater then
            Print("Workouts are locked by The Forever Fit Cheater. Use Reset Statistics in settings to resume.")
            return
        end
        if FF.state.currentExercise then
            Print("An exercise reminder is already active.")
            return
        end
        if #FF:EnabledExercises() == 0 then
            Print("Reminders are paused. Enable an exercise in settings to resume.")
            return
        end
        FF:CancelTimer()
        FF.state.pending = true
        FF:TryShowExercise()
        if FF.state.pending then
            Print("Test reminder queued until you leave combat and close settings.")
        end
    elseif cmd == "stats" then
        FF:PrintStatistics()
    elseif cmd == "achievements" or cmd == "ach" then
        FF:ToggleAchievements()
    elseif cmd == "icons" then
        local missing, checked = 0, 0
        for _, exercise in ipairs(FF.exercises) do
            checked = checked + 1
            if FF:ResolveIcon(exercise.icon) == 134400 then
                Print("Missing exercise icon: " .. exercise.name .. " (using fallback)")
                missing = missing + 1
            end
        end
        for _, achievement in ipairs(FF.generalAchievements) do
            checked = checked + 1
            if FF:ResolveIcon(achievement.icon) == 134400 then
                Print("Missing achievement icon: " .. achievement.name .. " (using fallback)")
                missing = missing + 1
            end
        end
        Print(string.format("Icon check: %d/%d built-in icons found.", checked - missing, checked))
    elseif cmd == "status" then
        local interval = FF.db.minutes .. " minutes"
        local enabled = FF:EnabledExercises()
        local used = 0
        for _, exercise in ipairs(enabled) do
            if FF.db.cycleCounts[exercise.id] == 1 then
                used = used + 1
            end
        end
        Print("Interval: " .. interval .. "; enabled exercises: " .. #enabled .. "; rotation: " .. used .. "/" .. #enabled .. " completed" .. (FF.stats.cheater and "; workouts LOCKED (reset statistics to resume)" or (#enabled == 0 and "; reminders PAUSED" or "")))
    else
        FF:OpenSettings()
    end
end
