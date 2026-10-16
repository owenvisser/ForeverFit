local _, FF = ...

-- Counts actual Walking Pad sessions in saved completion totals, including retired custom exercises.
-- Input: a lifetime table keyed by exercise ID. Output: number of completed Walking Pad sessions.
function FF:CountWalkingPadSessions(completionCounts)
    local walkingIDs = {}
    for _, exercise in ipairs(self.baseExercises) do
        if exercise.group == "Walking Pad" then walkingIDs[exercise.id] = true end
    end
    for _, exercise in ipairs(self.db.customExercises) do
        if exercise.group == "Walking Pad" then walkingIDs[exercise.id] = true end
    end
    local total = 0
    for id in pairs(walkingIDs) do total = total + (completionCounts[id] or 0) end
    return total
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
    if exercise.group == "Walking Pad" then
        self.stats.walkingMinutes = self.stats.walkingMinutes + 1
        self.accountStats.walkingMinutes = self.accountStats.walkingMinutes + 1
    end
    if exercise.custom then
        self.stats.exerciseHistory[exercise.id] = { name = exercise.name, group = exercise.group }
    end
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
    if exercise.custom then
        self.stats.exerciseHistory[exercise.id] = { name = exercise.name, group = exercise.group }
    end
    self:CheckAchievementUnlocks(exercise, false)
    if self.achievementsFrame and self.achievementsFrame:IsShown() then
        self:RefreshAchievements()
    end
end

-- Clears all account achievement/workout totals and this character's statistics.
-- Input: current account and character SavedVariables. Output: empty account progress;
-- characters not currently logged in are invalidated by resetGeneration on next login.
function FF:ResetStatistics()
    local account, stats = self.accountStats, self.stats
    account.resetGeneration = (tonumber(account.resetGeneration) or 0) + 1
    account.lifetime = {}
    account.skipsLifetime = {}
    account.achievementDates = {}
    account.walkingMinutes = 0
    account.customOtherSessions = 0
    account.inventor = false
    account.cheater = false
    -- Preserve migratedCharacters: it is bookkeeping, not progress. Old saves are
    -- invalidated by resetGeneration before they can be migrated on future logins.
    stats.resetGeneration = account.resetGeneration
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
    self.achievementAlertQueue = {}
    if self.achievementAlertFrame then self.achievementAlertFrame:Hide() end
    self.state.pending = false
    self:UpdateTaxiWatcher()
    if not self.state.settingsOpen and not self.state.currentExercise then self:StartTimer() end
    if self.achievementsFrame and self.achievementsFrame:IsShown() then
        self:RefreshAchievements()
    end
    if self.RefreshStatisticsTab then self:RefreshStatisticsTab() end
    if self.RefreshOptions then self:RefreshOptions() end
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
            self.Print((names[id] or id .. " (retired)") .. ": level " .. level .. " (" .. countLevel .. " completed, " .. skipsLevel .. " skipped); lifetime (" .. countLifetime .. " completed, " .. skipsLifetime .. " skipped)")
        end
    end
    self.Print("Level " .. level .. ": " .. levelCompleted .. " completed, " .. levelSkipped .. " skipped. Lifetime: " .. lifetimeCompleted .. " completed, " .. lifetimeSkipped .. " skipped.")
end
