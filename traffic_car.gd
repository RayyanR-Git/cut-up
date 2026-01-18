extends Node3D

@export var speed: float = 20.0

func _physics_process(delta):
	# Move along global Z every physics frame
	global_position.z += speed * delta
