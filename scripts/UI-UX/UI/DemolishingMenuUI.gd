class_name DemolishingMenuUI
extends Control

@export var train: TrainHead
@export var menu_offset_y: float = 65.0 

@onready var radial_panel: Control = $RadialPanel
@onready var btn_demolish: Button = $RadialPanel/ButtonDemolish

var current_slot: Node3D = null

func _ready() -> void:
	hide()
	
	btn_demolish.pressed.connect(_on_demolish_selected)
	
	btn_demolish.set_anchors_preset(Control.PRESET_TOP_LEFT)
	btn_demolish.custom_minimum_size = Vector2(80, 50)
	btn_demolish.size = btn_demolish.custom_minimum_size
	
	btn_demolish.position = Vector2(-btn_demolish.size.x / 2.0, menu_offset_y)
	
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

func _on_slot_clicked(slot_node: Node3D) -> void:
	if train.slots_status.get(slot_node) != null:
		current_slot = slot_node
		_update_button_text()
		show()
	else:
		hide()

func _update_button_text() -> void:
	if is_instance_valid(current_slot):
		var turret = train.slots_status.get(current_slot)
		if is_instance_valid(turret) and "build_cost" in turret:
			var refund = int(turret.build_cost * 0.3)
			btn_demolish.text = "Demolish turret? Refund: $" + str(refund)
		else:
			btn_demolish.text = "Demolish turret?"

func _on_demolish_selected() -> void:
	if is_instance_valid(current_slot):
		train.demolish_turret_at_slot(current_slot)
		hide()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		hide()
