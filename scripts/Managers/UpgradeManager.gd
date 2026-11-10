extends Node

var research_points: int = 30

var upgrades: Dictionary = {
	
	# Train Upgrades:
	"Armor": {"Level": 0, "Max": 3},
	"Magnetism": {"Level": 0, "Max": 3},
	"Transmission": {"Level": 0, "Max": 4},
	"Wagons": {"Level": 0, "Max": 4},
	
	#Skill Upgrades:
	"Bombardment": {"Level": 1, "Max": 3},
	"Repair": {"Level": 1, "Max": 3},
	"Pitch": {"Level": 1, "Max": 3},
	"Supercharge": {"Level": 1, "Max": 3},
	
	#Turret Upgrades:
	"Machinegun": {"Level": 1, "Max": 3},
	"Artillery": {"Level": 1, "Max": 3},
	"Blast": {"Level": 1, "Max": 3},
	"Incendiary": {"Level": 1, "Max": 3},
}

func preview(key: String) -> String:
	if not PREVIEW.has(key):
		return ""
	var lvl: int = upgrades[key]["Level"]
	var lines: Array[String] = []
	for e in PREVIEW[key]:
		var arr: Array = e["arr"]
		var cur: float = arr[clampi(lvl, 0, arr.size() - 1)] * e["mult"]
		var nxt: float = arr[clampi(lvl + 1, 0, arr.size() - 1)] * e["mult"]
		lines.append("%s: %s%s → %s%s" % [e["label"], str(snappedf(cur, 0.1)), e["suffix"], str(snappedf(nxt, 0.1)), e["suffix"]])
	return "\n".join(lines)

const PREVIEW := {
	"Armor":        [{"label": "Penetration reduction", "arr": ARMOR_PEN_REDUCTION, "mult": 100.0, "suffix": "%"}],
	"Magnetism":    [{"label": "Bonus metal", "arr": MAGNETISM_BONUS, "mult": 100.0, "suffix": "%"}],
	"Transmission": [{"label": "Energy per wagon", "arr": TRANSMISSION_POWER, "mult": 1.0, "suffix": ""}],
	"Bombardment":  [{"label": "Damage", "arr": BOMB_DAMAGE_MULT, "mult": 100.0, "suffix": "%"},
					 {"label": "Radius", "arr": BOMB_RADIUS_MULT, "mult": 100.0, "suffix": "%"}],
	"Pitch":        [{"label": "Slow", "arr": PITCH_SLOW, "mult": 100.0, "suffix": "%"}],
	"Supercharge":  [{"label": "Duration", "arr": SUPER_DURATION, "mult": 1.0, "suffix": "s"},
					 {"label": "Attack speed", "arr": SUPER_ATK_SPEED, "mult": 100.0, "suffix": "%"}],
	"Repair":       [{"label": "Heal", "arr": REPAIR_HEAL, "mult": 1.0, "suffix": ""},
					 {"label": "Cost", "arr": REPAIR_COST, "mult": 1.0, "suffix": " metal"},
					 {"label": "Cooldown", "arr": REPAIR_COOLDOWN, "mult": 1.0, "suffix": "s"}],
}

func _ready() -> void:
	print("wagon_limit: ", UpgradeManager.wagon_limit())            # 2 no nível 0
	print("energia: ", UpgradeManager.transmission_power())          # 5
	print("magnetism: ", UpgradeManager.magnetism_mult())            # 1.0
	print("pen 0.5: ", UpgradeManager.armor_penetration_after_upgrade(0.5))
	print(UpgradeManager.preview("Armor"))

func level(key: String) -> int:
	return upgrades[key]["Level"]

func pick(arr: Array, key: String) -> float:
	return arr[clampi(upgrades[key]["Level"], 0, arr.size() - 1)]

# do train
const ARMOR_PEN_REDUCTION := [0.0, 0.1, 0.2, 0.3]      # subtrai da penetração do inimigo
const MAGNETISM_BONUS     := [0.0, 0.15, 0.30, 0.45]   # % extra de metal
const TRANSMISSION_POWER  := [5, 6, 7, 8, 9] # energia por vagão
const WAGON_LIMIT         := [2, 3, 4, 5, 6]

# skills
const BOMB_DAMAGE_MULT := [1.0, 1.25, 1.5, 1.75]
const BOMB_RADIUS_MULT := [1.0, 1.15, 1.3, 1.45]
const PITCH_SLOW       := [0.4, 0.5, 0.6, 0.7]
const SUPER_DURATION   := [5.0, 6.5, 8.0, 10.0]
const SUPER_ATK_SPEED  := [1.3, 1.45, 1.6, 1.8]
const REPAIR_HEAL     := [30, 45, 60, 80]
const REPAIR_COST     := [60, 50, 40, 30]
const REPAIR_COOLDOWN := [20.0, 17.0, 14.0, 11.0]

func armor_penetration_after_upgrade(pen: float) -> float:
	return maxf(0.0, pen - pick(ARMOR_PEN_REDUCTION, "Armor"))

func magnetism_mult() -> float:
	return 1.0 + pick(MAGNETISM_BONUS, "Magnetism")

func transmission_power() -> int:
	return int(pick(TRANSMISSION_POWER, "Transmission"))

func wagon_limit() -> int:
	return int(pick(WAGON_LIMIT, "Wagons"))
