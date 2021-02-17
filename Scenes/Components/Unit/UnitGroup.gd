extends Node2D
class_name UnitGroup

# Pseudocode from https://www.gamasutra.com/view/feature/3314/coordinated_unit_movement.php?print=1

enum State {
	BROKEN,
	FORMING,
	FORMED
};

# Need to know what positions are available.
# Maybe store a PoolVector2Array, then add to that array each time?
# Automatically sort self into a square, the smallest square possible based on numUnits?
# Ranged units should have higher priority in square, higher health units have lower priority?

# 1. Unit Formation needs to store the general points.
# 2. Unit Formation sends each point to it's unit's one at a time.
# 3. When a unit from Formation hits point, send out next point.
	# a) If point is within bounds of formation, set next path for whole unit cluster, give them each waypoint one at a time.
onready var map : TileMap = get_node("/root/Level/Navigation2D/TileMap")

onready var num_units = 0
onready var units = setup_formation()
onready var target = null
onready var avg_pos = calc_average_unit_position()

func _ready():
	calc_formation_shape_at_position(global_position)

func setup_formation():
	var paths = []
	var priority = 0
	for child in get_children():
		if (child.is_type(Globals.UNIT)):
			paths.push_back(child.get_path())
			child.unit_priority = priority
			priority += 1
			num_units += 1
	return paths
	
func calc_formation_shape_at_position(pos : Vector2):
	
	var dim : Vector2 = Vector2(pow(units.size(), 0.5), pow(units.size(), 0.5) + 1).round()
	
	get_node(units[0]).unit_offset = Vector2(0,0)
	
	
	var last_pos : Vector2 = Vector2(0,0)
	var dir : Vector2 = Vector2(0, -16)
	var step : int = 1
	var step_count = 1
	var steps_finished = 0
	var used : Array = []
	
	var new_pos : Vector2 = dir * 1.0
	for i in range(units.size() - 1):
		
		while (map.get_cellv(map.world_to_map(pos + new_pos)) != 0 or used.has(new_pos)):
			# Increment step until you find it.
			step_count += 1
			if (step_count > step):
				dir = dir.rotated(-deg2rad(90.0))
				step_count = 1
				if (steps_finished == 1):
					steps_finished = 0
					step += 1
				else:
					steps_finished += 1
			last_pos = new_pos
			new_pos = last_pos + dir * 1.0
		
		# we've found it now save it
		new_pos = last_pos + dir * 1.0
		get_node(units[1+i]).unit_offset = new_pos
		used.append(new_pos)
		last_pos = get_node(units[1+i]).unit_offset
	
func _physics_process(delta):
	if (target):
		# Determine state
		for unit_path in units:
			var unit = get_node(unit_path)
			unit.move_along_path(delta)
			
			avg_pos = calc_average_unit_position()


onready var origin : Vector2 = Vector2()
# Handle Manual Path Updating Here
func _input(event):
	if (num_units > 0):
		if (event is InputEventMouseButton):
			if (event.button_index == 1 and event.is_pressed()):
				target = get_global_mouse_position()
				if (Input.is_action_pressed("p_shift")):
					
					var path : PoolVector2Array = calc_path(origin, target)
					extend_path_in_children(path)
					origin = path[-1]
				else:
					var path : PoolVector2Array = calc_path(avg_pos, target)
					set_path_in_children(path)
					origin = path[-1]
					
func calc_path(start : Vector2, end : Vector2) -> PoolVector2Array:
	print(end.snapped(Vector2(16, 16)) + Vector2(8, 8))
	
	calc_formation_shape_at_position(end.snapped(Vector2(16, 16)) + Vector2(8, 8))
	return get_node("/root/Level/Navigation2D").get_simple_path(start, end.snapped(Vector2(16, 16)) + Vector2(8, 8), false)

func calc_average_unit_position() -> Vector2:
	var avg : Vector2 = Vector2()
	var count = 0
	
	for child in get_children():
		avg += child.global_position
		count += 1.0
		
	return avg / count
	
func set_path_in_children(path : PoolVector2Array) -> void:
	for unit_path in units:
		var unit = get_node(unit_path)
		unit.set_path(path)
		
func extend_path_in_children(path : PoolVector2Array) -> void:
	for unit_path in units:
		var unit = get_node(unit_path)
		unit.extend_path(path)
		
		# How can I handle the position offsets?
