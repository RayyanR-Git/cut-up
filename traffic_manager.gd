extends Node3D

@export var traffic_car_scene: PackedScene
@export var spawn_interval: float = 1.5
@export var spawn_distance: float = 80.0

# 4 lane X positions: left two, right two
@export var lanes: PackedFloat32Array = PackedFloat32Array([-7.0, -2.0, 2.0, 7.0])

var player: Node3D
var timer: float = 0.0

func _ready():
	randomize() # ensure randi() is not always the same
	player = get_parent().get_node_or_null("Player")
	if not player:
		push_error("TrafficManager: Player not found! Make sure Main has a child named 'Player'.")
	if not traffic_car_scene:
		push_error("TrafficManager: traffic_car_scene not assigned!")

func _physics_process(delta):
	if not player or not traffic_car_scene:
		return

	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_traffic_car()

func spawn_traffic_car():
	# pick random lane 0..3
	var lane_index := randi() % lanes.size()
	var x_pos := lanes[lane_index]

	var car: Node3D = traffic_car_scene.instantiate()
	add_child(car)

	# spawn ahead of player
	var spawn_pos := player.global_position
	spawn_pos.x = x_pos
	spawn_pos.z += spawn_distance
	car.global_position = spawn_pos

	# LEFT lanes (0,1) move backward, RIGHT lanes (2,3) move forward
	if lane_index <= 1:
		car.speed = -20.0  # backward along Z
	else:
		car.speed = 20.0   # forward along Z

	# DEBUG: see that speed is set
	print("Spawned car in lane ", lane_index, " with speed ", car.speed)
