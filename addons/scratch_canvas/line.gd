extends Line2D
#https://stackoverflow.com/questions/42889699/smooth-drawing-with-apple-pencil
#https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm

export var perpendicular_distance = 3 # set on sparse line
var velocity = Vector2.ZERO
var points_saved = 0

func add_point_sparsely(point):
	points[-1] = point
	var new_velocity = points[-1]  - points[-2]
	
	if not velocity: # one time use
		velocity = new_velocity
		
	else:
		var projected = new_velocity.project(velocity)
		# backwards test if new_velocity.dot(velocity) <= 0:?
		
		if (projected - new_velocity).length() > perpendicular_distance :
			velocity = new_velocity
			add_point(point)
		else:
			points_saved+=1

#func _draw():
#	if current_line and current_line.points:
#		for point in current_line.points:
#			draw_circle(point, 4, Color.red)
