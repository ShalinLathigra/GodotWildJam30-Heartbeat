extends Area2D
#extends RigidBody2D
class_name Unit
# travel speed in pixel/s
export var speed : int = 100
onready var unit_priority : float = -1
onready var unit_offset : Vector2 = Vector2()

# at which distance to stop moving
# NOTE: setting this value too low might result in jerky movement near destination
const eps = 2.5

func _ready():
	# Snap position to grid
	pass

# points in the path
var points : PoolVector2Array = PoolVector2Array([])

func set_path(path):
	$AnimatedSprite.add_state(Globals.state.RUN)
	points = path
	
	var dist = (global_position - points[0]).length_squared()
	
	var removed = []
	for i in range(points.size() - 1):
		if (global_position - points[i]).length_squared() < dist:
			removed.append(i)
			
	for i in range(removed.size()):
		points.remove(removed[i] - i)
	
	
func extend_path(path : PoolVector2Array) -> void:
	points.resize(points.size() - 1)
	points.append_array(path)

func move_along_path(delta):
	if points.size() > 1:
		var distance = points[1] - get_global_position()
		if (points.size() == 2):
			 distance += unit_offset
		var direction = distance.normalized() # direction of movement
		if distance.length() > eps and points.size() > 1:
			global_position += direction*speed * delta
			$AnimatedSprite.flip_h = direction.x < 0
		else:
			points.remove(0)
			if (points.size() <= 1):
				$AnimatedSprite.pop_state()
		update() # we update the node so it has to draw it self again
func _draw():
	# if there are points to draw
	if points.size() > 1:
		for p in points:
			draw_circle(p - get_global_position(), 2, Color(1, 0, 0)) # we draw a circle (convert to global position first)

func get_type(): return "Unit"
func is_type(type): return type == "Unit" or .is_type(type)
