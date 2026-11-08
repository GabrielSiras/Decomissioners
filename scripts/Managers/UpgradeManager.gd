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
