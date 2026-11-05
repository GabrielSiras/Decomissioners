class_name LoadingSpinner
extends Control

@export var dot_count: int = 8
@export var radius: float = 22.0
@export var dot_radius: float = 4.5
@export var speed: float = 1.2
@export var color: Color = Color.WHITE

var t: float = 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(radius * 2.0 + dot_radius * 4.0, radius * 2.0 + dot_radius * 4.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	t += delta * speed
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var head := fposmod(t, 1.0)
	for i in dot_count:
		var frac := float(i) / dot_count
		var k := 1.0 - fposmod(head - frac, 1.0)
		var ang := -PI * 0.5 + TAU * frac
		var pos := center + Vector2(cos(ang), sin(ang)) * radius
		draw_circle(pos, dot_radius * lerp(0.4, 1.0, k), Color(color, lerp(0.15, 1.0, k)))
