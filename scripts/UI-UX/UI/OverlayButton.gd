extends Button

@export var overlay: PackedScene

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	var overlay_instance = overlay.instantiate()
	add_child(overlay_instance)
