extends "canvas.gd"

var max_lines = 10 # then lines2capture 

# capture has less drawing cost 
func lines2capture():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")

	var image = get_viewport().get_texture().get_data()

	image.flip_y()
	image = image.get_rect(get_global_rect())
	
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	texture_normal = tex

	# free Line2D nodes (visible in Remote Scene Tree)
	for index in range(get_child_count()):
		get_child(index).queue_free()



func _on_CanvasOptimized_button_up():
	if get_child_count() > max_lines:
		lines2capture()
