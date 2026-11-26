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
@export var turret_names: Array[String] = ["Machinegun", "Artillery", "Blast", "Incendiary"]

@export_category("SFX")
@export var random_pitch: bool = true
@export var pitch_min: float = 0.9
@export var pitch_max: float = 1.1

@onready var build_sound: AudioStreamPlayer = $BuildSound

@onready var radial_panel: Control = $RadialPanel
@onready var btn_turret_1: Button = $RadialPanel/MachinegunButton
@onready var btn_turret_2: Button = $RadialPanel/IncendiaryButton
@onready var btn_turret_3: Button = $RadialPanel/BlastButton
@onready var btn_turret_4: Button = $RadialPanel/ArtilleryButton

var current_slot: Node3D = null
var selected_level: int = 1

func _ready() -> void:
	hide()
	_unlock_turrets()
	
	btn_turret_1.pressed.connect(_on_turret_1_selected)
	btn_turret_2.pressed.connect(_on_turret_2_selected)
	btn_turret_3.pressed.connect(_on_turret_3_selected)
	btn_turret_4.pressed.connect(_on_turret_4_selected)

	_organize_radial_buttons()
	
	if is_instance_valid(train):
		if not train.is_node_ready():
			await train.ready
		
		_connect_all_slots()

func _play_build_sound() -> void:
	if not is_instance_valid(build_sound):
		return
	if random_pitch:
		build_sound.pitch_scale = randf_range(pitch_min, pitch_max)
	build_sound.play()

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

func _organize_radial_buttons() -> void:
	var buttons: Array[Button] = [btn_turret_1, btn_turret_2, btn_turret_3, btn_turret_4]
	var count = buttons.size()
	
	for i in range(count):
		var btn = buttons[i]
		btn.custom_minimum_size = Vector2(90, 45)
		
		var angle = (i * (2.0 * PI / count)) - (PI / 2.0)
		var offset = Vector2(cos(angle), sin(angle)) * menu_radius
		
		btn.position = offset - (btn.custom_minimum_size / 2.0)

func _update_button_labels() -> void:
	var scenes: Array[PackedScene] = [turret_1_scene, turret_2_scene, turret_3_scene, turret_4_scene]
	var buttons: Array[Button] = [btn_turret_1, btn_turret_2, btn_turret_3, btn_turret_4]

	for i in buttons.size():
		var scene: PackedScene = scenes[i]
		if scene == null:
			continue

		var t = scene.instantiate()
		var idx: int = clampi(selected_level - 1, 0, t.cost_per_level.size() - 1)
		var cost: int = t.cost_per_level[idx]
		var unlocked: bool = selected_level <= UpgradeManager.level(t.upgrade_key)
		t.free()

		var name_text: String = turret_names[i] if i < turret_names.size() else "Turret"
		var label: Label = buttons[i].get_node_or_null("CostLabel")
		if label:
			label.text = "$%d" % cost
		buttons[i].text = "" % [name_text, cost]
		buttons[i].disabled = not unlocked or MetalManager.get_metal() < cost

func _on_slot_clicked(slot_node: Node3D) -> void:
	if train.slots_status.get(slot_node) == null:
		current_slot = slot_node
		_update_button_labels()
		show()

func _on_level_selected(lvl: int) -> void:
	selected_level = lvl
	_update_button_labels()

func _try_build(scene: PackedScene) -> void:
	if not is_instance_valid(current_slot):
		return
	if train.place_turret_at_slot(current_slot, scene, selected_level):
		_play_build_sound()
		hide()

func _on_turret_1_selected() -> void:
	_try_build(turret_1_scene)

func _on_turret_2_selected() -> void:
	_try_build(turret_2_scene)

func _on_turret_3_selected() -> void:
	_try_build(turret_3_scene)

func _on_turret_4_selected() -> void:
	_try_build(turret_4_scene)

func _unlock_turrets() -> void:
	if GameProgress.is_unlocked("level02"):
		btn_turret_3.visible = true
	if GameProgress.is_unlocked("level03"):
		btn_turret_2.visible = true


func _unhandled_input(event: InputEvent) -> void:
	if visible and event is InputEventMouseButton and event.pressed:
		hide()

func _on_close_button_pressed() -> void:
	hide()
