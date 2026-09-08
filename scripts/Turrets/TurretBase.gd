class_name TurretBase
extends Node2D

@export_category("Atributos Base da Torre")
@export var damage: int = 5
@export var fire_rate: float = 1.0
@export var range_radius: float = 200.0

@onready var range_area: Area2D = $RangeArea
@onready var shoot_timer: Timer = $ShootTimer
@onready var muzzle: Marker2D = $Muzzle

var targets_in_range: Array[Node2D] = []
var current_target: Node2D = null

func _ready() -> void:
	shoot_timer.wait_time = fire_rate
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)
	
	var collision = range_area.get_node_or_null("CollisionShape2D")
	if collision and collision.shape is CircleShape2D:
		collision.shape.radius = range_radius

func _process(_delta: float) -> void:
	_update_target()
	
	if is_instance_valid(current_target):
		look_at(current_target.global_position)

func _update_target() -> void:
	targets_in_range = targets_in_range.filter(func(t): return is_instance_valid(t))
	
	if targets_in_range.is_empty():
		current_target = null
		if not shoot_timer.is_stopped():
			shoot_timer.stop()
	else:
		current_target = targets_in_range[0] 
		if shoot_timer.is_stopped():
			shoot_timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		targets_in_range.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body in targets_in_range:
		targets_in_range.erase(body)

func _on_shoot_timer_timeout() -> void:
	if is_instance_valid(current_target):
		perform_attack()

func perform_attack() -> void:
	pass
