local _, FF = ...

-- Completed sessions per exercise; the native Legacy system remains unaffected.
FF.achievementTiers = {
    { name = "Bronze", target = 1, color = { 0.76, 0.47, 0.24 } },
    { name = "Silver", target = 10, color = { 0.72, 0.76, 0.81 } },
    { name = "Gold", target = 50, color = { 0.98, 0.77, 0.20 } },
    { name = "Platinum", target = 250, color = { 0.35, 0.85, 0.80 } },
    { name = "Diamond", target = 1000, color = { 0.55, 0.70, 1.0 } },
}

-- Five progressively more ridiculous titles per exercise.
FF.achievementNames = {
    pushups = { "Northshire Push-up Recruit", "Scarlet Monastery Press Corps", "Arms Like Anduin", "Mogging Thrall", "The Push-up Lich King" },
    wallpushups = { "Goldshire Wall Leaner", "Stormwind Wall Inspector", "Keeper of Hellfire Ramparts", "Blackrock Wall Brawler", "The Great Wall of Gilneas" },
    squats = { "Dun Morogh Squat Recruit", "Dwarven Leg Day", "Thunder Bluff Thunder Thighs", "Sargeras Skips Leg Day", "Titanforged Quads" },
    lunges = { "Lordaeron Lunge Recruit", "A Peon's First Step", "The Stride of Stratholme", "Lunging Through the Dark Portal", "Illidan's Unprepared Leg Day" },
    calfraises = { "Elwynn Tiptoe Apprentice", "Gadgetzan Calf Cartel", "Mount Hyjal High Heels", "Calves of the Old Gods", "Archimonde's Ankle Day" },
    jumpingjacks = { "Dun Morogh Jumping Recruit", "Gnomeregan Jump Jet", "Murloc Evasion Maneuver", "Leaper of the Dark Portal", "Jacked by the Light" },
    plank = { "Stormwind Floor Sentinel", "Darnassus Bridge Plank", "Shield Wall of Ironforge", "The Unmoving Blackrock", "The Plank King of Northrend" },
    curls = { "Goldshire Curl Initiate", "Biceps for the Horde", "Gains of Ironforge", "Thrall's Training Partner", "Swole of the Titans" },
    press = { "Stormwind Shoulder Squire", "Gryphon Rider Press", "Karazhan Overhead Overlord", "Pressing Sulfuras Skyward", "The Shoulders of Sargeras" },
    rows = { "Booty Bay Rowboat Rookie", "Pulling Aggro in Ragefire", "Oar Master of Booty Bay", "Tug-of-War with Deathwing", "Row, Row, Row Your Raid" },
    gobletsquats = { "Gadgetzan Goblet Goblin", "Squat and Loot in the Deadmines", "Ironforge Tavern's Strongest Legs", "The Goblet of the Old Gods", "The Squatfather of Stormwind" },
    laterals = { "Darnassus Little Wings", "Flight Form Apprentice", "Delts of the Argent Dawn", "Wings of the Val'kyr", "Shoulders of the Pantheon" },
    deadlifts = { "Elwynn Loot Lifter", "Ironforge Inventory Overweight", "Blackrock Epic Loot Hauler", "Azeroth's Moving Company", "Lifting the Dark Portal" },
    easywalk = { "First Steps in Elwynn", "Goldshire Stroller", "Road to Redridge", "Stormwind Footman of the Year", "The Eternal Wanderer of Azeroth" },
    briskwalk = { "Brisk Stormwind Recruit", "Outrunning a Murloc", "Boots of Minor Speed", "Strider of Stranglethorn", "Faster Than Your Hearthstone" },
    inclineeasy = { "Dun Morogh Hillwalker", "Climbing the Wetlands Pass", "Footman of Alterac", "Trailblazer of Mount Hyjal", "Summiting Icecrown on Foot" },
    inclinebrisk = { "Brisk Dun Morogh Climber", "Hustling up Thunder Bluff", "Race to Blackrock Spire", "Sprint to the Peaks of Hyjal", "Outrunning the Storm Peaks" },
    shrugs = { "Ironforge Trap Recruit", "Shoulders up for the King", "Traps of Blackrock", "Shrugging Off Deathwing", "The Titanforged Trapezius" },
    triceps = { "Silvermoon Triceps Initiate", "Triceps of the Scarlet Crusade", "Triceps for the Argent Tournament", "Elbows of the Naaru", "The Lich King's Overhead Lockout" },
}

-- General achievements include cumulative prescribed walking minutes and zero-point shame tiers.
FF.generalAchievements = {
    { id = "firstfit", name = "Quest Accepted: Leg Day", kind = "total", target = 1, points = 1,
      description = "Complete your first Forever Fit session.", icon = "Interface\\Icons\\Achievement_Quests_Completed_01" },
    { id = "fit100", name = "The Barrens Grind Is Real", kind = "total", target = 100, points = 1,
      description = "Complete 100 workouts.", icon = "Interface\\Icons\\Achievement_Quests_Completed_06" },
    { id = "fit1000", name = "No Rest XP", kind = "total", target = 1000, points = 1,
      description = "Complete 1,000 workouts.", icon = "Interface\\Icons\\Spell_Holy_Renew" },
    { id = "walk60", name = "Goldshire Is That Way", kind = "walking", target = 60, points = 1,
      description = "Complete 60 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
    { id = "walk600", name = "Walked the Barrens", kind = "walking", target = 600, points = 1,
      description = "Complete 600 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\INV_Boots_05" },
    { id = "walk6000", name = "The Long Walk to Silithus", kind = "walking", target = 6000, points = 1,
      description = "Complete 6,000 prescribed minutes of walking-pad sessions.", icon = "Interface\\Icons\\Ability_Rogue_Sprint" },
    { id = "skip5", name = "AFK in Orgrimmar", kind = "skipped", target = 5, points = 0,
      description = "Skip 5 workouts. The innkeeper is impressed.", icon = "Interface\\Icons\\INV_Misc_PocketWatch_01" },
    { id = "skip50", name = "Professional Stormwind Benchwarmer", kind = "skipped", target = 50, points = 0,
      description = "Skip 50 workouts. You have mastered the art of sitting.", icon = "Interface\\Icons\\INV_Misc_PocketWatch_02" },
    { id = "skip500", name = "Illidan Was Not Prepared for Leg Day", kind = "skipped", target = 500, points = 0,
      description = "Skip 500 workouts. A truly questionable feat of strength.", icon = "Interface\\Icons\\Ability_Rogue_FeignDeath" },
    { id = "inventor", name = "Gnomeregan Patent Pending", kind = "inventor", target = 1, points = 1, hidden = true,
      description = "Invent your first custom workout. The patent office has some questions.",
      icon = "Interface\\Icons\\INV_Gizmo_02" },
    { id = "cheater11", name = "The Forever Fit Cheater", kind = "cheater", target = 1, points = 0, hidden = true,
      description = "Even the Bronze Dragonflight doubts your rep speed!",
      icon = "Interface\\Icons\\Ability_Rogue_Sprint" },
}

-- Progression challenges count distinct exercise achievements within each track.
-- Any four bodyweight or free-weight exercises, or any two walking-pad exercises,
-- can satisfy a tier; the enabled-checkbox settings never alter achievement rules.
FF.milestoneTracks = {
    { group = "No Equipment", target = 4, icon = "Interface\\Icons\\Ability_Warrior_Charge" },
    { group = "Free Weights", target = 4, icon = "Interface\\Icons\\Ability_Warrior_StrengthOfArms" },
    { group = "Walking Pad", target = 2, icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
}

FF.otherAchievementNames = {
    "Goblin-Made Training Wheels", "Ogre-Approved Gym Routine",
    "Gnomeregan's Unlicensed Gym", "Bilgewater's Questionable Masterpiece",
}

FF.milestoneRanks = {
    { group = "Beginner", required = 1, names = {
        "Beginner Body Fitness", "Initiate Lifter", "The Road to Goldshire" } },
    { group = "Intermediate", required = 10, names = {
        "Stormwind Training Veteran", "Ironforge Iron-Pumper", "The Long Road Through Westfall" } },
    { group = "Expert", required = 50, names = {
        "Champion of the Argent Gym", "Swole of the Titans", "The Wanderer of Azeroth" } },
    { group = "Godly", required = 250, names = {
        "Might of the Titans", "Forged in Blackrock Mountain", "Walking with the Old Gods" } },
}
