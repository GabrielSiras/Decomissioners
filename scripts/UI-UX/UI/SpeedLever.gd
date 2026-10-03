class_name SpeedLever
extends CanvasLayer

signal speed_changed(speed_factor: float)
signal braked()

@export_category("Efeitos Visuais")
@export var ui_brake_vfx_scene: PackedScene 

@onready var v_slider: VSlider = $VSlider

var _previous_value: float = 1.0

func _ready() -> void:
	if is_instance_valid(v_slider):
		_previous_value = v_slider.value
		v_slider.value_changed.connect(_on_slider_value_changed)

func _on_slider_value_changed(new_value: float) -> void:
	if new_value < _previous_value:
		braked.emit()

	_previous_value = new_value
	speed_changed.emit(new_value)

func update_slider_visual(factor: float) -> void:
	if is_instance_valid(v_slider):
		_previous_value = factor
		v_slider.set_value_no_signal(factor)

func _trigger_brake_vfx() -> void:
	if ui_brake_vfx_scene:
		var vfx = ui_brake_vfx_scene.instantiate()
		add_child(vfx)
		if vfx is Node2D or vfx is Control:
			vfx.global_position = v_slider.global_position
