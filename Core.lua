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
