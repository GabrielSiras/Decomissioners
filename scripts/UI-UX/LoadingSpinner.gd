class_name LoadingSpinner
extends Control

@export var dot_count: int = 8
@export var radius: float = 22.0
@export var dot_radius: float = 4.5
@export var speed: float = 1.2
@export var color: Color = Color("#f84824")

@export_group("Outline")
@export var outline_color: Color = Color.BLACK
@export var outline_width: float = 4.0

var t: float = 0.0

func _ready() -> void:
	var margin := (dot_radius + maxf(outline_width, 0.0)) * 4.0
	custom_minimum_size = Vector2(radius * 2.0 + margin, radius * 2.0 + margin)
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

		var r : float = dot_radius * lerp(0.4, 1.0, k)
		var alpha : float = lerp(0.15, 1.0, k)

		if outline_width > 0.0:
			draw_circle(pos, r + outline_width, Color(outline_color, alpha))

		draw_circle(pos, r, Color(color, alpha))
