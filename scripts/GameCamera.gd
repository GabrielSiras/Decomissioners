extends Camera2D

func _ready() -> void:
	make_current()
	
func set_camera_zoom(new_zoom: float) -> void:
	zoom = Vector2(new_zoom, new_zoom)
