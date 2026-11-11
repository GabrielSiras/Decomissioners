class_name MachineGunTurret
extends TurretBase

##Lvl 1, Lvl 2, Lvl 3
var level_data: Dictionary = {
	1: {"damage": 2, "cooldown": 0.2, "armor_penetration": 0.10, "range": 2.0},
	2: {"damage": 3, "cooldown": 0.15, "armor_penetration": 0.15, "range": 3.0},
	3: {"damage": 4, "cooldown": 0.1, "armor_penetration": 0.20, "range": 4.0}
}

func _ready() -> void:
	super._ready()
	
	if has_node("Model3D"):
		$Model3D.rotate_y(PI)
