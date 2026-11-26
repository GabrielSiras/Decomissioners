extends Control

@export var selected_upgrade_hud: CanvasLayer
@export_category("Labels and Buttons")
@export var upgrade_description: Label
@export var upgrade_name: Label
@export var research_button: Button
@export var refund_button: Button
@export var points_label: Label
@export_subgroup("Unlockable Buttons")
@export var supercharge_button: Button
@export var blast_button: Button
@export var pitch_button: Button
@export var incendiary_button: Button

@export_category("Transição")
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer

var is_changing: bool = false

const SOCKET_GROUPS := {
	"Armor": "ArmorSockets",
	"Artillery": "ArtillerySockets",
	"Blast": "BlastSockets",
	"Bombardment": "BombardmentSockets",
	"Incendiary": "IncendiarySockets",
	"Machinegun": "MachinegunSockets",
	"Magnetism": "MagnetismSockets",
	"Pitch": "PitchSockets",
	"Repair": "RepairSockets",
	"Supercharge": "SuperchargeSockets",
	"Wagons": "WagonsSockets",
	"Transmission": "TransmissionSockets",
}

const UPGRADE_INFO := {
	# Train
	"Armor": "Increases the train's damage reduction.",
	"Magnetism": "Increases the amount of metal salvaged from enemies.",
	"Transmission": "Increases the amount of Energy per wagon.",
	"Wagons": "Adds a new wagon to the train per point spent.",
	# Skills
	"Bombardment": "Improves the Bombardment skill.",
	"Repair": "Improves the Repair skill.",
	"Pitch": "Improves the Pitch skill.",
	"Supercharge": "Improves the Supercharge skill.",
	# Turrets
	"Machinegun": "Allows you to upgrade the Machinegun turret to a higher level.",
	"Artillery": "Allows you to upgrade the Artillery turret to a higher level.",
	"Blast": "Allows you to upgrade the Blast turret to a higher level.",
	"Incendiary": "Allows you to upgrade the Incendiary turret to a higher level.",
}

func _ready() -> void:
	points_label.text = str(UpgradeManager.research_points)
	
	if GameProgress.is_unlocked("level02"):
		supercharge_button.disabled = false
		blast_button.disabled = false
	if GameProgress.is_unlocked("level03"):
		pitch_button.disabled = false
		incendiary_button.disabled = false
		

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	_restore_sockets()

func _restore_sockets() -> void:
	for key in UpgradeManager.upgrades:
		var group_name: String = SOCKET_GROUPS.get(key, "")
		var sockets: Array = get_tree().get_nodes_in_group(group_name)
		var lvl: int = UpgradeManager.upgrades[key]["Level"]
		if sockets.size() < lvl:
			push_warning("ResearchMenu: grupo '%s' tem %d sockets, mas o nível é %d" % [group_name, sockets.size(), lvl])
		for s in sockets.size():
			sockets[s].button_pressed = false
		for s in mini(lvl, sockets.size()):
			sockets[s].button_pressed = true

func _go_to(scene_path: String) -> void:
	if is_changing:
		return
	if not ResourceLoader.exists(scene_path):
		push_warning("ResearchMenu: cena não encontrada: " + scene_path)
		return

	is_changing = true
	_set_buttons_disabled(true)

	if random_pitch:
		metal_click.pitch_scale = randf_range(0.9, 1.1)
	metal_click.play()

	start_timer.one_shot = true
	start_timer.start(click_delay)
	await start_timer.timeout

	get_tree().change_scene_to_file(scene_path)

func _set_buttons_disabled(value: bool) -> void:
	for b in find_children("*", "BaseButton", true, false):
		b.disabled = value

func _update_hud(upgrade_key: String, socket_group: StringName) -> void:
	if not selected_upgrade_hud.visible:
		selected_upgrade_hud.visible = true

	var u: Dictionary = UpgradeManager.upgrades[upgrade_key]
	var is_max: bool = u["Level"] >= u["Max"]

	upgrade_name.text = upgrade_key
	upgrade_description.text = UPGRADE_INFO.get(upgrade_key, "")
	var preview: String = UpgradeManager.preview(upgrade_key)
	if preview != "" and not is_max:
		upgrade_description.text += "\n\n" + preview
	research_button.upgrade_key = upgrade_key
	research_button.socket_group = socket_group

	if is_max:
		research_button.disabled = true
		research_button.text = "MAX"
	else:
		research_button.disabled = UpgradeManager.research_points == 0
		research_button.text = "RESEARCH"

func _on_upgrade_bought() -> void:
	points_label.text = str(UpgradeManager.research_points)
	call_deferred("_refresh_selected")

func _refresh_selected() -> void:
	if selected_upgrade_hud.visible and research_button.upgrade_key != "":
		_update_hud(research_button.upgrade_key, research_button.socket_group)

func _on_main_menu_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_railmap_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _on_refund_button_pressed() -> void:
	var i = 0
	for key in UpgradeManager.upgrades:
		var upgrade: Dictionary = UpgradeManager.upgrades[key]
		if i >= 4:
			UpgradeManager.add_research_points(upgrade["Level"]-1) 
			UpgradeManager.upgrades[key]["Level"] = 1
		else:
			UpgradeManager.add_research_points(upgrade["Level"]) 
			UpgradeManager.upgrades[key]["Level"] = 0
		i += 1
		
	_restore_sockets()
	_refresh_selected()
	points_label.text = str(UpgradeManager.research_points)

func _turn_off_hud() -> void:
	selected_upgrade_hud.visible = false
