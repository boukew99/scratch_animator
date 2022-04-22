extends Control

var canvas = preload("res://addons/canvas/canvas_with_background.tscn")

onready var frames = $VBoxContainer/TabContainer

func _on_Next_pressed():
	frames.current_tab = clamp(frames.current_tab + 1, 0, frames.get_child_count())


func _on_Prev_pressed():
	frames.current_tab  = clamp(frames.current_tab - 1, 0, frames.get_child_count())


func _on_Tag_text_entered(new_text):
	frames.get_current_tab_control().name = new_text


func _on_Sub_pressed():
	frames.get_current_tab_control().queue_free()


func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = "0"
	frames.add_child(inst, true)
	_on_Next_pressed()


func _on_TabContainer_tab_changed(tab):
	$VBoxContainer/HBoxContainer/Tag.text = frames.get_child(tab).name


func _on_FPS_value_changed(value):
	$FPSTimer.wait_time = 1 / value


func _on_Play_toggled(button_pressed):
	if button_pressed:
		$FPSTimer.start()
	else:
		$FPSTimer.stop()


func _on_FPSTimer_timeout():
	frames.current_tab = wrapi(frames.current_tab + 1, 0, frames.get_child_count())


func _on_Save_pressed():
	$FileDialog.popup_centered()


func _on_FileDialog_dir_selected(dir):
	for index in range(frames.get_child_count()):
		frames.current_tab = index
		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		yield(VisualServer, "frame_post_draw")

		var image = get_viewport().get_texture().get_data()
		image.flip_y() # capture is y-flipped
		var frame = frames.get_child(index)
		image.get_rect(frame.get_global_rect()).save_png(dir.plus_file(frame.name + ".png"))


func _on_MouseMode_toggled(button_pressed):
	get_tree().set_group("canvas", "toggle_mode", button_pressed)
