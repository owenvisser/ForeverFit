local _, FF = ...

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
