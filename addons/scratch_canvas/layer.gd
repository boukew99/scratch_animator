extends Node2D

export(PackedScene) var line = preload("line.tscn")
var undo_redo = UndoRedo.new()

func add_line():
#	print("points saved: ", float(current_line.points_saved)  / (current_line.points_saved + current_line.points.size()))
	var current_line = line.instance()
	current_line.points = [get_local_mouse_position(), get_local_mouse_position()]

	undo_redo.create_action("instance_line")
	undo_redo.add_do_reference(current_line) # frees removed lines when clearing history
	undo_redo.add_do_method(self, "add_child", current_line) 
	undo_redo.add_undo_method(self, "remove_child", current_line)
	undo_redo.commit_action()
	
	current_line.owner = self
	return current_line # use current_line.add_point_sparsely(point)


# has some limitations, automate with a `max_lines` trigger
func capture_lines(path = ""):
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")
	
	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image = image.get_rect(owner.get_global_rect())
		
	var tex = ImageTexture.new()
	tex.create_from_image(image)

	undo_redo.create_action("capture_lines")
	undo_redo.add_do_property(self, "texture_normal", tex)
	undo_redo.add_undo_property(self, "texture_normal", null)
	undo_redo.commit_action()
	
	for index in range(get_child_count()):
		get_child(index).hide() # visible in Remote Scene Tree
	
	if path:
		image.save_png(path)
