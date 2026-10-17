# Forever Fit

**Version:** 1.1.1  
**Client:** World of Warcraft: Forever (Camelot)

Forever Fit is a Lua addon that prompts short real-world exercise breaks during WoW sessions. Players choose which workouts to include, respond **Completed** or **Skip** to reminders, review session statistics, and unlock account-wide **Fitness Challenges**. It tracks sessions rather than repetitions or weights.

## Features

- **Reminder sources:** Configurable 10–60-minute timer, optional flight-path taxi detection, and the Welcoming Campfire buff. Campfire reminders cannot trigger consecutively; another trigger resets eligibility.
- **Exercise catalog:** No Equipment, Free Weights, and Walking Pad workouts in one data file, plus user-defined custom exercises.
- **Workout UI:** Movable, resizable popup with instructions, WoW-themed quips, Completed/Skip actions, and optional sounds.
- **Achievements:** Account-wide general, exercise-tier, milestone, and hidden Fitness Challenges. Blizzard-style achievement alerts queue sequentially; clicking an alert opens the relevant achievement.
- **Statistics:** Per-character, per-level, and account-wide progress. The Statistics tab groups exercises by category and retains the history of deleted custom exercises.
- **Settings and social features:** Individual exercise controls, party/guild announcements, level-up summaries, and a confirmed account-wide statistics-and-achievements reset.

## Install

1. Copy `ForeverFit/` into your WoW client's `Interface/AddOns/` directory.
2. Check that `ForeverFit.toc` is directly inside that folder.
3. Enable **Forever Fit** in the addon list, log in, and use `/ffit` for settings.

Back up the relevant `WTF/Account/.../SavedVariables/` data before upgrading or testing resets. No third-party Lua libraries or additional addons are required by the packaged source.

## Commands

| Command | Action |
| --- | --- |
| `/ffit` or `/foreverfit` | Open settings |
| `/ffit test` | Queue a test workout reminder (normal restrictions apply) |
| `/ffit alerttest` | Preview an achievement alert without awarding progress |
| `/ffit stats` | Print workout statistics to chat |
| `/ffit achievements` or `/ffit ach` | Open Fitness Challenges |
| `/ffit status` | Show reminder and rotation status |
| `/ffit icons` | Check built-in exercise and general-achievement icon references |

## Project structure

```text
ForeverFit/
├── ForeverFit.toc
├── Core.lua
├── Data/
│   ├── Exercises.lua
│   └── AchievementDefinitions.lua
├── Models/
│   ├── DatabaseModel.lua
│   ├── ExerciseModel.lua
│   ├── AchievementModel.lua
│   └── StatisticsModel.lua
├── Controllers/
│   ├── WorkoutController.lua
│   ├── AchievementController.lua
│   └── SettingsController.lua
└── Views/
    ├── PopupView.lua
    ├── AchievementsView.lua
    ├── AchievementAlertView.lua
    └── Settings/
        ├── GeneralTab.lua
        ├── DefaultExercisesTab.lua
        ├── CustomExercisesTab.lua
        ├── StatisticsTab.lua
        ├── InfoTab.lua
        ├── OptionsTheme.lua
        └── OptionsWidgets.lua
```

**Data** defines bundled exercises and achievement metadata. **Models** own exercise selection, saved data, statistics, and progression. **Controllers** coordinate WoW events and actions. **Views** implement popups, achievement UI, and settings pages. `Core.lua` initializes the addon and registers slash commands; `ForeverFit.toc` controls file load order.

## Working on Forever Fit

- **Edit exercises or quips:** `Data/Exercises.lua`
- **Edit achievement definitions/tiers:** `Data/AchievementDefinitions.lua`
- **Change reminder behavior:** `Controllers/WorkoutController.lua`
- **Change achievement awards:** `Controllers/AchievementController.lua`
- **Change alert styling:** `Views/AchievementAlertView.lua`
- **Change settings layouts:** `Views/Settings/` (`OptionsTheme.lua` and `OptionsWidgets.lua` hold shared styling/widgets)
- **Change recorded statistics:** `Models/StatisticsModel.lua` and `Models/DatabaseModel.lua`

The addon uses Blizzard's frame and Settings APIs, Lua event callbacks, and timers; there is no build step. Keep exercise IDs and achievement IDs stable when updating content because they are referenced by saved progress. If adding Lua files, include them in `ForeverFit.toc` in dependency order.

### Saved data

`ForeverFitDB` holds account-wide configuration and achievement progress. `ForeverFitCharDB` holds character-specific history and state. Deleted custom workouts retain historical statistics. The **Reset Everything** action on the Statistics tab clears workout and achievement history across the account, including offline characters when they next log in; it preserves configuration and custom exercise definitions.

## Changelog

### v1.3.0

- Added custom icons to all exercises.
- Revised quips on all exercises.
- Adjusted popup for exercises to be more customizable in size.

### v1.2.0

- Added a category-grouped **Statistics** tab with completed, skipped, and total sessions; preserved history for deleted custom exercises.
- Fixed Walking Pad achievements progressing from unrelated workouts, including correction of affected saved progress.
- Made achievement alerts clickable, opening the exact achievement earned.
- Moved reset to Statistics and extended it to account-wide workout, achievement, and Cheater history, with `RESET ALL` confirmation.
- Made Cheater Apology controls visible only while Cheater status is active.

### v1.1.0

- Reorganized the addon into Data / Models / Controllers / Views.
- Kept workout progression session-based rather than prescribing repetitions.
- Added and refined Blizzard-style achievement alerts, sequential notifications, and `/ffit alerttest`.
- Refined Legacy Challenges styling and consecutive campfire-trigger behavior.
