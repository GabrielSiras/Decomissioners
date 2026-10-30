class_name LatchCounter
extends Control

@export var content: Control
@export var count_label: Label
@export var slide_distance: float = 60.0
@export var fade_time: float = 0.35
@export var pop_scale: float = 1.4

var current_count: int = 0
var visible_state: bool = false
var tween: Tween

func _ready() -> void:
	add_to_group("latch_counter")
	if content == null:
		content = $Content
	if count_label == null:
		count_label = $Content/CountLabel
	content.modulate.a = 0.0
	content.position.x = -slide_distance
	refresh()

func refresh() -> void:
	var count := get_tree().get_nodes_in_group("latched_opressors").size()
	if count == current_count:
		return

	var previous := current_count
	current_count = count

	if count > 0:
		count_label.text = str(count)
		if not visible_state:
			_show()
		elif count > previous:
			_pop()
	elif visible_state:
		_hide()

func _kill_tween() -> void:
	if tween and tween.is_valid():
		tween.kill()

func _show() -> void:
	visible_state = true
	_kill_tween()
	tween = create_tween().set_parallel(true)
	tween.tween_property(content, "modulate:a", 1.0, fade_time)
	tween.tween_property(content, "position:x", 0.0, fade_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide() -> void:
	visible_state = false
	_kill_tween()
	tween = create_tween().set_parallel(true)
	tween.tween_property(content, "modulate:a", 0.0, fade_time)
	tween.tween_property(content, "position:x", -slide_distance, fade_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _pop() -> void:
	count_label.pivot_offset = count_label.size * 0.5
	count_label.scale = Vector2.ONE * pop_scale
	var t := create_tween()
	t.tween_property(count_label, "scale", Vector2.ONE, 0.2) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
