# Forever Fit 1.1.0 — MVC-style source organization

Forever Fit is a World of Warcraft: Forever addon that delivers workout reminders, editable custom exercises, and Fitness Challenges. This package reorganizes the original Lua code by responsibility without changing the existing SavedVariables schemas or built-in exercise IDs.

## Installation

Copy the complete **ForeverFit** directory into your client's `Interface/AddOns/` directory. Ensure that `ForeverFit.toc` is immediately inside `ForeverFit/`. Enable the addon in the client and `/reload`.

Keep your existing saved data: `ForeverFitDB` (account-wide) and `ForeverFitCharDB` (per-character). **Back up your SavedVariables before upgrading.** No existing SavedVariables keys were renamed by this refactor.

## Source tree

```text
ForeverFit/
  ForeverFit.toc
  Core.lua
  README.md
  Data/
    Exercises.lua
    AchievementDefinitions.lua
  Models/
    DatabaseModel.lua
    ExerciseModel.lua
    AchievementModel.lua
    StatisticsModel.lua
  Controllers/
    WorkoutController.lua
    AchievementController.lua
    SettingsController.lua
  Views/
    PopupView.lua
    AchievementsView.lua
    Settings/
      GeneralTab.lua
      DefaultExercisesTab.lua
      CustomExercisesTab.lua
      InfoTab.lua
      OptionsTheme.lua
      OptionsWidgets.lua
```

### Responsibilities

- **Data**: Static built-in exercise records and achievement descriptions, thresholds, and tier configuration. All workout types remain in *one* `Exercises.lua` file.
- **Models**: Exercise catalog and rotation, account/character SavedVariables, completion statistics, and achievement progress calculations.
- **Controllers**: Reminder scheduling and game triggers, awarding achievements and guild-chat links, and settings-page registration.
- **Views**: Workout popup, Fitness Challenges UI, individual settings tabs, plus the common settings theme and widgets.
- **Core.lua**: Minimal addon bootstrap, shared runtime state, WoW event dispatch, and `/ffit` commands.

## Editing the addon

- To change a workout name, description, instruction, or category, edit `Data/Exercises.lua` (keep its `id` unchanged for existing players).
- To change achievement text or target configuration, edit `Data/AchievementDefinitions.lua` (preserve IDs and be aware that altering targets changes progression).
- To change workout rotation or custom-exercise storage logic, edit `Models/ExerciseModel.lua`.
- To change statistics / SavedVariables initialization, edit the corresponding files in `Models/`.
- To change reminders, taxi/campfire detection, or workout completion dispatch, edit `Controllers/WorkoutController.lua`.
- The Welcoming Campfire can trigger at most one workout per login session. This lock is held only in runtime state, not SavedVariables; logging in or `/reload` starts a fresh session for the addon. Timed and taxi reminders are unaffected.
- To change one settings tab's controls, open the corresponding file in `Views/Settings/`; adjust common appearance in `OptionsTheme.lua`.

`ForeverFit.toc` is the explicit Lua load order. When you add a Lua file, list it there after any files it depends on. The addon retains the original `FF` shared namespace (`local _, FF = ...`), public method names, and initialization hooks.

## Commands

`/ffit` — settings. `/ffit stats` — workout statistics. `/ffit achievements` — Fitness Challenges. `/ffit test` — test popup (outside login grace/combat). `/ffit status` — active rotation status. `/ffit icons` — verify available built-in icons.

## Validation

The delivered package passes static file reference, function parity, and Lua syntax checks. These checks cannot simulate Blizzard's complete UI/event environment; an in-game `/reload`, popup, settings-tab, and achievement interaction test is still required.

## Customizing settings appearance

In `Views/Settings/OptionsTheme.lua`, use `FF.OptionsTheme.COMMON` to adjust margins, text styles, gaps and common widget sizes across all settings tabs. `MAIN`, `DEFAULT`, `CUSTOM`, and `INFO` contain page-specific layout parameters. Individual tab files define which controls exist, while `OptionsWidgets.lua` defines the shared constructors. For example, `CUSTOM.FORM_X` adjusts the horizontal placement of custom-exercise editor fields without modifying `CustomExercisesTab.lua`.

### Previous 1.1.0 settings changelog

- Centralized the shared settings-page typography and geometry in `OptionsTheme.lua`.
- Centralized common Blizzard settings widget constructors in `OptionsWidgets.lua`.
- Consolidated shared settings-page styling while preserving page-specific exceptions.
- Left the existing workout behavior, statistics schema, and account-wide achievement tracking unchanged.

### This source reorganization

- Moved the single built-in exercise catalog and static achievement templates into `Data/`.
- Split runtime data management and achievement calculations across `Models/`.
- Separated game event coordination and settings registration into `Controllers/`.
- Renamed interface files around their actual tab and component responsibilities under `Views/`.
- Preserved original external `FF:` methods, achievement IDs, saved-variable keys, and the WoW load-order mechanism.
