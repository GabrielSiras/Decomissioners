class_name MainMenu
extends Control
@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer

@export var start_button: Button

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_start_button_pressed() -> void:
	start_button.disabled = true
	$MetalClick.pitch_scale = randf_range(0.9, 1.1)
	$MetalClick.play()
	start_timer.one_shot = true
	start_timer.start()
	await start_timer.timeout
	get_tree().change_scene_to_file("res://scenes/devroom.tscn")
	
func _on_research_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/ResearchMenu.tscn")
	
func _on_railmap_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")
	
