extends Node2D

var mouse_left_down: bool = false
var distance_to_spawn : float = 10.0
var last_spawn_position : Vector2 = Vector2(-100, -100)

var drawing_positions = []

signal attacked(gesture_name)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.is_pressed():
			mouse_left_down = true
			drawing_positions.clear()
		elif event.button_index == 1 and not event.is_pressed():
			mouse_left_down = false
			
			if drawing_positions.size() > 4:
				var gesture_name = recognize(drawing_positions)
				emit_signal("attacked", gesture_name)
			

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	if mouse_left_down && last_spawn_position.distance_to(mouse_position) > distance_to_spawn:
		spawnParticle(mouse_position)

func spawnParticle(mouse_position):
	last_spawn_position = mouse_position
	drawing_positions.append(mouse_position)

const NUM_POINTS = 32
const SQUARE_SIZE = 250.0

var templates = []
# Predefined gesture templates
func _ready():
	var ShapeTemplates = preload("res://Player/Drawing/Particle/templates.gd").new()
	templates = ShapeTemplates.templates

# Function to recognize the gesture
func recognize(points):
	points = resample(points, NUM_POINTS)
	drawing_positions = points
	
	
	points = scale_to_square(points, SQUARE_SIZE)
	drawing_positions = points
	
	
	points = translate_to_origin(points)
	drawing_positions = points
	
	
	var b = INF
	var best_template = null
	var my_dict = {}
	for template in templates:
		var t_points = resample(template["points"], NUM_POINTS)
		t_points = scale_to_square(t_points, SQUARE_SIZE)
		t_points = translate_to_origin(t_points)
		var d = path_distance(points, t_points)
		var key=template["name"]
		if my_dict.has(key):
			if d > my_dict[key]:
				my_dict[key] = d
		else:
			my_dict[key] = d
		if d < b:
			b = d
			best_template = template
	if(b>80):
		return "no shape"
	
	return best_template["name"]

# Resample the points to a fixed number
func resample(points, total_points):
	var initial_points = points
	var interval = path_length(initial_points) / float(total_points - 1)
	var total_length = 0.0
	var new_points = [initial_points[0]]
	
	var i = 1
	while i < initial_points.size():
		var current_length = initial_points[i - 1].distance_to(initial_points[i])
		if (total_length + current_length) >= interval:
			var qx = initial_points[i - 1].x + ((interval - total_length) / current_length) * (initial_points[i].x - initial_points[i - 1].x)
			var qy = initial_points[i - 1].y + ((interval - total_length) / current_length) * (initial_points[i].y - initial_points[i - 1].y)
			var q = Vector2(qx, qy)
			new_points.append(q)
			initial_points.insert(i, q)
			total_length = 0.0
		else:
			total_length += current_length
		i += 1
	
	if new_points.size() == total_points - 1:
		new_points.append(points[points.size() - 1])
		
	return new_points

# Calculate the total length of the path
func path_length(points):
	var d = 0.0
	for i in range(1, points.size()):
		d += points[i].distance_to(points[i - 1])
	
	return d

func get_centroid(points):
	var x_sum = 0.0
	var y_sum = 0.0
	for point in points:
		x_sum += point.x
		y_sum += point.y
	return Vector2(x_sum / points.size(), y_sum / points.size())

func scale_to_square(points, size):
	var B = bounding_box(points)
	
	# Calculate scale factors
	var scale_x = size / B.size.x
	var scale_y = size / B.size.y
	
	# Determine the scale factor to maintain aspect ratio
	var scale_factor = min(scale_x, scale_y)
	
	# Scale points
	var new_points = []
	for point in points:
		var qx = (point.x - B.position.x) * scale_factor
		var qy = (point.y - B.position.y) * scale_factor
		new_points.append(Vector2(qx, qy))
	
	# Calculate the new bounding box of the scaled points
	var new_bbox = bounding_box(new_points)
	
	# Calculate the offset to center the points in the square
	var offset_x = (size - new_bbox.size.x) / 2
	var offset_y = (size - new_bbox.size.y) / 2
	
	# Translate points to center within the square
	for i in range(len(new_points)):
		new_points[i].x += offset_x
		new_points[i].y += offset_y
	
	return new_points


func bounding_box(points):
	var min_x = INF
	var min_y = INF
	var max_x = -INF
	var max_y = -INF
	 
	for point in points:
		if point.x < min_x:
			min_x = point.x
		if point.y < min_y:
			min_y = point.y
		if point.x > max_x:
			max_x = point.x
		if point.y > max_y:
			max_y = point.y
	
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

# Translate points to the origin
func translate_to_origin(points):
	var centroid = get_centroid(points)
	var new_points = []
	for point in points:
		var qx = point.x - centroid.x
		var qy = point.y - centroid.y
		new_points.append(Vector2(qx, qy))
	
	return new_points

# Calculate the average distance between corresponding points in two paths
func path_distance(a, b):
	
	var min_distance = INF
	
	for offset in range(0, NUM_POINTS + 1, 2):
		var forward_distance = calculate_offset_distance(a, b, offset)
		var reverse_distance = calculate_offset_distance(a, b, offset, true)
		#forward_distance=forward_distance*forward_distance
		#reverse_distance=reverse_distance*reverse_distance
		if forward_distance < min_distance:
			min_distance = forward_distance
		
		if reverse_distance < min_distance:
			min_distance = reverse_distance
	
	return min_distance

func calculate_offset_distance(a, b, offset, reverse = false):
	var d = 0.0
	var size = a.size()
	
	for i in range(size):
		var a_index = i
		var b_index = (i + offset) % size
		
		if reverse:
			b_index = (size - 1 - b_index) % size
		
		d += a[a_index].distance_to(b[b_index])
	
	return d / size
