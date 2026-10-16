local _, FF = ...

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

function FF:SaveCustomExercise(id, name, description, group)
    name = CleanCustomText(name, 44)
    description = CleanCustomText(description, 180)
    local valid = { ["No Equipment"] = true, ["Free Weights"] = true, ["Walking Pad"] = true, Other = true }
    if name == "" or description == "" or not valid[group] then
        return nil, "Enter a name, description, and category."
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
    exercise.name, exercise.instructions, exercise.group = name, description, group
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
