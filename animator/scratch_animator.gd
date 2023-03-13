extends PanelContainer

onready var canvas = $"%Canvas"
onready var frame_slider = $"%FrameSlider"
onready var frame_tabs = $"%FrameTabs"
onready var frame_timer = $FrameTimer
var play_scale = 1
var loop = false

func _ready():
	frame_tabs.add_tab("1")

func _on_FrameSlider_value_changed(value):
	canvas.set_frame(value)

func _on_Next_pressed():
	frame_tabs.current_tab += 1
	

func _on_Previous_pressed():
	frame_tabs.current_tab -= 1
	
func _on_OnionSkinDepth_item_selected(index):
	canvas.onion_skins = index
	canvas.set_frame(frame_slider.value)


func _on_Add_pressed():
	canvas.add_frame()
	frame_tabs.add_tab(str(canvas.get_child_count()))
	frame_tabs.current_tab +=1
	frame_slider.max_value += 1
	frame_slider.tick_count +=1
	frame_slider.value +=1


func _on_Duplicate_pressed():
	canvas.duplicate_frame(frame_slider.value)
	
#	dup.name += ".2"
#	frames.add_child(dup, true)
#	frames.move_child(dup, frames.current_tab +1)


func _on_Undo_pressed():
	canvas.undo()


func _on_Redo_pressed():
	canvas.redo()


func _on_ColorPickerButton_color_changed(color):
	canvas.line_modulate = color


func _on_SketchVisible_toggled(button_pressed):
	get_tree().set_group("sketch", "visible", button_pressed)
	
	
func _on_Timer_timeout():
	if loop:
		frame_slider.value = wrapi(frame_slider.value + 1 * play_scale, 0, canvas.get_child_count())
	else:
		frame_slider.value += 1
	
	
func _on_Play_pressed():
	frame_timer.start() if frame_timer.is_stopped() else frame_timer.stop()


func _on_Fps_value_changed(value):
	if value == 0:
		return
		
	play_scale = sign(value)
	frame_timer.wait_time = 1 / abs(value)


func _on_FrameTabs_tab_changed(tab):
	set_current_frame(tab)

func set_current_frame(index):
	frame_tabs.current_tab = index
	canvas.set_frame(index)
	

func _on_FrameTabs_tab_close(tab):
	$FreeFrameConfirmationDialog.popup_centered()

func _on_FreeFrameConfirmationDialog_confirmed():
	canvas.free_frame(frame_tabs.current_tab)
	frame_tabs.remove_tab(frame_tabs.current_tab)


func _on_OutLineLayer_toggled(button_pressed):
	canvas.set_layer(frame_slider.value, 0)

func _on_FillLayer_toggled(button_pressed):
	canvas.set_layer(frame_slider.value, 1)
#	$HBoxContainer/VBoxContainer/HBoxContainer/ColorPickerButton.visible = button_pressed
	
func _on_SketchLayer_toggled(button_pressed):
	canvas.set_layer(frame_slider.value, 2)
#	$HBoxContainer/VBoxContainer/HBoxContainer/OnionSkinDepth.visible = button_pressed
#	$HBoxContainer/VBoxContainer/HBoxContainer/SketchVisible.visible = button_pressed

func _on_Canvas_gui_input(event):
	pass
#	if event.is_action_pressed("next"):
#		_on_Next_pressed()
#	if event.is_action_pressed("previous"):
#		_on_Previous_pressed()
	if event is InputEventPanGesture:
		frame_slider.current_value += event.delta.x
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			frame_slider.value+= 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			frame_slider.value -= 1


func _on_Settings_pressed():
	$SettingsConfirmationDialog.popup_centered()


func _on_Canvas_resized():
	pass


func _on_Loop_toggled(button_pressed):
	$HBoxContainer/VBoxContainer/HBoxContainer/Duplicate.visible = not button_pressed
	$HBoxContainer/VBoxContainer/HBoxContainer/Add.visible = not button_pressed
	$HBoxContainer/VBoxContainer/HBoxContainer/Next.visible = button_pressed
	loop = button_pressed


func _on_ResizeConfirmationDialog_confirmed():
	canvas.rect_min_size = $HBoxContainer/VBoxContainer/PanelContainer/ScrollContainer.rect_size


func _on_ScrollContainer_resized():
	$ResizeConfirmationDialog.popup_centered()
#
#func _on_Capture_pressed():
#
#	for index in range(canvas.get_child_count()):
#		frame_slider.value = index
#		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
#		yield(VisualServer, "frame_post_draw")
#
#		var image = get_viewport().get_texture().get_data()
#		image.flip_y() # capture is y-flipped
#		image = image.get_rect(frames.get_global_rect())
#		image.resize(40 * aspect.ratio, 40, Image.INTERPOLATE_LANCZOS)
#
#		var tex = ImageTexture.new()
#		tex.create_from_image(image)
#
#		$CapturesDialog/GridContainer.get_child(index).texture = tex
#
#	$CapturesDialog.popup_centered()
#
#
#func _on_Save_pressed():
#	file_dialog.filters = ["*.dict"]
#	file_dialog.mode = FileDialog.MODE_SAVE_FILE
#	file_dialog.popup_centered()
#
#func _on_ConfirmationDialog_confirmed():
#	file_dialog.filters = ["*.png"]
#	file_dialog.mode = FileDialog.MODE_OPEN_DIR
#	$FileDialog.popup_centered()
#
#func _on_FileDialog_dir_selected(dir):
#	for index in range(frames.get_child_count()):
#		slider.value = index
#		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
#		yield(VisualServer, "frame_post_draw")
#
#		var image = get_viewport().get_texture().get_data()
#		image.flip_y() # capture is y-flipped
#		var frame = frames.get_child(index)
#		image = image.get_rect(frame.get_global_rect())
#		var file_name = $FileDialog.current_file + "_" + frame.name + ".png"
#		image.save_png(dir.plus_file(file_name))
#
#
#func _on_FileDialog_file_selected(path):
#	match path.get_extension():
#		"dict":
#			var copy = {}
#			for frame in frames.get_children():
#				var points = []
#				for line in frame.get_children():
#					points.append(line.points)
#
#				copy[frame.name] = points
#
#			var file = File.new()
#			file.open_compressed(path, File.WRITE)
#			file.store_var(copy)
#			file.close()
#
#			name_label.text = path.get_file().get_basename()
#			file_dir = path.get_base_dir()


func _on_OnionSkinDepth_value_changed(value):
	canvas.onion_skins = value
