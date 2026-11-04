class_name SpawnEntry
extends Resource

enum Mode { CHUNK, SHOULDER_BEHIND, AIR }

@export var scene: PackedScene
@export var weight: float = 1.0
@export var mode: Mode = Mode.CHUNK
