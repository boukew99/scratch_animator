extends TextureButton 
#https://stackoverflow.com/questions/42889699/smooth-drawing-with-apple-pencil
#https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm
signal drawing(line)

var line = preload("line.tscn")
var current_line

var max_distance = 20 * 2
var bias = 2 * 2
var pos = Vector2.ZERO
var last_point = Vector2.ZERO

func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
#		current_line.add_point(event.position)
		var previous_point = current_line.points[ current_line.get_point_count() -1 ]
		var new_direction = event.position - previous_point
		var previous_direction = previous_point - current_line.points[ current_line.get_point_count() -2 ]
		
		var distance = previous_point.distance_to(event.position) * bias # straigth
		var angle =  cos(previous_direction.angle_to(new_direction)) # corner
		
		if angle < 0 or ( distance / angle ) > max_distance:
			current_line.add_point(event.position)
			last_point = event.position
			pos = event.position
			update()
			
#		var previous_point = current_line.points[ current_line.get_point_count() -1 ]
#		var new_direction = event.position - previous_point
#
#		var distance = previous_point.distance_to(event.position)
#		var angle =  cos(previous_directon.angle_to(new_direction))

	
func _on_Canvas_button_down():
	current_line = line.instance()
	current_line.add_point( get_local_mouse_position() )
	last_point = get_local_mouse_position()
	add_child(current_line)
	emit_signal("drawing", current_line)


#func _draw():
#	draw_circle(last_point, 4, Color.red)
#	if current_line and current_line.points:
#		for point in current_line.points:
#			draw_circle(point, 4, Color.red)
#
#
#	draw_arc(pos, max_distance, -PI /2, PI/2, 25, Color.red, 2)
#	draw_arc(pos, max_distance / bias, -PI/2, PI/2, 25, Color.red, 2)


func _on_Canvas_button_up():
	current_line.add_point( get_local_mouse_position() )
