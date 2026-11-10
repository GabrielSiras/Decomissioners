extends Control

@export var selected_upgrade_hud: CanvasLayer
@export_category("Labels and Buttons")
@export var upgrade_description: Label
@export var upgrade_name: Label
@export var research_button: Button
@export var points_label: Label

@export_category("Transição")
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer

var is_changing: bool = false

func _ready() -> void:
	points_label.text = str(UpgradeManager.research_points)
	
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	var upgrade_sockets: Array[Array]
	upgrade_sockets.append(get_tree().get_nodes_in_group("ArmorSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("MagnetismSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("TransmissionSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("WagonsSocket"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("BombardmentSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("RepairSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("PitchSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("SuperchargeSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("MachinegunSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("ArtillerySockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("BlastSockets"))
	upgrade_sockets.append(get_tree().get_nodes_in_group("IncendiarySockets"))
	
	var i = 0
	for upgrade in UpgradeManager.upgrades:
		var s = 0
		var key_value = UpgradeManager.upgrades[upgrade]
		while s < key_value["Level"]:
			upgrade_sockets[i][s].button_pressed = true
			s += 1
		i += 1
	

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
	if UpgradeManager.upgrades[upgrade_key]["Level"] == UpgradeManager.upgrades[upgrade_key]["Max"]:
		research_button.disabled = true
		research_button.text = "MAX"
	else:
		if UpgradeManager.research_points == 0:
			research_button.disabled = true
		else:
			research_button.disabled = false
		research_button.text = "Research"
		match upgrade_key:
			
			# Train Atributes
			"Armor":
				upgrade_name.text = "Armor"
				upgrade_description.text = "Increases the Train's and wagons' armor damage reduction."
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Magnetism":
				upgrade_name.text = "Magnetism"
				upgrade_description.text = "placeholder"
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Transmission":
				upgrade_name.text = "Transmission"
				upgrade_description.text = "placeholder"
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Wagons":
				upgrade_name.text = "Wagons"
				upgrade_description.text = "placeholder"
				
			# Skills
			"Bombardment":
				upgrade_name.text = "Bombardment"
				upgrade_description.text = "Increases the damage of the Bombardment skill."
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Repair":
				upgrade_name.text = "Repair"
				upgrade_description.text = "placeholder"
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Pitch":
				upgrade_name.text = "Pitch"
				upgrade_description.text = "Increases the slow effect of the Pitch skill."
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
			"Supercharge":
				upgrade_name.text = "Supercharge"
				upgrade_description.text = "Increases the damage and attack speed buff of the Supercharge skill."
				upgrade_description.text += "\n\n" + UpgradeManager.preview(upgrade_key)
				
			# Turrets:
			"Machinegun":
				upgrade_name.text = "Machinegun"
				upgrade_description.text = "Unlocks a higher level of the Machinegun turret."
			"Artillery":
				upgrade_name.text = "Artillery"
				upgrade_description.text = "Unlocks a higher level of the Artillery turret."
			"Blast":
				upgrade_name.text = "Blast"
				upgrade_description.text = "Unlocks a higher level of the Blast turret."
			"Incendiary":
				upgrade_name.text = "Incendiary"
				upgrade_description.text = "Unlocks a higher level of the Incendiary turret."
		research_button.upgrade_key = upgrade_key
		research_button.socket_group = socket_group

func _on_upgrade_bought() -> void:
	points_label.text = str(UpgradeManager.research_points)

func _on_main_menu_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_railmap_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _turn_off_hud() -> void:
	selected_upgrade_hud.visible = false
