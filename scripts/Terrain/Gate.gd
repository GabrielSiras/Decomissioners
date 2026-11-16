extends Node3D
class_name Gate

@onready var gate: Node3D = $Gate
@onready var destroyed_gate: Node3D = $GateDestroyed

func switch_to_destroyed() -> void:
	gate.visible = false
	destroyed_gate.visible = true
