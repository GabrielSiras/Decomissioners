class_name MachineGunTurret
extends TurretBase

func _ready() -> void:
	super._ready()
	#apply_level_stats(current_level)
	
	if has_node("Model3D"):
		$Model3D.rotate_y(PI)
