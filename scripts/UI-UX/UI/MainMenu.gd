class_name MainMenu
extends CanvasLayer
@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton
@onready var start_timer: Timer = $StartTimer

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
