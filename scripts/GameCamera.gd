class_name GameCamera
extends Camera3D

@export var fixed_y_height: float = 15.0

func _ready() -> void:
	# Define esta câmera como a câmera ativa da cena principal
	make_current()
	
	# Garante a rotação de -90 graus olhado direto para baixo
	rotation_degrees = Vector3(-75, 0, 0)
	
	# Ajusta a altura no eixo Y mantendo X e Z na posição configurada
	global_position.y = fixed_y_height

## Caso queira alterar a altura da câmera (zoom de distância vertical) via código:
func set_height(new_height: float) -> void:
	fixed_y_height = new_height
	global_position.y = fixed_y_height
