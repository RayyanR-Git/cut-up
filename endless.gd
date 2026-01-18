extends Node3D

func _init():
	print("SCRIPT IS LOADING!!!")

func _ready():
	print("=== RoadManager Starting ===")
	print("Step 1: Getting parent...")
	var parent = get_parent()
	print("Parent is: ", parent)
	
	print("Step 2: Looking for Player node...")
	player = parent.get_node_or_null("Player")
	print("Player result: ", player)
	
	if not player:
		print("ERROR: Player not found!")
		print("Available children of parent:")
		for child in parent.get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
		return
	else:
		print("Player found at: ", player.global_position)
	
	print("Step 3: Checking road segment scene...")
	if not road_segment_scene:
		print("ERROR: Road segment scene not assigned!")
		return
	else:
		print("Road segment scene assigned: ", road_segment_scene.resource_path)
	
	print("Segment Length: ", segment_length)
	print("Visible Segments: ", visible_segments)
	
	print("Step 4: Spawning initial segments...")
	for i in range(-2, visible_segments):
		spawn_segment(i)
	
	print("Total segments spawned: ", segments.size())
	print("=== RoadManager Ready ===")
# Road segment scene to spawn
@export var road_segment_scene: PackedScene
@export var segment_length: float = 20.0  # Length of each road piece
@export var visible_segments: int = 5  # How many segments ahead/behind to keep

var player: Node3D
var segments: Array[Node3D] = []
var current_segment_index: int = 0


func _process(_delta):
	if not player:
		return
	
	# Calculate which segment the player is on
	var player_z = player.global_position.z
	var new_index = int(floor(player_z / segment_length))
	
	# Debug print every 60 frames (once per second at 60fps)
	if Engine.get_process_frames() % 60 == 0:
		print("Player Z: %.2f | Current Segment: %d | New Segment: %d | Total Segments: %d" % [player_z, current_segment_index, new_index, segments.size()])
	
	# Check if player moved to a new segment
	if new_index != current_segment_index:
		print(">>> SEGMENT CHANGED from %d to %d! Updating..." % [current_segment_index, new_index])
		current_segment_index = new_index
		update_segments()

func update_segments():
	print("Updating segments...")
	
	# Remove segments that are too far behind
	var min_index = current_segment_index - 2
	var max_index = current_segment_index + visible_segments
	
	print("  Valid range: %d to %d" % [min_index, max_index])
	
	# Remove old segments
	var removed_count = 0
	for segment in segments.duplicate():  # Use duplicate to avoid modification during iteration
		var seg_index = segment.get_meta("segment_index")
		if seg_index < min_index or seg_index > max_index:
			print("  Removing segment %d (out of range)" % seg_index)
			segments.erase(segment)
			segment.queue_free()
			removed_count += 1
	
	if removed_count > 0:
		print("  Removed %d old segments" % removed_count)
	
	# Spawn new segments ahead
	var spawned_count = 0
	for i in range(current_segment_index - 2, current_segment_index + visible_segments):
		if not has_segment(i):
			spawn_segment(i)
			spawned_count += 1
	
	if spawned_count > 0:
		print("  Spawned %d new segments" % spawned_count)
	
	print("  Total active segments: %d" % segments.size())

func spawn_segment(index: int):
	var segment = road_segment_scene.instantiate()
	add_child(segment)
	
	# Position the segment
	segment.global_position = Vector3(0, 0, index * segment_length)
	segment.set_meta("segment_index", index)
	
	segments.append(segment)
	
	print("  Spawned segment %d at Z=%.1f" % [index, segment.global_position.z])

func has_segment(index: int) -> bool:
	for segment in segments:
		if segment.get_meta("segment_index") == index:
			return true
	return false
