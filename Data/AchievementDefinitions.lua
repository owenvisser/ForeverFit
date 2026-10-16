local _, FF = ...

-- Completed sessions per exercise; the native Legacy system remains unaffected.
FF.achievementTiers = {
  { name = "Bronze",   target = 1,    color = { 0.76, 0.47, 0.24 } },
  { name = "Silver",   target = 10,   color = { 0.72, 0.76, 0.81 } },
  { name = "Gold",     target = 50,   color = { 0.98, 0.77, 0.20 } },
  { name = "Platinum", target = 100,  color = { 0.35, 0.85, 0.80 } },
  { name = "Diamond",  target = 1000, color = { 0.55, 0.70, 1.0 } },
}

-- Five progressively more ridiculous titles per exercise.
FF.achievementNames = {
  pushups = {
    "The Lights Leanest Recruit",
    "Scarlet Crusade Chest Day",
    "Varian's Sword Won't Swing itself",
    "Orgrim's Bench Rival",
    "The Undying Press Of Icecrown"
  },
  wallpushups = {
    "Defais Wall Leaner",
    "Westfall Fence Presser",
    "Jaina's Vertical Form",
    "Sylvanas' Undercity Scrubbin' Upkeep",
    "I Prefer Standing, The Floor Is Gross"
  },
  squats = {
    "Dun Morogh Squat Initiate",
    "Magni's Mourning Routine",
    "Loch Modan Leg Day",
    "Cairne's Squat Rival",
    "Moving The Weight Of The Titans"
  },
  lunges = {
    "Redridge Guard Warm-up",
    "How Do You Space Your Totems?",
    "The Path Of Tears",
    "Velen's Forward, Then Backward, Step",
    "I Get Down, Just To Get Back Up"
  },
  calfraises = {
    "Baby Kodo's First Hill",
    "Dun Morogh G.O.A.T.",
    "Tyrande's High Heels",
    "That's Why Tauren Have Hooves",
    "The Eternal Walk Of The Elder Celfthoof"
  },
  jumpingjacks = {
    "Goblin Jump Recruit",
    "Wetlands Hop Squad",
    "Why Are They Moving Like That?",
    "The Mage Shuffle",
    "Like A Fire Dancer"
  },
  plank = {
    "I Haven't Done This Since Early Leveling",
    "Why Am I Doing This Again?",
    "It Hurts",
    "It's Becoming More Boring By The Minute",
    "The Pain Flows Through Me"
  },
  curls = {
    "The Beginnings Of A Mighty Arm",
    "With Discipline Comes Strength",
    "That's why Nazgrel Has Those Guns",
    "Saurfang's 100 Swings A Day",
    "Too Big For Armor"
  },
  press = {
    "Padding Your Pauldrons",
    "Do Fireballs Weigh A Lot?",
    "The Bananas Are In The Trees",
    "The Strength Of A Fel Orc",
    "Holding Up The Beacon",
  },
  rows = {
    "Booty Bay Rower",
    "The Blackwater Raiders' Finest Deckhand",
    "Those Who Fire Bows, Row",
    "Engine Ironclad",
    "Don't Let Jaina Say She Drives It Herself",
  },
  gobletsquats = {
    "The Kids Need Somewhere To Sit",
    "Whoops, Dropped My Whetstones!",
    "I Have To Pick Up The What Again?",
    "It's Always Stones In This Game",
    "The Crystals Do Weigh A Lot, Actually"
  },
  laterals = {
    "Haha, You Look Like A Macaw",
    "Now You're Flapping With Some Gusto",
    "Imagine If You Had To Do This With Four Arms",
    "No, I Won't Let You Hold It While I Whirlwind",
    "I Don't Fit Through The Gate"
  },
  deadlifts = {
    "Picking It Up For The First Time",
    "I Have To Get It Out Of The Ground?",
    "Someone's Gotta Carry The Ore",
    "The Azerothian Mover",
    "He Carried All The Corpses Himself",
  },
  easywalk = {
    "Speedy's Walking Buddy",
    "Escaping The Grimtotem, Eventually...",
    "Chicken Walker",
    "Tanaris' Chauffeur",
    "All That, For This? Thanks, I Guess",
  },
  briskwalk = {
    "Redridge Runner",
    "Speedwalking Away From Patches",
    "Shaman Shuffle",
    "Don't Get Dazed",
    "Bring A Friend, You're Walking A Lot"
  },
  inclineeasy = {
    "Dun Morogh Hill Surveyor",
    "Striding Through Arathi Pass",
    "Falstad's Messenger",
    "Sauntering To The Peaks Of Alterac",
    "Walking To Hyjal",
  },
  inclinebrisk = {
    "Hill Runner",
    "Stonetalon Strut",
    "Fire Totem Quest Enjoyer",
    "Most People Would Take The Lift",
    "A True Mountaineer"
  },
  shrugs = {
    "Even Mages Lift Their Staves",
    "Shields Up!",
    "The Conviction To Shrug",
    "Neck Thicker Than Garrosh",
    "Gruul Look-A-Like"
  },
  triceps = {
    "Learning To Punch With Force",
    "Armour Breaker",
    "Lor'themar's Extension Form",
    "Kael'thas' Overhead Rival",
    "Pushing Down The Doors To Uldaman"
  },
}

-- Unique achievement icons for each exercise tier.
-- Order: Bronze, Silver, Gold, Platinum, Diamond.
FF.achievementIcons = {
  pushups = {
    "Interface\\Icons\\Ability_Paladin_LongArmoftheLaw.blp",
    "Interface\\Icons\\ability_rogue_recuperate.blp",
    "Interface\\Icons\\INV_Sword_2H_GladiatorShalamayne_C_01.blp",
    "Interface\\Icons\\INV_Armor_Orc_D_01_Chest.blp",
    "Interface\\Icons\\Achievement_Boss_LichKing.blp",
  },
  wallpushups = {
    "Interface\\Icons\\INV_Helm_Armor_BanditMask_C_01.blp",
    "Interface\\Icons\\INV_HarvestGolemPet.blp",
    "Interface\\Icons\\Achievement_Boss_Zuldazar_Jaina.blp",
    "Interface\\Icons\\Achievement_Leader_Sylvanas.blp",
    "Interface\\Icons\\Spell_Nature_Acid_01.blp",
  },
  squats = {
    "Interface\\Icons\\INV_Shield_1H_Ironforge_C_01.blp",
    "Interface\\Icons\\Achievement_Leader_King_Magni_Bronzebeard.blp",
    "Interface\\Icons\\Achievement_Character_Dwarf_Male.blp",
    "Interface\\Icons\\Achievement_Character_Tauren_Male.blp",
    "Interface\\Icons\\Achievement_Dungeon_UlduarRaid_Titan_01.blp",
  },
  lunges = {
    "Interface\\Icons\\Warrior_talent_icon_Deadlycalm.blp",
    "Interface\\Icons\\Spell_Totem_WardOfDraining.blp",
    "Interface\\Icons\\Achievement_Character_Draenei_Female.blp",
    "Interface\\Icons\\Achievement_Leader_Prophet_Velen.blp",
    "Interface\\Icons\\Spell_Holy_Resurrection.blp",
  },
  calfraises = {
    "Interface\\Icons\\Inv_misc_trinket6oIH_clefthoof2.blp",
    "Interface\\Icons\\INV_Pet_ Goat.blp",
    "Interface\\Icons\\Achievement_Leader_Tyrande_Whisperwind.blp",
    "Interface\\Icons\\INV_Blacksmithing_hoofplate.blp",
    "Interface\\Icons\\INV_ClefthoofDraenorMount_Purple.blp",
  },
  jumpingjacks = {
    "Interface\\Icons\\Ability_Racial_RocketJump.blp",
    "Interface\\Icons\\INV_Misc_Head_Gnoll_01.blp",
    "Interface\\Icons\\INV_Misc_Head_Gnome_01.blp",
    "Interface\\Icons\\Spell_Mage_IceFlows.blp",
    "Interface\\Icons\\INV_Misc_FireDancer_01.blp",
  },
  plank = {
    "Interface\\Icons\\Ability_Priest_HeavanlyVoice.blp",
    "Interface\\Icons\\Ability_Priest_Thoughtsteal01.blp",
    "Interface\\Icons\\Ability_Butcher_Exsanguination.blp",
    "Interface\\Icons\\Ability_Priest_Darkness.blp",
    "Interface\\Icons\\Ability_Revendreth_Priest.blp",
  },
  curls = {
    "Interface\\Icons\\Ability_Priest_InnerLightandShadow.blp",
    "Interface\\Icons\\Spell_Nature_Strength.blp",
    "Interface\\Icons\\Ability_Warrior_StrengthOfArms.blp",
    "Interface\\Icons\\INV_Axe_10.blp",
    "Interface\\Icons\\Achievement_BG_most_damage_killingblow_dieleast.blp",
  },
  press = {
    "Interface\\Icons\\INV_Armor_LoGosh_C_01_Shoulder.blp",
    "Interface\\Icons\\Ability_Mage_FieryPayback.blp",
    "Interface\\Icons\\Ability_Hunter_Pet_Gorilla.blp",
    "Interface\\Icons\\Ability_BossFelMagnaron_HandEmpowered.blp",
    "Interface\\Icons\\Ability_Paladin_BeaconofLight.blp",
  },
  rows = {
    "Interface\\Icons\\Ships_ABILITY_BoardingPartyALLIANCE.blp",
    "Interface\\Icons\\Ships_ABILITY_BoardingParty.blp",
    "Interface\\Icons\\Ability_Hunter_ZenArchery.blp",
    "Interface\\Icons\\INV_ShipMount.blp",
    "Interface\\Icons\\INV_Garrison_Cargoship.blp",
  },
  gobletsquats = {
    "Interface\\Icons\\Shaman_PVP_RockShield.blp",
    "Interface\\Icons\\INV_Stone_WeightStone_01.blp",
    "Interface\\Icons\\INV_Stone_13.blp",
    "Interface\\Icons\\INV_Stone_03.blp",
    "Interface\\Icons\\INV_Misc_QirajiCrystal_02.blp",
  },
  laterals = {
    "Interface\\Icons\\INV_Misc_Birdbeck_01.blp",
    "Interface\\Icons\\Ability_Hunter_Pet_Vulture.blp",
    "Interface\\Icons\\Spell_Shadow_SummonFelGuard.blp",
    "Interface\\Icons\\Ability_Whirlwind.blp",
    "Interface\\Icons\\Achievement_Zone_Blackrock_01.blp",
  },
  deadlifts = {
    "Interface\\Icons\\Spell_Nature_Earthquake.blp",
    "Interface\\Icons\\INV_Misc_Profession_Book_Mining.blp",
    "Interface\\Icons\\Trade_Mining.blp",
    "Interface\\Icons\\INV_Crate_04.blp",
    "Interface\\Icons\\Achievement_Boss_Nefarion.blp",
  },
  easywalk = {
    "Interface\\Icons\\Inv_Pet_Speedy.blp",
    "Interface\\Icons\\Achievement_Character_Tauren_Female.blp",
    "Interface\\Icons\\INV_Pet_MechanicalChicken.blp",
    "Interface\\Icons\\Ability_Hunter_Pet_Turtle.blp",
    "Interface\\Icons\\INV_Ore_Arcanite_02.blp",
  },
  briskwalk = {
    "Interface\\Icons\\Ability_Warrior_Charge.blp",
    "Interface\\Icons\\Achievement_Boss_patchwerk.blp",
    "Interface\\Icons\\spell_Shaman_spiritwalkersgrace.blp",
    "Interface\\Icons\\Ability_Mount_JungleTiger.blp",
    "Interface\\Icons\\Ability_Mount_WhiteTiger.blp",
  },
  inclineeasy = {
    "Interface\\Icons\\Achievement_Zone_DunMorogh.blp",
    "Interface\\Icons\\Achievement_Zone_ArathiHighlands_01.blp",
    "Interface\\Icons\\Achievement_Zone_Hinterlands_01.blp",
    "Interface\\Icons\\Achievement_Zone_AlteracMountains_01.blp",
    "Interface\\Icons\\Achievement_Zone_Mount Hyjal.blp",
  },
  inclinebrisk = {
    "Interface\\Icons\\Ability_Mount_MountainRam.blp",
    "Interface\\Icons\\Achievement_Zone_Stonetalon_01.blp",
    "Interface\\Icons\\Spell_Fire_SearingTotem.blp",
    "Interface\\Icons\\Spell_Arcane_TeleportThunderBluff.blp",
    "Interface\\Icons\\Ability_Racial_Mountaineer.blp",
  },
  shrugs = {
    "Interface\\Icons\\ability_mage_GreaterInvisibility.blp",
    "Interface\\Icons\\Ability_Warrior_ShieldGuard.blp",
    "Interface\\Icons\\Ability_Paladin_Conviction.blp",
    "Interface\\Icons\\Ability_Garrosh_Hellscreams_Warsong.blp",
    "Interface\\Icons\\Achievement_Boss_GruulTheDragonkiller.blp",
  },
  triceps = {
    "Interface\\Icons\\Ability_Warrior_SecondWind.blp",
    "Interface\\Icons\\Ability_Warrior_Devastate.blp",
    "Interface\\Icons\\Achievement_Leader_Lorthemar_Theron .blp",
    "Interface\\Icons\\Ability_Warrior_TitansGrip",
    "Interface\\Icons\\Achievement_Dungeon_Uldaman.blp",
  },
}

-- General achievements include cumulative prescribed walking minutes and zero-point shame tiers.
FF.generalAchievements = {
  {
    id = "firstfit",
    name = "Starting Off Strong",
    kind = "total",
    target = 1,
    points = 1,
    description = "Complete your first Forever Fit session.",
    icon = "Interface\\Icons\\INV_BoastfulGruntling_HD.blp"
  },
  {
    id = "fit100",
    name = "Putting In The Work",
    kind = "total",
    target = 100,
    points = 1,
    description = "Complete 100 workouts. Keep going, you can do it!",
    icon = "Interface\\Icons\\ability_rogue_sturdyrecuperate.blp"
  },
  {
    id = "fit1000",
    name = "The Grind Is Real, But So Are The Gains",
    kind = "total",
    target = 1000,
    points = 1,
    description = "Complete 1,000 workouts. A Mighty Adventurer.",
    icon = "Interface\\Icons\\Ability_Socererking_arcanefortification.blp"
  },
  {
    id = "fit10000",
    name = "Mogging Azeroth",
    kind = "total",
    target = 10000,
    points = 1,
    description = "Complete 10,000 workouts. You look and act like a fitness legend.",
    icon = "Interface\\Icons\\Ability_Warrior_IntensifyRage.blp"
  },
  {
    id = "walk60",
    name = "Out Of The Starting Zone",
    kind = "walking",
    target = 10,
    points = 1,
    description = "Complete 1 session on the walking-pad.",
    icon = "Interface\\Icons\\Achievement_Zone_ElwynnForest.blp"
  },
  {
    id = "walk600",
    name = "Traversing The Barrens",
    kind = "walking",
    target = 100,
    points = 1,
    description = "Complete 100 sessions on the walking-pad.",
    icon = "Interface\\Icons\\Achievement_Zone_Barrens_01.blp"
  },
  {
    id = "walk6000",
    name = "World of Walk-craft",
    kind = "walking",
    target = 1000,
    points = 1,
    description = "Complete 1,000 sessions on the walking-pad.",
    icon = "Interface\\Icons\\Ability_Rogue_FleetFooted.blp"
  },
  { -- done
    id = "skip5",
    name = "It's The Thought That Counts",
    kind = "skipped",
    target = 5,
    points = 1,
    description = "Skip 5 workouts. Why did I download this addon again?",
    icon = "Interface\\Icons\\INV_Misc_PocketWatch_01.blp"
  },
  { -- done
    id = "skip50",
    name = "Professional Benchwarmer",
    kind = "skipped",
    target = 50,
    points = 1,
    description = "Skip 50 workouts. You have mastered the art of sitting.",
    icon = "Interface\\Icons\\INV_FISHINGCHAIR.BLP"
  },
  {
    id = "skip500",
    name = "How The Not-So-Mighty Have Fallen",
    kind = "skipped",
    target = 500,
    points = 1,
    description = "Skip 500 workouts. A truly questionable feat of strength.",
    icon = "Interface\\Icons\\Spell_Nature_NatureTouchDecay.blp"
  },
  {
    id = "inventor",
    name = "Patent Pending",
    kind = "inventor",
    target = 1,
    points = 1,
    hidden = true,
    description = "Invent your first custom workout. The patent office has some questions.",
    icon = "Interface\\Icons\\INV_Gizmo_02"
  },
  {
    id = "cheater11",
    name = "The Forever Fit Cheater",
    kind = "cheater",
    target = 1,
    points = 0,
    hidden = true,
    description = "Even the Bronze Dragonflight doubts your rep speed!",
    icon = "Interface\\Icons\\Achievement_Halloween_Smiley_01"
  },
}

-- Progression challenges count distinct exercise achievements within each track.
-- Any four bodyweight or free-weight exercises, or any two walking-pad exercises,
-- can satisfy a tier; the enabled-checkbox settings never alter achievement rules.
FF.milestoneTracks = {
  { group = "No Equipment", target = 4, icon = "Interface\\Icons\\Ability_Warrior_Charge" },
  { group = "Free Weights", target = 4, icon = "Interface\\Icons\\Ability_Warrior_StrengthOfArms" },
  { group = "Walking Pad",  target = 2, icon = "Interface\\Icons\\Ability_Hunter_Pathfinding" },
}

FF.otherAchievementNames = {
  "Goblin-Made Training Wheels", "Ogre-Approved Gym Routine",
  "Gnomeregan's Unlicensed Gym", "Bilgewater's Questionable Masterpiece",
}

FF.milestoneRanks = {
  {
    group = "Beginner",
    required = 1,
    names = {
      "Beginning Body Fitness",
      "Initiate Of Lifting",
      "The Road To Goldshire",
    },
    icons = {
      "Interface\\Icons\\Spell_Priest_VowofUnity.blp",
      "Interface\\Icons\\Ability_Paladin_BlessedMending.blp",
      "Interface\\Icons\\ACHIEVEMENT_GUILDPERK_HASTYHEARTH.BLP",
    },
    otherIcon = "Interface\\Icons\\INV_Misc_Note_01",
  },
  {
    group = "Intermediate",
    required = 10,
    names = {
      "Hardy",
      "The Blessing Of Might",
      "Traversing The Zones",
    },
    icons = {
      "Interface\\Icons\\Ability_PVP_Hardiness.blp",
      "Interface\\Icons\\Spell_Holy_FistOfJustice.blp",
      "Interface\\Icons\\Ability_Monk_TigersLust.blp",
    },
    otherIcon = "Interface\\Icons\\INV_Misc_Note_01",
  },
  {
    group = "Expert",
    required = 50,
    names = {
      "Pysical Atonement",
      "Forging Fitness",
      "Keeping Up With The Rogues",
    },
    icons = {
      "Interface\\Icons\\Ability_Priest_Atonement.blp",
      "Interface\\Icons\\Ability_Racial_MassProduction.blp",
      "Interface\\Icons\\Ability_Rogue_Sprint.blp",
    },
    otherIcon = "Interface\\Icons\\INV_Misc_Note_01",
  },
  {
    group = "Godly",
    required = 10,
    names = {
      "Bajheera's Disciple",
      "Zyzz Would Be Proud",
      "Lance Walks And So Do I",
    },
    icons = {
      "Interface\\Icons\\Ability_Ardenweald_Priest.blp",
      "Interface\\Icons\\Ability_Paladin_SelflessHealer.blp",
      "Interface\\Icons\\Rogue_BurstofSpeed.blp",
    },
    otherIcon = "Interface\\Icons\\INV_Misc_Note_01",
  },
}
