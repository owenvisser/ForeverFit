local _, FF = ...

function FF:AnnounceAchievement(achievement)
    if not self.db.guildAchievementAnnounce or not IsInGuild() then return end
    C_ChatInfo.SendChatMessage(string.format(
        "[Forever Fit] %s has earned [%s]!",
        UnitName("player") or "An adventurer", achievement.name
    ), "GUILD")
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

-- Award the faction-flavored inventor achievement once per account.
function FF:AwardInventorAchievement()
    local achievement = self:GetAchievementByID("inventor")
    if not achievement or not self.accountStats.inventor or self.accountStats.cheater
        or self.accountStats.achievementDates.inventor then return end
    self.accountStats.achievementDates.inventor = time()
    self:AnnounceAchievement(achievement)
    self:QueueAchievementAlert(achievement)
end

-- Award the secret achievement once, as soon as the cheater lock activates.
function FF:AwardCheaterAchievement()
    if not self.accountStats.cheater or self.accountStats.achievementDates.cheater11 then return end
    self.accountStats.achievementDates.cheater11 = time()
    local achievement = self:GetAchievementByID("cheater11")
    self:AnnounceAchievement(achievement)
    self:QueueAchievementAlert(achievement)
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
        elseif completed and achievement.kind == "walking" and exercise.group == "Walking Pad" then
            delta = 1
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
            self:QueueAchievementAlert(achievement)
        end
    end
end
