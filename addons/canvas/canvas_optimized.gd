extends TextureButton

var line = preload("line.tscn")
var current_line

func _on_Canvas_toggled(button_pressed):
	if button_pressed:
		current_line = line.instance()
		add_child(current_line)
		$CaptureTimer.stop()
	else:
		$CaptureTimer.start()


func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
		current_line.add_point(event.position)


# replace line nodes with capture for less drawing cost (visible in Remote Scene Tree)
func _on_CaptureTimer_timeout():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")

	var image = get_viewport().get_texture().get_data()

	image.flip_y()
	image = image.get_rect(get_global_rect())
	
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	texture_normal = tex

	# free Line2D nodes
	for index in range(1, get_child_count()):
		get_child(index).queue_free()


