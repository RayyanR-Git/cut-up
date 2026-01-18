extends Node3D

@export var road_segment_scene: PackedScene
@export var segment_length: float = 20.0
@export var visible_segments: int = 5

var player: Node3D
var segments: Array[Node3D] = []
var current_segment_index: int = 0

func _ready():
	# Find the Player node in the Main scene
	player = get_parent().get_node_or_null("Player")
	
	if not player:
		push_error("RoadManager: Player not found! Make sure Main has a child named 'Player'.")
		return
	
	if not road_segment_scene:
		push_error("RoadManager: Road segment scene not assigned!")
		return
	
	# Spawn initial segments around the player
	for i in range(-2, visible_segments):
		spawn_segment(i)

func _process(_delta):
	if not player:
		return
	
	# Determine which segment index the player is currently over (along Z)
	var player_z = player.global_position.z
	var new_index = int(floor(player_z / segment_length))
	
	if new_index != current_segment_index:
		current_segment_index = new_index
		update_segments()

func update_segments():
	var min_index = current_segment_index - 2
	var max_index = current_segment_index + visible_segments
	
	# Remove segments that are too far behind or ahead
	for segment in segments.duplicate():
		var seg_index = segment.get_meta("segment_index")
		if seg_index < min_index or seg_index > max_index:
			segments.erase(segment)
			segment.queue_free()
	
	# Ensure we have all segments from min_index to max_index
	for i in range(min_index, max_index):
		if not has_segment(i):
			spawn_segment(i)

func spawn_segment(index: int):
	var segment = road_segment_scene.instantiate()
	add_child(segment)
	
	# Position each segment along Z
	segment.global_position = Vector3(0, 0, index * segment_length)
	segment.set_meta("segment_index", index)
	segments.append(segment)

func has_segment(index: int) -> bool:
	for segment in segments:
		if segment.get_meta("segment_index") == index:
			return true
	return false
