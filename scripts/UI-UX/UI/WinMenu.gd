class_name WinMenu
extends CanvasLayer

@onready var menu_button: Button = $ColorRect/CenterContainer/VBoxContainer/MenuButton

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MainMenu.tscn")
