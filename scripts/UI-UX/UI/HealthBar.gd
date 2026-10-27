class_name HealthBarUI
extends ProgressBar

@onready var damage_bar: ProgressBar = $DamageBar
@onready var timer: Timer = $Timer

var health: float = 0.0:
	set(new_val):
		var previous_health = health
		health = new_val
		
		# Atualiza a barra principal
		self.value = health
		
		# Obtém o damage_bar de forma segura caso o @onready ainda não tenha corrido
		var d_bar = damage_bar if is_instance_valid(damage_bar) else get_node_or_null("DamageBar")
		
		if health < previous_health:
			if is_instance_valid(timer):
				timer.start()
		else:
			if is_instance_valid(d_bar):
				d_bar.value = health

func init_health(max_hp: float) -> void:
	max_value = max_hp
	self.value = max_hp
	health = max_hp
	
	var d_bar = damage_bar if is_instance_valid(damage_bar) else get_node_or_null("DamageBar")
	if is_instance_valid(d_bar):
		d_bar.max_value = max_hp
		d_bar.value = max_hp

func _ready() -> void:
	if is_instance_valid(timer):
		if not timer.timeout.is_connected(_on_timer_timeout):
			timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	var d_bar = damage_bar if is_instance_valid(damage_bar) else get_node_or_null("DamageBar")
	if is_instance_valid(d_bar):
		var tween = create_tween()
		tween.tween_property(d_bar, "value", health, 0.3)
