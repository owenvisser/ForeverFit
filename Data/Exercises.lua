local _, FF = ...

-- Icons are placeholders until original exercise instruction images are added.
FF.exercises = {
  {
    id = "squats",
    group = "No Equipment",
    name = "Bodyweight Squats",
    icon = "Interface\\Icons\\Ability_Warrior_Charge",
    instructions = "Feet shoulder-width apart. Sit your hips back and down, then stand tall. Keep your heels grounded.",
    quip = "It might be hard now, but you'll be able to carry more loot later."
  },
  {
    id = "calfraises",
    group = "No Equipment",
    name = "Calf Raises",
    icon = "Interface\\Icons\\Ability_Hunter_Pathfinding",
    instructions =
    "Stand tall, rise onto the balls of your feet, pause briefly, and lower your heels slowly. For added challenge, add incline to your toes.",
    quip = "Why do you think Cairnes calves are so big?"
  },
  {
    id = "plank",
    group = "No Equipment",
    name = "Forearm Plank",
    icon = "Interface\\Icons\\Ability_Warrior_ShieldWall",
    instructions =
    "Support yourself on forearms and toes, with shoulders over elbows. Keep your trunk braced without sagging.",
    quip = "Without a few planks, that Barbaric Harness wouldn't look nearly as good."
  },
  {
    id = "jumpingjacks",
    group = "No Equipment",
    name = "Jumping Jacks",
    icon = "Interface\\Icons\\Spell_Nature_Lightning",
    instructions =
    "Jump your feet apart as your arms rise overhead, then return to start. Step side-to-side for a low-impact option.",
    quip = "Valeera Sanguinar didn't get that nimble by standing in stealth all day."
  },
  {
    id = "pushups",
    group = "No Equipment",
    name = "Push-ups",
    icon = "Interface\\Icons\\Ability_Warrior_StrengthOfArms",
    instructions =
    "Hands beneath shoulders, body straight. Lower your chest with control, pause, then press upward.",
    quip = "The Scarlet Crusade isn't going to push itself back!"
  },
  {
    id = "lunges",
    group = "No Equipment",
    name = "Reverse Lunges",
    icon = "Interface\\Icons\\Ability_Rogue_Sprint",
    instructions =
    "Step one foot back, lower with control, then return to standing; repeat for both legs. Hold a chair for balance if needed.",
    quip = "For the Horde! And for healthier knees."
  },
  {
    id = "wallpushups",
    group = "No Equipment",
    name = "Wall Push-ups",
    icon = "Interface\\Icons\\Ability_Warrior_DefensiveStance",
    instructions =
    "Stand an arm's length from a wall. Bend your elbows to lean in, then push back while keeping your body aligned.",
    quip = "Every build starts out with a strong foundation."
  },
  {
    id = "curls",
    group = "Free Weights",
    name = "Dumbbell Curls",
    icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
    instructions =
    "Keep elbows at your sides. Lift the dumbbells toward your shoulders, then lower slowly.",
    quip = "You don't swing hammers like King Magni Bronzebeard without putting in a few curls."
  },
  {
    id = "deadlifts",
    group = "Free Weights",
    name = "Dumbbell Deadlifts",
    icon = "Interface\\Icons\\Ability_Warrior_ColossusSmash",
    instructions =
    "With dumbbells at your sides, push hips back, keep your back neutral, and stand by driving through your feet.",
    quip = "Picking up epic loot is a full-body workout."
  },
  {
    id = "gobletsquats",
    group = "Free Weights",
    name = "Goblet Squats",
    icon = "Interface\\Icons\\Ability_Warrior_Charge",
    instructions =
    "Hold one light dumbbell at your chest. Squat down with heels planted, then stand, keeping your chest lifted.",
    quip = "This is what happens when you loot too much plate armor."
  },
  {
    id = "laterals",
    group = "Free Weights",
    name = "Lateral Raises",
    icon = "Interface\\Icons\\Ability_Druid_FlightForm",
    instructions =
    "With light dumbbells and soft elbows, lift arms to shoulder level out to your sides, then lower slowly.",
    quip = "Spread your wings. Unfortunately, flying is still locked."
  },
  {
    id = "rows",
    group = "Free Weights",
    name = "One-arm Dumbbell Rows",
    icon = "Interface\\Icons\\Ability_Hunter_MarkedForDeath",
    instructions =
    "Brace one hand on a stable surface. Hinge at the hips and pull a dumbbell toward your hip, then lower.",
    quip = "Pull harder! That raid isn't going to carry itself."
  },
  {
    id = "triceps",
    group = "Free Weights",
    name = "Overhead Triceps Extensions",
    icon = "Interface\\Icons\\Ability_Warrior_TitansGrip",
    instructions =
    "Hold one light dumbbell securely overhead with both hands. Bend your elbows slowly behind your head, then extend them. Keep upper arms steady.",
    quip = "The Light demands stronger triceps, champion!"
  },
  {
    id = "press",
    group = "Free Weights",
    name = "Shoulder Press",
    icon = "Interface\\Icons\\Ability_Warrior_TitansGrip",
    instructions =
    "From shoulder height, press light dumbbells overhead without arching your lower back. Lower with control.",
    quip =
    "Believe it or not, there's no room between Varian Wrynn's shoulders and those massive pauldrons. Keep pressing!"
  },
  {
    id = "shrugs",
    group = "Free Weights",
    name = "Shoulder Shrugs",
    icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
    instructions =
    "With light dumbbells at your sides, lift both shoulders toward your ears, pause, then lower without rolling them.",
    quip = "Raise those traps like you just spotted Onyxia!"
  },
  {
    id = "easywalk",
    group = "Walking Pad",
    name = "Easy Walk",
    icon = "Interface\\Icons\\Inv_Pet_Speedy",
    instructions =
    "Turn on your walking pad and walk at a comfortable pace. Keep your gaze forward and use the walking pad's safety features if necessary.",
    quip = "Just press W."
  },
  {
    id = "briskwalk",
    group = "Walking Pad",
    name = "Brisk Walk",
    icon = "Interface\\Icons\\Warrior_talent_icon_Skirmisher",
    instructions =
    "Turn on your walking pad and walk at a pace that feels fast but still controlled. Do not run or overreach your stride.",
    quip = "Pretend you're PirateSoftware in Dire Maul."
  },
  {
    id = "inclineeasy",
    group = "Walking Pad",
    name = "Easy Incline Walk",
    icon = "Interface\\Icons\\Achievement_Zone_RedridgeMountains",
    instructions =
    "If your walking pad supports incline, choose a gentle setting and walk at a comfortable pace. Hold a natural upright posture.",
    quip = "On the way to the icy mountains of dun morough, taking in the view."
  },
  {
    id = "inclinebrisk",
    group = "Walking Pad",
    name = "Brisk Incline Walk",
    icon = "Interface\\Icons\\Warrior_talent_icon_Blitz",
    instructions =
    "If your walking pad supports incline, choose a manageable incline and brisk walk for five minutes. Reduce speed or incline if needed.",
    quip = "Brave the climb to Mount Hyjal, hero!"
  },
}
