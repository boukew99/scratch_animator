extends "canvas.gd"

var max_lines = 500
var max_distance = 20
var bias = 2

func capture_lines():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")

	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image = image.get_rect(get_global_rect())
		
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	texture_normal = tex

	for index in range(get_child_count()):
		get_child(index).hide() # visible in Remote Scene Tree
	
	return image
	
func optimize_line(points : PoolVector2Array):
	var removed_points = 0
	var start_size = points.size()
	var optimized_points = points
	var previous_point = points[0]
	
	for index in range(1, start_size -1):
		var point = points[index]
		var new_direction = points[index] - points[index -1]
		var previous_direction = point - points[index -1]
		
		var distance = previous_point.distance_to(point) * bias # straigth
		var angle = cos(previous_direction.angle_to(new_direction)) # corner
		
		if angle > 0 and ( distance / angle ) > max_distance:
			optimized_points.remove(index - removed_points)
#			print(" angle: ", angle, " distance: ", distance, " check: ", distance / angle)
			previous_point = point
			removed_points += 1
			pos = point
			update()
			
	print("%.2f reduced, %s <-- %s points" %  [removed_points / float(start_size), optimized_points.size(), start_size] )
	return optimized_points
	
func _on_CanvasOptimized_button_down():
	Input.set_use_accumulated_input(true)
	
	
func _on_CanvasOptimized_button_up():
	Input.set_use_accumulated_input(true)
	if current_line.points.size() < 2: 
		current_line.queue_free()
	else:
		current_line.points = optimize_line(current_line.points)
	
	if get_child_count() % max_lines == 0: # every 10 lines
		capture_lines()
		print("capture event")

var pos = Vector2.ZERO


