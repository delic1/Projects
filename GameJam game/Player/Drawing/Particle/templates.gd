extends Node

# Helper function to rotate points
func rotate_points(points, angle):
	var rotated_points = []
	var cos_angle = cos(angle)
	var sin_angle = sin(angle)
	
	for point in points:
		var x_new = point.x * cos_angle - point.y * sin_angle
		var y_new = point.x * sin_angle + point.y * cos_angle
		rotated_points.append(Vector2(x_new, y_new))
	
	return rotated_points

# Generate the points for different directions
var original_triangle = [Vector2(0, 0), Vector2(0.5, 0.6), Vector2(1, 0)]
var east_triangle = original_triangle
var south_triangle = rotate_points(original_triangle, PI / 2)  # 90 degrees clockwise
var west_triangle = rotate_points(original_triangle, PI)       # 180 degrees
var north_triangle = rotate_points(original_triangle, -PI / 2) # 90 degrees counterclockwise

var templates = [
	{"name": "horizontal line", "points": [Vector2(0, 0), Vector2(1, 0)]},
	{"name": "vertical line", "points": [Vector2(0, 0), Vector2(0, 1)]},
	{"name": "circle", "points": generate_circle_points(1, 32)},
	{"name": "simple_lightning", "points": [Vector2(0, 0), Vector2(0.2, -0.707), Vector2(-0.2, -0.707), Vector2(-0, -1.4)]},
	{"name": "triangle_no_bottom_west", "points": north_triangle},
	{"name": "triangle_no_bottom_south", "points": west_triangle},
	{"name": "triangle_no_bottom_east", "points": south_triangle},
	{"name": "triangle_no_bottom_north", "points": east_triangle}
]

# Helper function to generate circle points
func generate_circle_points(radius, segments):
	var points = []
	for i in range(segments):
		var angle = 2 * PI * i / segments
		points.append(Vector2(radius * cos(angle), radius * sin(angle)))
	points.append(points[0])  # Closing the circle
	return points

# Helper function to generate heart points
func generate_heart_points():
	var points = []
	for t in range(0, 360, 10):
		var rad = deg_to_rad(t)
		var x = 0.5 * (16 * pow(sin(rad), 3))
		var y = 0.5 * (13 * cos(rad) - 5 * cos(2 * rad) - 2 * cos(3 * rad) - cos(4 * rad))
		points.append(Vector2(x, -y))  # -y to flip the heart correctly
	points.append(points[0])  # Closing the heart shape
	return points
