extends Button

func _ready() -> void:
	pressed.connect(SettingsOverlay._on_exit_button_pressed.bind(name))
