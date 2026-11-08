extends Button

signal upgrade_bought

var upgrade_key: String
var socket_group: StringName

func _ready() -> void:
	upgrade_bought.connect(owner._on_upgrade_bought)

func _on_button_pressed() -> void:
	var upgrade_sockets: Array = get_tree().get_nodes_in_group(socket_group)
	
	if UpgradeManager.upgrades[upgrade_key]["Level"] == UpgradeManager.upgrades[upgrade_key]["Max"] - 1:
		disabled = true
		text = "MAX"
	UpgradeManager.research_points -= 1
	upgrade_bought.emit()
	upgrade_sockets[UpgradeManager.upgrades[upgrade_key]["Level"]].button_pressed = true
	UpgradeManager.upgrades[upgrade_key]["Level"] += 1
	print(UpgradeManager.upgrades[upgrade_key]["Level"])
