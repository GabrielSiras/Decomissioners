class_name SpawnEntry
extends Resource

enum Mode { CHUNK, SHOULDER_BEHIND, AIR }

@export var scene: PackedScene
@export var weight: float = 1.0
@export var mode: Mode = Mode.CHUNK

@export_category("Faixa lateral (distância do centro do trem)")
@export var use_lane: bool = true
@export var lane_min_x: float = 4.0
@export var lane_max_x: float = 6.5
