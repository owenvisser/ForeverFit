# Forever Fit

**Version:** v1.1.0  
**Client:** World of Warcraft: Forever

Forever Fit is a World of Warcraft addon that reminds you to take short exercise breaks while adventuring in Azeroth. Complete real-life workout quests, track your sessions, and unlock WoW-themed **Fitness Challenges**—without prescribed repetition counts. You choose how much exercise is appropriate for you.

## Features

- **Workout reminders:** A configurable 10–60 minute timer, with optional reminders when boarding a flight-path taxi or gaining the Welcoming Campfire buff.
- **Exercise selection:** No Equipment, Free Weights, and Walking Pad categories. Enable or disable individual exercises and categories; the rotating selection avoids immediate repeats when multiple exercises are enabled, unless there is only one exercise choice.
- **Simple workout popup:** Exercise instructions, a Warcraft-themed quip, and **Completed** / **Skip** buttons. The popup can be previewed, moved, and resized in settings.
- **Custom exercises:** Create, edit, and disable your own workouts, including an **Other** category.
- **Statistics:** Track completed and skipped sessions, including per-character and per-level history. The addon also tracks account-wide totals used for Fitness Challenges.
- **Fitness Challenges:** General, exercise-specific, and milestone achievements. Built-in exercises have five progression tiers—Bronze, Silver, Gold, Platinum, and Diamond—based on completed sessions. Earn **Fitness Points** and view progress in the in-game achievement interface.
- **Achievement notifications:** Blizzard-style **Achievement Earned!** alerts with an icon, achievement name, and points shield. Multiple unlocks are queued and shown one at a time.
- **Optional social announcements:** Share workout breaks or invitations with party members, announce achievements in guild chat, and report workout totals on level-up. Achievement titles posted through Forever Fit can be opened by other players running the addon.
- **Optional sound effects:** Race-specific completion and skip sounds, with a Human Male Only override.

## Installation

ForeverFit is also available on **CurseForge** at the url **`https://www.curseforge.com/wow/addons/foreverfit`**

If downloading directly from GitHub:
1. Place the `ForeverFit` folder in your WoW client's `Interface/AddOns/` directory.
2. Verify that `ForeverFit.toc` is directly inside `ForeverFit/`.
3. Enable **Forever Fit** in the addon list and log in, or type `/reload`.

All statistics and achievement progress are stored in your `WTF/Account/.../SavedVariables/` files, so your data is saved unless you intentionally want to reset it.

## Getting started

Open the addon with `/ffit`. In the settings pages, choose a reminder interval, enable your preferred exercises, and configure optional taxi, campfire, sound, and social features. When a reminder appears, perform the workout at your preferred intensity and select **Completed** or **Skip**.

Use **Default Exercises** to choose built-in workouts, **Custom Exercises** to manage your own, and **View Fit Challenges** or `/ffit achievements` to inspect achievement progress.

## Slash commands

| Command | Action |
| --- | --- |
| `/ffit` or `/foreverfit` | Open settings |
| `/ffit test` | Show a test workout reminder without waiting for a trigger |
| `/ffit alerttest` | Preview the achievement notification without awarding progress |
| `/ffit stats` | Print workout statistics |
| `/ffit achievements` or `/ffit ach` | Open Fitness Challenges |
| `/ffit status` | Show reminder interval and exercise rotation status |
| `/ffit icons` | Check the built-in exercise and general-achievement icons |

Test workout reminders respect the normal login grace period and other workout restrictions. The achievement alert test does not unlock achievements or modify statistics.

## Settings and saved progress

- **General:** Reminder interval, triggers, sounds, guild/party announcements, popup layout preview, and character-statistics reset.
- **Default Exercises:** Built-in exercise categories and enable/disable choices.
- **Custom Exercises:** Personal exercise definitions and their inclusion in the rotation.
- **Info:** Addon information.

`ForeverFitDB` stores account-wide configuration and achievement progress. `ForeverFitCharDB` stores character-specific statistics and state, including popup layout. The **Reset Statistics** option resets the current character's workout records while preserving other characters' contributions to account-wide achievements.

## Project structure

```text
ForeverFit/
├── ForeverFit.toc
├── Core.lua
├── README.md
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
        ├── InfoTab.lua
        ├── OptionsTheme.lua
        └── OptionsWidgets.lua
```

`Data/` holds built-in content; `Models/` manages data and progression; `Controllers/` handles gameplay events and actions; and `Views/` draws the interface. `Core.lua` initializes the addon and registers slash commands. WoW loads Lua files in the order listed in `ForeverFit.toc`.

For development, edit workout text in `Data/Exercises.lua`, achievement names and thresholds in `Data/AchievementDefinitions.lua`, notification styling in `Views/AchievementAlertView.lua`, and shared settings spacing and typography in `Views/Settings/OptionsTheme.lua`. Preserve established exercise and achievement IDs to avoid breaking existing progress.

## Changelog

### v1.1.0

- Organized the addon into Data, Models, Controllers, and Views while retaining a single built-in exercise catalog.
- Renamed settings files by tab and centralized reusable settings appearance and widgets.
- Simplified workout instructions and custom exercise creation by removing prescribed repetition targets; continued tracking **completed sessions** rather than reps.
- Updated Welcoming Campfire reminders to block consecutive campfire triggers until another reminder source fires.
- Refined Fitness Challenges cards using Blizzard's Legacy Challenges artwork and added per-tier achievement icon support.
- Added classic-style achievement unlock alerts, including the achievement icon, name, points shield, sequential notification queue, and `/ffit alerttest`.
- Refined the achievement alert's native banner artwork, proportions, positioning, and shield number styling; removed the redundant “+1 Fitness Point” line.
- Preserved established account-wide achievement progress, character statistics, and existing workout settings.
