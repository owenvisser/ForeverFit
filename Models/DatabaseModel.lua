local _, FF = ...

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
    -- Keep the legacy key but count Walking Pad sessions, not minutes or unrelated workouts.
    if type(stats.walkingMinutes) ~= "number" then
        stats.walkingMinutes = self:CountWalkingPadSessions(stats.lifetime)
    end
    -- Persist custom exercise names/categories with the character's workout history.
    stats.exerciseHistory = stats.exerciseHistory or {}
    for _, exercise in ipairs(self.db.customExercises) do
        if (stats.lifetime[exercise.id] or 0) > 0 or (stats.skipsLifetime[exercise.id] or 0) > 0 then
            stats.exerciseHistory[exercise.id] = stats.exerciseHistory[exercise.id]
                or { name = exercise.name, group = exercise.group }
        end
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
    account.resetGeneration = tonumber(account.resetGeneration) or 0
    -- Old offline characters must not restore workout history after an account reset.
    -- Keep non-statistical character preferences (such as popup layout) untouched.
    if (tonumber(stats.resetGeneration) or 0) ~= account.resetGeneration then
        stats.lifetime = {}
        stats.levels = {}
        stats.skipsLifetime = {}
        stats.skipsLevels = {}
        stats.achievementDates = {}
        stats.completionTimes = {}
        stats.exerciseHistory = {}
        stats.cheater = false
        stats.inventor = false
        stats.customOtherSessions = 0
        stats.walkingMinutes = 0
        stats.lastAnnouncedLevel = nil
    end
    stats.resetGeneration = account.resetGeneration
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
    -- Correct previously inflated Walking Pad counts using actual exercise IDs.
    stats.walkingMinutes = self:CountWalkingPadSessions(stats.lifetime)
    account.walkingMinutes = self:CountWalkingPadSessions(account.lifetime)
    -- Remove falsely earned Walking Pad dates, preserving legitimate unlocks.
    for _, achievement in ipairs(self.generalAchievements) do
        if achievement.kind == "walking" and account.walkingMinutes < achievement.target then
            account.achievementDates[achievement.id] = nil
            stats.achievementDates[achievement.id] = nil
        end
    end
    -- After migration, the account owns the lockout and earned achievements.
    stats.cheater = account.cheater
    stats.inventor = account.inventor
end
