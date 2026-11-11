class_name DemolishingMenuUI
extends Control

@export var train: TrainHead
@export var menu_offset_y: float = 65.0 

@export_category("SFX")
@export var random_pitch: bool = true
@export var pitch_min: float = 0.9
@export var pitch_max: float = 1.1

@onready var demolish_sound: AudioStreamPlayer = $DemolishSound

@onready var radial_panel: Control = $RadialPanel
@onready var btn_demolish: Button = $RadialPanel/ButtonDemolish
@onready var btn_upgrade: Button = $RadialPanel/ButtonUpgrade

var current_slot: Node3D = null

func _ready() -> void:
	hide()
	
	btn_demolish.pressed.connect(_on_demolish_selected)
	
	btn_demolish.set_anchors_preset(Control.PRESET_TOP_LEFT)
	btn_demolish.custom_minimum_size = Vector2(80, 50)
	btn_demolish.size = btn_demolish.custom_minimum_size
	btn_demolish.position = Vector2(-btn_demolish.size.x / 2.0, menu_offset_y)
	
	btn_upgrade.pressed.connect(_on_upgrade_selected)
	btn_upgrade.set_anchors_preset(Control.PRESET_TOP_LEFT)
	btn_upgrade.custom_minimum_size = Vector2(80, 50)
	btn_upgrade.size = btn_upgrade.custom_minimum_size
	btn_upgrade.position = Vector2(-btn_upgrade.size.x / 2.0, -menu_offset_y - btn_upgrade.size.y)
	
	if is_instance_valid(train):
		if not train.is_node_ready():
			await train.ready
		
		_connect_all_slots()

func _play_demolish_sound() -> void:
	if not is_instance_valid(demolish_sound):
		return
	if random_pitch:
		demolish_sound.pitch_scale = randf_range(pitch_min, pitch_max)
	demolish_sound.play()

func _connect_all_slots() -> void:
	if train.turret_slots_container:
		_connect_container_slots(train.turret_slots_container)
		
	for wagon in train.wagons:
		if is_instance_valid(wagon) and wagon.has_node("TurretSlots"):
			_connect_container_slots(wagon.get_node("TurretSlots"))

func _connect_container_slots(container: Node3D) -> void:
	for slot in container.get_children():
		if slot.has_signal("slot_clicked") and not slot.slot_clicked.is_connected(_on_slot_clicked):
			slot.slot_clicked.connect(_on_slot_clicked)

func _process(_delta: float) -> void:
	if visible and is_instance_valid(current_slot):
		var camera = get_viewport().get_camera_3d()
		if camera:
			var screen_pos = camera.unproject_position(current_slot.global_position)
			radial_panel.global_position = screen_pos

func _on_slot_clicked(slot_node: Node3D) -> void:
	if train.slots_status.get(slot_node) != null:
		current_slot = slot_node
		_update_button_text()
		show()
	else:
		hide()

func _update_button_text() -> void:
	if not is_instance_valid(current_slot):
		return
	var turret = train.slots_status.get(current_slot)
	if is_instance_valid(turret) and "build_cost" in turret:
		btn_demolish.text = "Demolish turret? Refund: $" + str(int(turret.build_cost * 0.3))
	else:
		btn_demolish.text = "Demolish turret?"

	var st: Dictionary = train.get_upgrade_status(current_slot)
	btn_upgrade.disabled = not st["can"]
	if st["can"]:
		btn_upgrade.text = "Upgrade $" + str(st["cost"])
	else:
		btn_upgrade.text = st["reason"] if st["reason"] != "" else "Upgrade"

func _on_demolish_selected() -> void:
	if is_instance_valid(current_slot):
		train.demolish_turret_at_slot(current_slot)
		_play_demolish_sound()
		hide()

func _on_upgrade_selected() -> void:
	if not is_instance_valid(current_slot):
		return
	if train.upgrade_turret_at_slot(current_slot):
		_play_demolish_sound() 
		_update_button_text()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		hide()
