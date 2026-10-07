class_name PitchPuddle
extends Area3D

@export_category("Configurações do Piche")
@export var puddle_duration: float = 4.0  # Tempo que a poça fica ativa no chão
@export var fade_duration: float = 0.3    # Tempo da animação de sumir
@export var move_slow_ratio: float = 0.5
@export var attack_slow_ratio: float = 0.5

@export_category("Efeito de Fogo (Incendiary)")
@export var fire_duration: float = 5.0
@export var burn_damage_per_sec: float = 20.0
@export var armor_reduction_ratio: float = 0.4

var is_on_fire: bool = false
var fire_timer: float = 0.0
var ground_enemies_inside: Array[Node3D] = []
var is_fading: bool = false

@onready var fire_vfx: Node3D = $FireVFX if has_node("FireVFX") else null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if is_instance_valid(fire_vfx):
		fire_vfx.hide()

	# Inicia o tempo de vida da poça
	get_tree().create_timer(puddle_duration, false).timeout.connect(_start_fade_out)

func _start_fade_out() -> void:
	if is_fading:
		return
	is_fading = true

	# 1. Remove os debuffs dos inimigos imediatamente
	for enemy in ground_enemies_inside:
		if is_instance_valid(enemy):
			_remove_puddle_debuff(enemy)
	ground_enemies_inside.clear()

	# 2. Desativa detecção de área para não afetar novos inimigos enquanto some
	monitoring = false
	monitorable = false

	# 3. Para de emitir novas partículas em todos os nós filhos para evaporar limpo
	_stop_particles(self)

	# 4. Transição suave (Tween) encolhendo a escala até 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector3(0.001, 0.001, 0.001), fade_duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	# 5. Espera o Tween terminar para deletar o nó com segurança
	await tween.finished
	queue_free()

func _stop_particles(parent_node: Node) -> void:
	for child in parent_node.get_children():
		if child is GPUParticles3D or child is CPUParticles3D:
			child.emitting = false
		if child.get_child_count() > 0:
			_stop_particles(child)

func _process(delta: float) -> void:
	if is_on_fire:
		fire_timer -= delta
		_apply_burn_and_armor_debuff(delta)
		
		if fire_timer <= 0.0:
			extinguish_fire()

func _is_valid_ground_enemy(body: Node3D) -> bool:
	if is_fading or not is_instance_valid(body):
		return false
	if not body.is_in_group("enemies"):
		return false
	if body.is_in_group("flying") or ("is_flying" in body and body.is_flying):
		return false
	return true

func _on_body_entered(body: Node3D) -> void:
	if _is_valid_ground_enemy(body):
		if not ground_enemies_inside.has(body):
			ground_enemies_inside.append(body)
			_apply_puddle_debuff(body)

func _on_body_exited(body: Node3D) -> void:
	if ground_enemies_inside.has(body):
		ground_enemies_inside.erase(body)
		_remove_puddle_debuff(body)

func _apply_puddle_debuff(enemy: Node3D) -> void:
	if enemy.has_method("apply_slow"):
		enemy.apply_slow(move_slow_ratio, attack_slow_ratio)

func _remove_puddle_debuff(enemy: Node3D) -> void:
	if enemy.has_method("remove_slow"):
		enemy.remove_slow()

func ignite() -> void:
	if not is_on_fire:
		is_on_fire = true
		if is_instance_valid(fire_vfx):
			fire_vfx.show()
	fire_timer = fire_duration

func extinguish_fire() -> void:
	is_on_fire = false
	if is_instance_valid(fire_vfx):
		fire_vfx.hide()

func _apply_burn_and_armor_debuff(delta: float) -> void:
	for enemy in ground_enemies_inside:
		if is_instance_valid(enemy):
			if enemy.has_method("take_damage"):
				enemy.take_damage(burn_damage_per_sec * delta)
			
			if enemy.has_method("apply_armor_reduction"):
				enemy.apply_armor_reduction(armor_reduction_ratio)
