extends Node3D

@export var traffic_car_scene: PackedScene
@export var spawn_interval: float = 2.0
@export var max_cars: int = 20
@export var spawn_distance_ahead: float = 100.0
@export var spawn_distance_behind: float = 100.0
@export var despawn_distance: float = 150.0

var player: Node3D
var spawn_timer: float = 0.0
var traffic_cars: Array[Node3D] = []

# Lane configuration:
# Lanes 0,1 (left side): -7.5, -2.5 → GO BACKWARD (oncoming traffic)
# Lanes 2,3 (right side): 2.5, 7.5 → GO FORWARD (same direction as player)
var lanes = [-7.5, -2.5, 2.5, 7.5]
var forward_lanes = [2, 3]  # Indices for forward lanes
var backward_lanes = [0, 1]  # Indices for backward lanes

func _ready():
	print("=== TrafficManager Starting ===")
	
	player = get_parent().get_node_or_null("Player")
	
	if not player:
		print("ERROR: Player not found!")
		return
	else:
		print("Player found!")
	
	if not traffic_car_scene:
		print("ERROR: Traffic car scene NOT assigned!")
		return
	else:
		print("Traffic car scene assigned!")
	
	# Spawn some initial traffic
	spawn_initial_traffic()
	
	print("TrafficManager ready!")

func _process(delta):
	if not player:
		return
	
	# Spawn timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_traffic_car()
	
	# Cleanup old cars
	cleanup_old_cars()

func spawn_initial_traffic():
	# Spawn some cars ahead (forward lanes)
	for i in range(3):
		spawn_traffic_at_position(true, randf_range(20, 80))
	
	# Spawn some oncoming cars (backward lanes)
	for i in range(3):
		spawn_traffic_at_position(false, randf_range(20, 80))

func spawn_traffic_car():
	if traffic_cars.size() >= max_cars:
		return
	
	# Randomly choose forward or backward traffic (50/50 chance)
	var going_forward = randf() > 0.5
	spawn_traffic_at_position(going_forward, spawn_distance_ahead if going_forward else spawn_distance_ahead)

func spawn_traffic_at_position(going_forward: bool, distance: float):
	# Choose lane based on direction
	var lane_index: int
	if going_forward:
		# Right lanes (2 or 3)
		lane_index = forward_lanes[randi() % forward_lanes.size()]
	else:
		lane_index = backward_lanes[randi() % backward_lanes.size()]
	
	var lane_x = lanes[lane_index]
	
	# Calculate spawn position
	var spawn_z: float
	if going_forward:
		# Spawn ahead for cars going same direction
		spawn_z = player.global_position.z + distance
	else:
		# Spawn ahead for oncoming traffic too (they'll drive toward you)
		spawn_z = player.global_position.z + distance
	
	# Create car
	var car = traffic_car_scene.instantiate()
	add_child(car)
	
	# Position it
	car.global_position = Vector3(lane_x, 1.0, spawn_z)
	car.set_lane(lane_index, going_forward)
	
	# Random color
	randomize_car_color(car)
	
	# Add to tracking
	traffic_cars.append(car)
	
	var direction_text = "FORWARD" if going_forward else "BACKWARD"
	print("Spawned %s traffic in lane %d at Z=%.1f" % [direction_text, lane_index, spawn_z])

func randomize_car_color(car: Node3D):
	var colors = [Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.WHITE, Color.ORANGE, Color.PURPLE]
	var mesh = car.get_node_or_null("MeshInstance3D")
	if mesh:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = colors[randi() % colors.size()]
		mesh.material_override = mat

func cleanup_old_cars():
	if not player:
		return
	
	for car in traffic_cars.duplicate():
		var distance_from_player = abs(car.global_position.z - player.global_position.z)
		
		# Despawn if too far away
		if distance_from_player > despawn_distance:
			traffic_cars.erase(car)
			car.queue_free()
