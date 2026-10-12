# Forever Fit v1.0

Forever Fit is a World of Warcraft: Forever addon that turns quiet moments between quests into short exercise reminders. Configure the workout interval, choose built-in or custom exercises, and earn fitness achievements through the game's Legacy Challenges interface.

Every hero can exercise in a way that works for them. Whether you lift like an orc, stroll like a tauren, or stretch between raids, small movements count too. No legendary equipment is required to take your next step!

## Installation

Extract the `ForeverFit` folder to your game's `Interface/AddOns` directory and run `/reload`. The addon uses WoW SavedVariables in the `WTF` directory, so replacing the addon files does not reset your settings, custom exercises, or workout history.

## Settings

Find **Forever Fit** under **Options → AddOns**:

- **Forever Fit** — reminder interval, party/guild announcements, sounds, achievement shortcut, popup layout preview, statistics reset, and Cheater apology.
- **Default Exercises** — built-in workouts, individual checkboxes, and category controls.
- **Custom Exercises** — create, edit, enable, or remove personal workouts, including the Other category.
- **Info** — description and update history.

Optional Welcoming Campfire reminders fire once when the buff (spell 1229739) is newly gained. All reminders are blocked for five minutes after login or `/reload`. Achievements and Fitness Points accumulate across characters, with existing character histories imported once per character at their next login. Per-character level histories and popup layouts stay separate. The Cheater lockout is account-wide; its apology clears the shared penalty. Reset Statistics resets only the current character's contribution to shared progress.

The four settings pages use separate, top-of-file layout variables (`SHORT_LINE_SKIP`, `BIG_LINE_SKIP`, and other page-specific spacing constants) and a `y` cursor for vertical positioning. Edit those local values to adjust each page independently without changing its behavior.

Use `/ffit stats` for exercise totals and `/ffit achievements` to open Fitness Challenges. The addon continues to use the existing SavedVariables and progression system. Report Lua errors with the full message and client build in the CurseForge project comments.

The **Preview / Move / Resize** button on the main settings page opens an editable sample workout popup. Only this preview can be dragged or resized (minimum 350×200 UI units); actual workout reminders are fixed in place with no resize handle. Instructions appear to the right of the exercise icon, below the target. Position and size are saved separately for each character in `ForeverFitCharDB`. The preview never counts as a completed or skipped workout. **Reset Popup Layout** restores the original position and size without affecting workout history.

## Changelog

- **v1.0** — Released in current state
- **v0.1.31** — Added optional campfire reminders, a five-minute login grace period, and account-wide achievement progress.
- **v0.1.30** — Fixed a login Lua error with custom exercises while registering achievement chat links; saved exercise data remains unchanged.

- **v0.1.29** — Set the popup minimum to 350×200; matched cheer/chicken sounds to the character's Classic race and gender; added a Human Male Only sound override that is disabled whenever sound is muted.

- **v0.1.28** — Placed workout instructions beside the icon and below the goal; limited moving and resizing to the settings preview.

- **v0.1.27** — Added a draggable, resizable workout popup preview and persistent per-character window layout.

- **v0.1.26** — Rebuilt settings layouts around independent vertical spacing variables and simplified Info to a description, encouragement, and changelog.
- **v0.1.25** — Added separate Default Exercises, Custom Exercises, and Info settings pages.
- **v0.1.24** — Fixed nil-checkbox errors when returning from custom exercise editing.
- **v0.1.23** — Added custom exercise creation, Other achievements, and a Cheater apology.
- **v0.1.22** — Played built-in cheer and chicken voice clips for workout actions.
- **v0.1.21** — Allowed zero enabled exercises, pausing reminders until one is selected.
- **v0.1.20** — Introduced flexible progression criteria and updated settings navigation.
- **v0.1.18** — Added flight-path workout breaks, category controls, and Cheater lockout.
- **v0.1.16** — Linked exercise tier achievements to overall milestone challenges.
- **v0.1.13** — Added achievement tooltips, earned dates, and icon fixes.

