class_name SpeedLever
extends CanvasLayer

signal speed_changed(speed_factor: float)

@onready var v_slider: VSlider = $VSlider

func _ready() -> void:
	v_slider.value_changed.connect(_on_slider_value_changed)

func _on_slider_value_changed(new_value: float) -> void:
	speed_changed.emit(new_value)

func update_slider_visual(factor: float) -> void:
	if is_instance_valid(v_slider):
		v_slider.set_value_no_signal(factor)
