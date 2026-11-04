extends Control

@export var selected_upgrade_hud: CanvasLayer
@export_category("Labels")
@export var upgrade_description: Label
@export var upgrade_name: Label
@export var upgrade_cost: Label
@export_category("Upgrade Costs")
@export_subgroup("Train")
@export var life: int = 0
@export var armor: int = 0
@export var power: int = 0
@export var wagon_size: int = 0
@export var acceleration: int = 0
@export_subgroup("Skills")
@export var bombardment: int = 0
@export var pitch: int = 0
@export var supercharge: int = 0
@export_subgroup("Turrets")
@export var machinegun_turret: int = 0
@export var artillery_turret: int = 0
@export var incendiary_turret: int = 0
@export var blast_turret: int = 0

@export_category("Transição")
@export var click_delay: float = 0.55
@export var random_pitch: bool = true

@onready var metal_click: AudioStreamPlayer = $MetalClick
@onready var start_timer: Timer = $StartTimer
var is_changing: bool = false

func _ready() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

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

func _update_hud(button_name: String) -> void:
	if not selected_upgrade_hud.visible:
		selected_upgrade_hud.visible = true
	match button_name:
		#Train Atributes
		"LifeButton":
			upgrade_name.text = "Life"
			upgrade_description.text = "Increases the life of the Train and wagons, 
										allowing them to take more hits."
			upgrade_cost.text = str(life)
		"ArmorButton":
			upgrade_name.text = "Armor"
			upgrade_description.text = "Increases the Train's and wagons' armor damage reduction."
			upgrade_cost.text = str(armor)
		"PowerButton":
			upgrade_name.text = "Power"
			upgrade_description.text = "Increases the Train's power, allowing it to pull more weight."
			upgrade_cost.text = str(power)
		"WagonSizeButton":
			upgrade_name.text = "Wagon Size"
			upgrade_description.text = "Unlocks longer wagon options for purchase at the pre-game phase. " + "Longer wagon's have extra turret slots and can carry more metal."
			upgrade_cost.text = str(wagon_size)
		"AccelButton":
			upgrade_name.text = "Acceleration"
			upgrade_description.text = "Increases the Train's acceleration, allowing it to speed up or slow down more efficiently."
			upgrade_cost.text = str(acceleration)
			
		#Skills
		"BombardmentButton":
			upgrade_name.text = "Bombardment"
			upgrade_description.text = "Increases the damage of the Bombardment skill."
			upgrade_cost.text = str(bombardment)
		"PitchButton":
			upgrade_name.text = "Pitch"
			upgrade_description.text = "Increases the slow effect of the Pitch skill."
			upgrade_cost.text = str(pitch)
		"SuperchargeButton":
			upgrade_name.text = "Supercharge"
			upgrade_description.text = "Increases the damage and attack speed buff of the Supercharge skill."
			upgrade_cost.text = str(supercharge)
			
		#Turrets:
		"MachinegunButton":
			upgrade_name.text = "Machinegun"
			upgrade_description.text = "Unlocks a higher level of the Machinegun turret."
			upgrade_cost.text = str(machinegun_turret)
		"ArtilleryButton":
			upgrade_name.text = "Artillery"
			upgrade_description.text = "Unlocks a higher level of the Artillery turret."
			upgrade_cost.text = str(artillery_turret)
		"IncendiaryButton":
			upgrade_name.text = "Incendiary"
			upgrade_description.text = "Unlocks a higher level of the Incendiary turret."
			upgrade_cost.text = str(incendiary_turret)
		"BlastButton":
			upgrade_name.text = "Blast"
			upgrade_description.text = "Unlocks a higher level of the Blast turret."
			upgrade_cost.text = str(blast_turret)

func _on_main_menu_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/MainMenu.tscn")

func _on_railmap_button_pressed() -> void:
	_go_to("res://scenes/UI-UX/UI/MENUs/RailmapMenu.tscn")

func _turn_off_hud() -> void:
	selected_upgrade_hud.visible = false
