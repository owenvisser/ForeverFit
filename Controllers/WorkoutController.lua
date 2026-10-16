local _, FF = ...

function FF:InLoginGrace()
    return not self.state.loggedIn or GetTime() < self.state.graceUntil
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
        or self.state.campfireTriggeredThisSession
        or self.stats.cheater or #self:EnabledExercises() == 0
        or self.state.pending or self.state.currentExercise then return end
    -- Permit only one campfire-triggered reminder per login; other triggers remain available.
    self.state.campfireTriggeredThisSession = true
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
            FF.state.campfireTriggeredThisSession = false
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
        FF.state.campfireTriggeredThisSession = false
        FF.state.pending = true
        FF:TryShowExercise()
    end)
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
