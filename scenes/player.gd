extends VehicleBody3D

@export var STEER_SPEED = 2.0
@export var STEER_LIMIT = 0.4
@export var engine_force_value = 50

var steer_target = 0
var crashed = false

func _ready():
	# Add to player group
	add_to_group("player")
	
	# Connect collision
	body_entered.connect(_on_body_entered)
	
	# Set collision layers
	collision_layer = 1  # Layer 1
	collision_mask = 2   # Detect Layer 2 (traffic)
	
	print("Player ready. Collision detection set up.")

func _physics_process(delta):
	if crashed:
		engine_force = 0
		brake = 3
		
		# Auto-reset after 2 seconds
		await get_tree().create_timer(2.0).timeout
		reset_car()
		return
	
	var speed = linear_velocity.length()
	traction(speed)
	
	# Steering
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= STEER_LIMIT
	
	# Forward
	if Input.is_action_pressed("ui_down"):
		if speed < 5 and speed != 0:
			engine_force = clamp(engine_force_value * 3 / speed, 0, 300)
		else:
			engine_force = engine_force_value
	else:
		engine_force = 0
	
	# Reverse/Brake
	if Input.is_action_pressed("ui_up"):
		if speed < 5 and speed != 0:
			engine_force = -clamp(engine_force_value * 5 / speed, 0, 200)
		else:
			engine_force = -engine_force_value * 0.5
	
	# Handbrake
	if Input.is_action_pressed("ui_select"):
		brake = 2.5
		$wheal2.wheel_friction_slip = 0.8
		$wheal3.wheel_friction_slip = 0.8
	else:
		brake = 0.0
		$wheal2.wheel_friction_slip = 3.0
		$wheal3.wheel_friction_slip = 3.0
	
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

func traction(speed):
	apply_central_force(Vector3.DOWN * speed * 2)

func _on_body_entered(body: Node):
	print("!!! PLAYER COLLISION !!!")
	print("Hit: ", body.name)
	print("Body class: ", body.get_class())
	
	if body.is_in_group("traffic"):
		print(">>> CRASHED INTO TRAFFIC! <<<")
		crashed = true
		crash_effect()

func crash_effect():
	# Slow down
	linear_velocity *= 0.2
	
	# Spin out
	apply_torque_impulse(Vector3(0, randf_range(-20, 20), 0))
	
	print("CRASH! Resetting in 2 seconds...")

func reset_car():
	# Reset position and velocity
	global_position = Vector3(0, 2, global_position.z - 10)
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	rotation = Vector3.ZERO
	crashed = false
	print("Car reset!")
