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
