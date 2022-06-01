extends TextureButton 
#https://stackoverflow.com/questions/42889699/smooth-drawing-with-apple-pencil
#https://en.wikipedia.org/wiki/Ramer%E2%80%93Douglas%E2%80%93Peucker_algorithm

signal drawing(line)

var line = preload("line.tscn")
var current_line

var velocity = Vector2.ZERO
var perpendicular_distance = 4
var time = UndoRedo.new()

var points_saved = 0

func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
		current_line.points[-1] = event.position
		var new_velocity = current_line.points[-1]  - current_line.points[-2]
		
		if not velocity: # one time use
			velocity = new_velocity
			
		else:
			var projected = new_velocity.project(velocity)
			# backwards test if new_velocity.dot(velocity) <= 0:?
			
			if (projected - new_velocity).length() > perpendicular_distance :
				velocity = new_velocity
				current_line.add_point(event.position)
			else:
				points_saved +=1
				
#		update()
		
func _on_Canvas_button_down():
	Input.set_use_accumulated_input(false)
	
	current_line = line.instance()
	add_child(current_line)
	current_line.owner = self
	
	current_line.add_point( get_local_mouse_position() ) 
	current_line.add_point( get_local_mouse_position() ) # now there is a line
	
	emit_signal("drawing", current_line)

#func _draw():
#	if current_line and current_line.points:
#		for point in current_line.points:
#			draw_circle(point, 4, Color.red)


func _on_Canvas_button_up():
	Input.set_use_accumulated_input(true)
	
	time.create_action("instance_line")
	time.add_do_reference(current_line) # frees lines when do history lost
	time.add_do_method(self, "add_child", current_line) # Errors
	time.add_undo_method(self, "remove_child", current_line)
	time.commit_action()
	
	print("points save: ", float(points_saved)  / (points_saved + current_line.points.size()))
	points_saved = 0

func clear():
	time.clear_history()
	for line in get_children():
		line.queue_free()
		
# has some limitations, automate with a `max_lines` trigger
func capture_lines(path = ""):
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image = image.get_rect(get_global_rect())
		
	var tex = ImageTexture.new()
	tex.create_from_image(image)

	time.create_action("capture_lines")
	time.add_do_property(self, "texture_normal", tex)
	time.add_undo_property(self, "texture_normal", null)
	time.commit_action()
	
	for index in range(get_child_count()):
		get_child(index).hide() # visible in Remote Scene Tree
	
	if path:
		image.save_png(path)


