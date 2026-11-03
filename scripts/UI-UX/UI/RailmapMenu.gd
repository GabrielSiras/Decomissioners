extends Control


func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_research_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")
