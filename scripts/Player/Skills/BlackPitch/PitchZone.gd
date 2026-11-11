class_name PitchZone
extends Area3D

@export var fire_duration: float = 5.0
@export var burn_damage_per_sec: float = 20.0

var active: bool = false
var slow_ratio: float = 0.5
var inside: Array[Node3D] = []
var fire_timer: float = 0.0
var _burn_acc: float = 0.0

@onready var fire_vfx: Node3D = get_node_or_null("FireVFX")

func _ready() -> void:
	add_to_group("pitch_puddles")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if fire_vfx:
		fire_vfx.hide()
	set_active(false)

func set_active(value: bool) -> void:
	active = value
	monitoring = value
	if value:
		slow_ratio = UpgradeManager.pick(UpgradeManager.PITCH_SLOW, "Pitch")
		for b in get_overlapping_bodies():
			_on_body_entered(b)
	else:
		for e in inside:
			if is_instance_valid(e):
				e.remove_slow()
		inside.clear()
		fire_timer = 0.0
		if fire_vfx:
			fire_vfx.hide()

func _on_body_entered(body: Node3D) -> void:
	if not active or inside.has(body):
		return
	if not body.is_in_group("enemies") or body.is_in_group("flying"):
		return
	if body.has_method("apply_slow"):
		inside.append(body)
		body.apply_slow(slow_ratio)

func _on_body_exited(body: Node3D) -> void:
	if inside.has(body):
		inside.erase(body)
		if is_instance_valid(body):
			body.remove_slow()

func ignite() -> void:
	if not active:
		return
	fire_timer = fire_duration
	if fire_vfx:
		fire_vfx.show()

func _process(delta: float) -> void:
	if fire_timer <= 0.0:
		return
	fire_timer -= delta
	if fire_timer <= 0.0 and fire_vfx:
		fire_vfx.hide()
	_burn_acc += burn_damage_per_sec * delta
	var tick := int(_burn_acc)
	_burn_acc -= tick
	if tick > 0:
		for e in inside:
			if is_instance_valid(e):
				e.take_damage(tick)
