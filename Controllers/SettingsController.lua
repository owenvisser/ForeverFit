local _, FF = ...

-- Registers General as the settings root and constructs the remaining three tabs.
-- Input: loaded settings views and saved preferences. Output: registered Blizzard settings pages.
function FF:BuildOptions()
    local panel = self:BuildGeneralTab()
    local category = Settings.RegisterCanvasLayoutCategory(panel, "Forever Fit")
    Settings.RegisterAddOnCategory(category)
    self.category = category
    self.settingsPanel = panel
    self:BuildDefaultOptions()
    self:BuildCustomOptions()
    self:BuildInfoOptions()
    self:RefreshOptions()
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
