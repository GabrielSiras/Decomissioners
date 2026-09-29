class_name BuildMenuUI
extends Control

@export var train: TrainHead
@export var turret_1_scene: PackedScene
@export var turret_1_cost: int = 50

@export var turret_2_scene: PackedScene
@export var turret_2_cost: int = 100

@export var turret_3_scene: PackedScene
@export var turret_3_cost: int = 100

@export var turret_4_scene: PackedScene
@export var turret_4_cost: int = 100

@export var menu_radius: float = 90.0 

@onready var radial_panel: Control = $RadialPanel
@onready var btn_turret_1: Button = $RadialPanel/ButtonTurret1
@onready var btn_turret_2: Button = $RadialPanel/ButtonTurret2
@onready var btn_turret_3: Button = $RadialPanel/ButtonTurret3
@onready var btn_turret_4: Button = $RadialPanel/ButtonTurret4

var current_slot: Node3D = null

func _ready() -> void:
	hide()
	
	btn_turret_1.pressed.connect(_on_turret_1_selected)
	btn_turret_2.pressed.connect(_on_turret_2_selected)
	btn_turret_3.pressed.connect(_on_turret_3_selected)
	btn_turret_4.pressed.connect(_on_turret_4_selected)

	
	_organize_radial_buttons()
	
	if is_instance_valid(train):
		if not train.is_node_ready():
			await train.ready
		
		if train.turret_slots_container:
			for slot in train.turret_slots_container.get_children():
				if slot.has_signal("slot_clicked"):
					slot.slot_clicked.connect(_on_slot_clicked)

func _process(_delta: float) -> void:
	if visible and is_instance_valid(current_slot):
		var camera = get_viewport().get_camera_3d()
		if camera:
			var screen_pos = camera.unproject_position(current_slot.global_position)
			radial_panel.global_position = screen_pos

func _organize_radial_buttons() -> void:
	var buttons: Array[Button] = [btn_turret_1, btn_turret_2, btn_turret_3, btn_turret_4]
	var count = buttons.size()
	
	for i in range(count):
		var btn = buttons[i]
		btn.custom_minimum_size = Vector2(90, 45)
		
		var angle = (i * (2.0 * PI / count)) - (PI / 2.0)
		var offset = Vector2(cos(angle), sin(angle)) * menu_radius
		
		btn.position = offset - (btn.custom_minimum_size / 2.0)

func _on_slot_clicked(slot_node: Node3D) -> void:
	if train.slots_status.get(slot_node) == null:
		current_slot = slot_node
		show()

func _on_turret_1_selected() -> void:
	if is_instance_valid(current_slot):
		if train.place_turret_at_slot(current_slot, turret_1_scene, turret_1_cost):
			hide()

func _on_turret_2_selected() -> void:
	if is_instance_valid(current_slot):
		if train.place_turret_at_slot(current_slot, turret_2_scene, turret_2_cost):
			hide()

func _on_turret_3_selected() -> void:
	if is_instance_valid(current_slot):
		if train.place_turret_at_slot(current_slot, turret_3_scene, turret_3_cost):
			hide()

func _on_turret_4_selected() -> void:
	if is_instance_valid(current_slot):
		if train.place_turret_at_slot(current_slot, turret_4_scene, turret_4_cost):
			hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		hide()
