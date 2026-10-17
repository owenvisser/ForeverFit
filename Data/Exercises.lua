local _, FF = ...
local ICON_PATH = "Interface\\AddOns\\ForeverFit\\Data\\FF_Exercise_Icons\\"

-- Icons are placeholders until original exercise instruction images are added.
FF.exercises = {
  {
    id = "squats",
    group = "No Equipment",
    name = "Bodyweight Squats",
    icon = ICON_PATH .. "squats.blp",
    instructions =
    "Stand with feet about shoulder-width apart and toes slightly turned out. Brace your core, bend hips and knees to squat with heels down, then drive through your feet to stand.",
    quip = "It might be hard now, but you'll be able to carry more loot later."
  },
  {
    id = "calfraises",
    group = "No Equipment",
    name = "Calf Raises",
    icon = ICON_PATH .. "calfraises.blp",
    instructions =
    "Stand upright with feet hip-width apart. Press through the balls of your feet to raise your heels as high as possible, pause, then lower under control without bouncing.",
    quip = "Why do you think Cairnes calves are so big?"
  },
  {
    id = "plank",
    group = "No Equipment",
    name = "Forearm Plank",
    icon = ICON_PATH .. "plank.blp",
    instructions =
    "Place forearms on the floor with elbows beneath shoulders and extend your legs behind you. Brace your abs and glutes, keeping a straight line from head to heels without sagging.",
    quip = "Without a few planks, that Barbaric Harness wouldn't look nearly as good."
  },
  {
    id = "jumpingjacks",
    group = "No Equipment",
    name = "Jumping Jacks",
    icon = ICON_PATH .. "jumpingjacks.blp",
    instructions =
    "Stand tall with feet together and arms at your sides. Jump feet apart while raising arms overhead, land softly, then jump back to the start. Repeat with steady rhythm.",
    quip = "Valeera Sanguinar didn't get that nimble by standing in stealth all day."
  },
  {
    id = "pushups",
    group = "No Equipment",
    name = "Push-ups",
    icon = ICON_PATH .. "pushups.blp",
    instructions =
    "Place hands just wider than shoulders and extend your legs into a straight plank. Keep elbows angled back as you lower your chest, then press up without letting your hips sag.",
    quip = "The Scarlet Crusade isn't going to push itself back!"
  },
  {
    id = "lunges",
    group = "No Equipment",
    name = "Reverse Lunges",
    icon = ICON_PATH .. "lunges.blp",
    instructions =
    "Stand tall and brace your core. Step one leg backward and lower until both knees bend near 90 degrees, keeping your front foot flat. Push through the front foot to stand; switch legs.",
    quip = "For the Horde! And for healthier knees."
  },
  {
    id = "wallpushups",
    group = "No Equipment",
    name = "Wall Push-ups",
    icon = ICON_PATH .. "wallpushups.blp",
    instructions =
    "Face a wall with palms at shoulder height, slightly wider than your shoulders. Walk feet back, bend elbows to bring your chest toward the wall, then push away with your body straight.",
    quip = "Every build starts out with a strong foundation."
  },
  {
    id = "curls",
    group = "Free Weights",
    name = "Dumbbell Curls",
    icon = ICON_PATH .. "curls.blp",
    instructions =
    "Stand holding dumbbells at your sides, palms forward. Keep upper arms close to your torso as you curl weights toward shoulders, then lower slowly without swinging.",
    quip = "You don't swing hammers like King Magni Bronzebeard without putting in a few curls."
  },
  {
    id = "deadlifts",
    group = "Free Weights",
    name = "Dumbbell Deadlifts",
    icon = ICON_PATH .. "deadlifts.blp",
    instructions =
    "Hold dumbbells at your sides with feet hip-width apart. Brace your core, bend knees slightly and hinge hips back with a neutral spine. Push through your feet to stand tall.",
    quip = "The proper way to pick up quest items."
  },
  {
    id = "gobletsquats",
    group = "Free Weights",
    name = "Goblet Squats",
    icon = ICON_PATH .. "gobletsquats.blp",
    instructions =
    "Hold one dumbbell at chest level with both hands. Stand shoulder-width apart, brace your core and squat between your knees while keeping heels down. Push through your feet to stand.",
    quip = "This is how goblins carry their gold bars."
  },
  {
    id = "laterals",
    group = "Free Weights",
    name = "Lateral Raises",
    icon = ICON_PATH .. "laterals.blp",
    instructions =
    "Stand tall with dumbbells at your sides and elbows slightly bent. Raise arms out to shoulder height, leading with elbows and avoiding momentum. Lower slowly.",
    quip = "Spread your wings. Not too hard though, no flying in Forever"
  },
  {
    id = "rows",
    group = "Free Weights",
    name = "One-arm Dumbbell Rows",
    icon = ICON_PATH .. "rows.blp",
    instructions =
    "Support one hand and knee on a sturdy bench; keep your back neutral. Pull the dumbbell toward your torso with elbow close to your side, squeeze your shoulder blade, then lower.",
    quip = "Pull harder! Your healer has mana and the DPS are itching."
  },
  {
    id = "triceps",
    group = "Free Weights",
    name = "Overhead Triceps Extensions",
    icon = ICON_PATH .. "triceps.blp",
    instructions =
    "Hold one dumbbell securely with both hands overhead. Keep upper arms steady as you bend your elbows to lower the weight behind your head, then extend your arms.",
    quip = "The Light demands faith, discipline, and stronger triceps!"
  },
  {
    id = "press",
    group = "Free Weights",
    name = "Shoulder Press",
    icon = ICON_PATH .. "press.blp",
    instructions =
    "Hold dumbbells at shoulder height with feet planted and core braced. Press overhead until your arms extend without arching your back, then lower slowly to your shoulders.",
    quip =
    "Believe it or not, there's no room between Varian Wrynn's shoulders and those massive pauldrons!"
  },
  {
    id = "shrugs",
    group = "Free Weights",
    name = "Shoulder Shrugs",
    icon = ICON_PATH .. "shrugs.blp",
    instructions =
    "Stand tall with dumbbells at your sides and arms straight. Raise shoulders directly toward your ears without rolling them or bending elbows, pause, then lower slowly.",
    quip = "/shrug, but heavier. Much heavier."
  },
  {
    id = "easywalk",
    group = "Walking Pad",
    name = "Easy Walk",
    icon = ICON_PATH .. "easywalk.blp",
    instructions =
    "Stand on the walking pad and start at a low speed. Walk with natural strides, relaxed shoulders and eyes forward; adjust speed to stay comfortable.",
    quip = "Just press W."
  },
  {
    id = "briskwalk",
    group = "Walking Pad",
    name = "Brisk Walk",
    icon = ICON_PATH .. "briskwalk.blp",
    instructions =
    "Begin at an easy pace, then gradually increase speed until your breathing quickens but your stride remains controlled. Look ahead, stand upright and avoid running.",
    quip = "Pretend you're PirateSoftware in Dire Maul."
  },
  {
    id = "inclineeasy",
    group = "Walking Pad",
    name = "Easy Incline Walk",
    icon = ICON_PATH .. "inclineeasy.blp",
    instructions =
    "If your walking pad supports incline, choose a gentle grade and start at a comfortable speed. Keep your torso upright, look ahead and use natural steps.",
    quip = "On the way to the icy mountains of dun morough, taking in the view."
  },
  {
    id = "inclinebrisk",
    group = "Walking Pad",
    name = "Brisk Incline Walk",
    icon = ICON_PATH .. "inclinebrisk.blp",
    instructions =
    "If your walking pad supports incline, set a manageable grade and gradually increase to a brisk pace. Stay upright, walk without overstriding and ease off if needed.",
    quip = "Brave the climb to Mount Hyjal!"
  },
}