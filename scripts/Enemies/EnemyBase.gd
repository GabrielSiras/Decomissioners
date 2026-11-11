class_name EnemyBase
extends CharacterBody3D

@export_group("Stats")
@export var max_health: int = 30
@export var current_armor: int = 10
@export var speed: float = 5.0
@export var metal_reward: int = 5

@export_group("Target")
@export var target: Node3D

@export_group("Health Bar")
@export var health_bar_scene: PackedScene = preload("res://scenes/UI-UX/UI/HealthBar.tscn")
@export var bar_offset: Vector3 = Vector3(0, 1.8, 0)
@export var bar_size: Vector2 = Vector2(40, 5)
@export var show_bar_only_when_damaged: bool = true
@export var auto_bar_position: bool = true
@export var bar_height_padding: float = 0.3
var health_bar: HealthBarUI = null
var _bar_world_offset: Vector3 = Vector3(0, 1.8, 0)
@export var screen_offset_pixels: float = 64.0

@onready var current_health: int = max_health
@export var armor_penetration: float = 0.5
var knockback_velocity: Vector3 = Vector3.ZERO
@export var knockback_friction: float = 30.0

var is_armor_debuffed: bool = false
var original_armor: int = 0
var debuff_timer_left: float = 0.0
var stun_timer: float = 0.0
var _model_size: float = 1.0
var _base_speed: float = 0.0
var _slow_count: int = 0

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies")
	tree_exiting.connect(_free_health_bar)
	_create_health_bar()
	if auto_bar_position:
		_compute_bar_offset()
	else:
		_bar_world_offset = bar_offset
	_base_speed = speed

func apply_slow(ratio: float) -> void:
	_slow_count += 1
	speed = _base_speed * (1.0 - ratio)

func remove_slow() -> void:
	_slow_count = maxi(0, _slow_count - 1)
	if _slow_count == 0:
		speed = _base_speed

func _compute_bar_offset() -> void:
	var meshes := find_children("*", "VisualInstance3D", true, false)
	var has_bounds := false
	var combined := AABB()

	for m in meshes:
		if not (m is MeshInstance3D):
			continue
		var aabb: AABB = m.global_transform * m.get_aabb()
		if not has_bounds:
			combined = aabb
			has_bounds = true
		else:
			combined = combined.merge(aabb)

	if not has_bounds:
		_bar_world_offset = bar_offset
		return

	var top_center := combined.position + Vector3(combined.size.x * 0.5, combined.size.y, combined.size.z * 0.5)
	var local := global_transform.affine_inverse() * top_center
	_bar_world_offset = Vector3(local.x, local.y + bar_height_padding, local.z)

func _create_health_bar() -> void:
	if health_bar_scene == null:
		return
	var layer := _get_bars_layer()
	health_bar = health_bar_scene.instantiate()
	layer.add_child(health_bar)
	health_bar.custom_minimum_size = bar_size
	health_bar.size = bar_size
	health_bar.init_health(float(max_health))
	health_bar.visible = not show_bar_only_when_damaged

func _get_bars_layer() -> Control:
	var layer = get_tree().get_first_node_in_group("enemy_bars_layer")
	if layer == null:
		var canvas := CanvasLayer.new()
		canvas.layer = 5
		var ctrl := Control.new()
		ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
		ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		ctrl.add_to_group("enemy_bars_layer")
		canvas.add_child(ctrl)
		get_tree().current_scene.add_child(canvas)
		layer = ctrl
	return layer

func _process(_delta: float) -> void:
	if not is_instance_valid(health_bar):
		return
	if show_bar_only_when_damaged and current_health >= max_health:
		health_bar.visible = false
		return
	var camera := get_viewport().get_camera_3d()
	if not is_instance_valid(camera):
		return

	var world_pos := global_position
	var on_screen := not camera.is_position_behind(world_pos)
	health_bar.visible = on_screen
	if on_screen:
		var p := camera.unproject_position(world_pos)
		var lift: float = screen_offset_pixels + _model_size * 8.0
		health_bar.position = p - Vector2(health_bar.size.x * 0.5, health_bar.size.y * 0.5 + lift)

func _free_health_bar() -> void:
	if is_instance_valid(health_bar):
		health_bar.queue_free()

func _update_health_bar() -> void:
	if is_instance_valid(health_bar):
		health_bar.health = float(current_health)

func apply_stun(duration: float) -> void:
	stun_timer = max(stun_timer, duration)

func apply_knockback(impulse: Vector3) -> void:
	impulse.y = 0.0
	
	var push_dir = impulse.normalized()
	global_position += push_dir * 0.3
	
	knockback_velocity = impulse

func _physics_process(delta: float) -> void:
	if is_armor_debuffed:
		debuff_timer_left -= delta
		if debuff_timer_left <= 0.0:
			_remove_armor_debuff()

	var ai_velocity: Vector3 = Vector3.ZERO

	if stun_timer > 0.0:
		stun_timer -= delta
	elif knockback_velocity.length() < 2.0 and is_instance_valid(target):
		var direction: Vector3 = (target.global_position - global_position).normalized()
		direction.y = 0.0
		ai_velocity = direction * speed
		
		if direction != Vector3.ZERO:
			look_at(global_position + direction, Vector3.UP)

	velocity = ai_velocity + knockback_velocity
	move_and_slide()

	if knockback_velocity.length() > 0.01:
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_friction * delta)
	else:
		knockback_velocity = Vector3.ZERO

func apply_armor_debuff(duration: float) -> void:
	if not is_armor_debuffed:
		is_armor_debuffed = true
		original_armor = current_armor
		current_armor = 0
	
	debuff_timer_left = duration

func _remove_armor_debuff() -> void:
	if is_armor_debuffed:
		is_armor_debuffed = false
		current_armor = original_armor

func take_damage(amount: int) -> void:
	if current_health <= 0:
		return

	var armor_reduction_percent: float = clamp(current_armor, 0, 100) / 100.0
	var damage_multiplier: float = 1.0 - armor_reduction_percent
	var final_damage: int = max(0, roundi(amount * damage_multiplier))
	
	current_health -= final_damage
	_update_health_bar()

	if current_health <= 0:
		die()

func take_damage_with_pen(amount: int, armor_pen: float) -> void:
	if current_health <= 0:
		return

	var effective_armor: float = current_armor * (1.0 - armor_pen)
	var armor_reduction_percent: float = clamp(effective_armor, 0.0, 100.0) / 100.0
	
	var final_damage: int = max(1, roundi(amount * (1.0 - armor_reduction_percent)))
	current_health -= final_damage
	_update_health_bar()
	
	if current_health <= 0:
		die()

func die() -> void:
	MetalManager.add_metal(roundi(metal_reward * UpgradeManager.magnetism_mult()))
	queue_free()
