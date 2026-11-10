class_name PitchZone
extends Area3D

@export_category("Configurações do Piche")
@export var move_slow_ratio: float = 0.5
@export var attack_slow_ratio: float = 0.5

@export_category("Efeito de Fogo (Incendiary)")
@export var fire_duration: float = 5.0
@export var burn_damage_per_sec: float = 20.0
@export var armor_reduction_ratio: float = 0.4

var active: bool = false
var is_on_fire: bool = false
var fire_timer: float = 0.0
var ground_enemies_inside: Array[Node3D] = []
var _burn_acc: float = 0.0

@onready var fire_vfx: Node3D = $FireVFX if has_node("FireVFX") else null

func _ready() -> void:
	move_slow_ratio = UpgradeManager.pick(UpgradeManager.PITCH_SLOW, "Pitch")
	add_to_group("pitch_puddles")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if is_instance_valid(fire_vfx):
		fire_vfx.hide()
	set_active(false)

func set_active(value: bool) -> void:
	active = value
	monitoring = value
	monitorable = value
	if not value:
		for e in ground_enemies_inside:
			if is_instance_valid(e):
				_remove_debuff(e)
		ground_enemies_inside.clear()
		extinguish_fire()
	else:
		# pega quem já está dentro quando a zona liga
		for b in get_overlapping_bodies():
			_on_body_entered(b)

func _is_valid_ground_enemy(body: Node3D) -> bool:
	if not active or not is_instance_valid(body):
		return false
	if not body.is_in_group("enemies"):
		return false
	if body.is_in_group("flying") or ("is_flying" in body and body.is_flying):
		return false
	return true

func _on_body_entered(body: Node3D) -> void:
	if _is_valid_ground_enemy(body) and not ground_enemies_inside.has(body):
		ground_enemies_inside.append(body)
		if body.has_method("apply_slow"):
			body.apply_slow(move_slow_ratio, attack_slow_ratio)

func _on_body_exited(body: Node3D) -> void:
	if ground_enemies_inside.has(body):
		ground_enemies_inside.erase(body)
		_remove_debuff(body)

func _remove_debuff(enemy: Node3D) -> void:
	if enemy.has_method("remove_slow"):
		enemy.remove_slow()

func ignite() -> void:
	if not active:
		return
	if not is_on_fire:
		is_on_fire = true
		if is_instance_valid(fire_vfx):
			fire_vfx.show()
	fire_timer = fire_duration

func extinguish_fire() -> void:
	is_on_fire = false
	if is_instance_valid(fire_vfx):
		fire_vfx.hide()

func _process(delta: float) -> void:
	if not is_on_fire:
		return
	fire_timer -= delta
	_burn(delta)
	if fire_timer <= 0.0:
		extinguish_fire()

func _burn(delta: float) -> void:
	_burn_acc += burn_damage_per_sec * delta
	var tick: int = int(_burn_acc)
	_burn_acc -= tick
	for enemy in ground_enemies_inside:
		if not is_instance_valid(enemy):
			continue
		if tick > 0 and enemy.has_method("take_damage"):
			enemy.take_damage(tick)
		if enemy.has_method("apply_armor_debuff"):
			enemy.apply_armor_debuff(0.3)
