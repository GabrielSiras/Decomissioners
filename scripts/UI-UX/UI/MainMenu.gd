class_name MainMenu
extends CanvasLayer

@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/devroom.tscn")
