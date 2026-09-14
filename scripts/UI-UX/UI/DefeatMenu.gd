class_name DefeatMenu
extends CanvasLayer

@onready var restart_button: Button = $CenterContainer/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $CenterContainer/VBoxContainer/MainMenuButton

func _ready() -> void:
	hide()
	
	restart_button.pressed.connect(_on_restart_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func show_defeat() -> void:
	show()
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MainMenu.tscn")
