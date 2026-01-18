extends Node3D

@export var follow_target_path: NodePath = ^"../Player"
@export var lock_y: float = 0.0   # height where the ground should stay

var target: Node3D

func _ready():
	target = get_node_or_null(follow_target_path)
	if not target:
		push_error("BackgroundGround: follow_target not found!")

func _physics_process(_delta):
	if not target:
		return

	# Copy player X/Z, keep fixed Y so the plane is always under/behind
	var pos := global_position
	pos.x = target.global_position.x
	pos.z = target.global_position.z
	pos.y = lock_y-3
	global_position = pos
