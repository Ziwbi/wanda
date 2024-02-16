GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

STRINGS.CHARACTER_TITLES.wanda = "The Timekeeper"
STRINGS.CHARACTER_NAMES.wanda = "Wanda"
STRINGS.CHARACTER_DESCRIPTIONS.wanda = "*Has excellent time management skills \n*Only as old as she feels \n*In a constant race against the clock"
STRINGS.CHARACTER_QUOTES.wanda = "\"Time! I just need more time!\""
STRINGS.CHARACTERS.WANDA = require "speech_wanda"
STRINGS.CHARACTERS.wanda = STRINGS.CHARACTERS.WANDA -- In base game and RoG GetActionFailString does not use string.upper on prefab name
table.insert(CHARACTER_GENDERS.FEMALE, "wanda")


STRINGS.ACTIONS.CAST_POCKETWATCH = {
    GENERIC = "Activate",
	RECALL_MARK = "Set Time In Space",
	-- RECALL = "Travel Back", 
}
STRINGS.ACTIONS.DISMANTLE_POCKETWATCH = "Take Apart"


STRINGS.NAMES.OLDAGER_COMPONENT = "the passage of time" -- for "was killed by ..." string
STRINGS.NAMES.POCKETWATCH_DISMANTLER = "Clockmaker's Tools"
STRINGS.NAMES.POCKETWATCH_HEAL = "Ageless Watch"
STRINGS.NAMES.POCKETWATCH_PARTS = "Time Pieces"
STRINGS.NAMES.POCKETWATCH_RECALL = "Backtrek Watch"
STRINGS.NAMES.POCKETWATCH_WARP = "Backstep Watch"
STRINGS.NAMES.POCKETWATCH_WEAPON = "Alarming Clock"
STRINGS.NAMES.WANDA = "Wanda"


STRINGS.TABS.CLOCKMAKER = "Clocksmithy"
STRINGS.RECIPE_DESC.POCKETWATCH_DISMANTLER = "Tinker with timepieces."
STRINGS.RECIPE_DESC.POCKETWATCH_HEAL = "You're only as old as you feel."
STRINGS.RECIPE_DESC.POCKETWATCH_PARTS = "It's what's inside, that counts."
STRINGS.RECIPE_DESC.POCKETWATCH_RECALL = "Return to a distant point in time."
STRINGS.RECIPE_DESC.POCKETWATCH_WARP = "Retrace your last steps."
STRINGS.RECIPE_DESC.POCKETWATCH_WEAPON = "This clock strikes YOU."

-- Technically those items are character specific, just in case
STRINGS.CHARACTERS.GENERIC.POCKETWATCH_DISMANTLER = "I wonder if she got them second hand."
STRINGS.CHARACTERS.GENERIC.POCKETWATCH_HEAL = {
	GENERIC = "I bet there's a lot of interesting science inside.",
	RECHARGING = "I guess it needs time to... recalibrate the, uh... time whatsit.",
}
STRINGS.CHARACTERS.GENERIC.POCKETWATCH_PARTS = "Wait a minute, this is starting to look more like magic than science!"
STRINGS.CHARACTERS.GENERIC.POCKETWATCH_WARP = {
	GENERIC = "I bet there's a lot of interesting science inside.",
	RECHARGING = "It's doing \"time stuff\", that's the technical term.",
}
STRINGS.CHARACTERS.GENERIC.POCKETWATCH_WEAPON = {
	GENERIC = "That looks like a bad time just waiting to happen.",
	DEPLETED = "only_used_by_wanda",
}
