extends Button

func _on_button_pressed() -> void:
	SettingsOverlay.visible = true
	get_tree().paused = true
	
