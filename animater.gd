extends Control

var canvas = preload("res://addons/canvas/canvas_background.tscn")

onready var frames = $VBoxContainer/HBoxContainer2/TabContainer
onready var slider = $VBoxContainer/HBoxContainer2/VBoxContainer/VSlider

func _ready():
	if OS.get_name() == "HTML5":
		$VBoxContainer/HBoxContainer/Save.hide()
		
func _on_Next_pressed():
	frames.current_tab = wrapi(frames.current_tab +1, 0, frames.get_tab_count())


func _on_Prev_pressed():
	frames.current_tab = wrapi(frames.current_tab -1, 0, frames.get_tab_count())


func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = "0"
	frames.add_child(inst, true)
	frames.move_child(inst, frames.current_tab +1)
	_on_Next_pressed()


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


func _on_VSlider_value_changed(value):
	frames.current_tab = wrapi(value, 0, frames.get_tab_count())


func _on_Remove_pressed():
	frames.get_current_tab_control().queue_free()


func _on_Duplicate_pressed():
	var dup = frames.get_current_tab_control().duplicate()
	frames.add_child(dup, true)
	frames.move_child(dup, frames.current_tab +1)
	_on_Next_pressed()


func _on_Rename_text_entered(new_text):
	frames.get_current_tab_control().name = new_text


func _on_TabContainer_sort_children():
	slider.max_value = frames.get_tab_count() * 7
