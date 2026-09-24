extends HBoxContainer

@export var metal_manager: MetalManager
@onready var metal_label: Label = $MetalLabel

func _ready() -> void:
	if typeof(MetalManager) != TYPE_NIL and not metal_manager:
		_connect_manager(MetalManager)
	elif metal_manager:
		_connect_manager(metal_manager)

func _connect_manager(manager: Node) -> void:
	if manager.has_signal("metal_changed"):
		manager.metal_changed.connect(_on_metal_changed)
		_on_metal_changed(manager.total_metal)

func _on_metal_changed(new_amount: int) -> void:
	if metal_label:
		metal_label.text = str(new_amount)
