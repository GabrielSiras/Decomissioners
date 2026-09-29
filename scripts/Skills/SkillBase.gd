class_name SkillBase
extends Button

@export var cooldown_time: float = 0.1
@export var train: TrainHead
@onready var cooldown_timer: Timer = Timer.new()

var is_on_cooldown: bool = false

func _ready() -> void:
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = cooldown_time
	cooldown_timer.timeout.connect(_on_cooldown_finished)
	add_child(cooldown_timer)
	
	pressed.connect(_on_pressed)

func _process(_delta: float) -> void:
	if is_on_cooldown:
		_update_cooldown_ui(cooldown_timer.time_left)

func _on_pressed() -> void:
	if is_on_cooldown:
		return
	
	if _use_skill():
		_start_cooldown()

func _use_skill() -> bool:
	return false

func _start_cooldown() -> void:
	is_on_cooldown = true
	disabled = true
	cooldown_timer.start()

func _on_cooldown_finished() -> void:
	is_on_cooldown = false
	disabled = false
	text = name

func _update_cooldown_ui(time_left: float) -> void:
	text = "%.1fs" % time_left
