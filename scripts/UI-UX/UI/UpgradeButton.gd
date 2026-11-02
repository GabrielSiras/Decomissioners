extends Button

signal no_button_toggled

func _ready() -> void:
	pressed.connect(owner._update_hud.bind(name))
	pressed.connect(_on_button_pressed)
	no_button_toggled.connect(owner._turn_off_hud)

func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	remove_from_group("UpgradeButtons")
	get_tree().call_group("UpgradeButtons", "untoggle_buttons")
	add_to_group("UpgradeButtons")
	if not button_pressed:
		no_button_toggled.emit()
	
func untoggle_buttons() -> void:
	button_pressed = false
