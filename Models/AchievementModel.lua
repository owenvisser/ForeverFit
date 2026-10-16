local _, FF = ...

FF.milestoneAchievements = {}
for rank, entry in ipairs(FF.milestoneRanks) do
    FF.milestoneAchievements[#FF.milestoneAchievements + 1] = {
        id = "other:" .. rank, name = FF.otherAchievementNames[rank], group = entry.group,
        kind = "other", target = entry.required, points = 1,
        icon = "Interface\\Icons\\INV_Misc_Note_01",
        description = "Complete " .. entry.required .. " custom workouts in the Other category.",
    }
    for track, spec in ipairs(FF.milestoneTracks) do
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

-- Builds an exercise achievement using its tier-specific icon when available.
function FF:GetExerciseAchievement(exercise, index)
    local tier = self.achievementTiers[index]
    if exercise.custom then return nil end

    local tierIcons = self.achievementIcons[exercise.id]
    local achievementIcon = tierIcons and tierIcons[index] or exercise.icon

    return { id = exercise.id .. ":" .. index, name = self.achievementNames[exercise.id][index],
        kind = "exercise", exerciseID = exercise.id, target = tier.target, points = 1,
        icon = achievementIcon, description = "Complete " .. tier.target .. " " .. exercise.name .. " sessions.", index = index }
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

function FF:RefreshInventorName()
    for _, achievement in ipairs(self.generalAchievements) do
        if achievement.id == "inventor" then
            achievement.name = UnitFactionGroup("player") == "Horde"
                and "Bilgewater Patent Pending" or "Gnomeregan Patent Pending"
            return
        end
    end
end
