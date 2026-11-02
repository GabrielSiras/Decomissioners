extends CanvasLayer

@export var close_button: Button

func _ready() -> void:
	close_button.pressed.connect(_on_closed_button_pressed)

func _process(delta: float) -> void:
	pass

func _on_closed_button_pressed() -> void:
	queue_free()
