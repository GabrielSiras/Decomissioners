class_name EmpPulse
extends Node3D

@export var max_radius: float = 20.0
@export var force: float = 20.0
@export var expand_duration: float = 0.3

func _ready() -> void:
	call_deferred("_apply_pulse")

func _apply_pulse() -> void:
	print("--- EMP DISPARADO EM: ", global_position, " ---")
	var enemies = get_tree().get_nodes_in_group("enemies")
	print("Inimigos encontrados no grupo 'enemies': ", enemies.size())
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
			
		var target_node: Node3D = enemy
		while is_instance_valid(target_node) and not target_node.has_method("apply_knockback") and target_node != get_tree().current_scene:
			target_node = target_node.get_parent()
			
		if not is_instance_valid(target_node) or target_node == get_tree().current_scene:
			continue

		var diff: Vector3 = target_node.global_position - global_position
		diff.y = 0.0
		var distance: float = diff.length()
		
		if distance <= max_radius:
			var push_dir: Vector3 = diff.normalized() if distance > 0.001 else Vector3.FORWARD
			print(" -> Empurrando: ", target_node.name, " | Distancia: ", "%.2f" % distance)
			target_node.apply_knockback(push_dir * force)
			
	_play_visual_effect()

func _play_visual_effect() -> void:
	scale = Vector3.ONE * 0.1
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * max_radius, expand_duration)
	tween.tween_callback(queue_free)
