extends Control

var canvas = preload("canvas/canvas.tscn")
var onion_skinning = false
var file_dir = ""
var bookmarks = [0]

onready var slider = $VBoxContainer/VSlider
onready var aspect = $VBoxContainer/AspectRatioContainer
onready var frames = $VBoxContainer/Frames
onready var file_dialog = $FileDialog
onready var timer = $FPSTimer
onready var name_label = $VBoxContainer/HBoxContainer/Filename
onready var shader = $VBoxContainer/AspectRatioContainer/Shader

func _on_Animator_ready():
	var config = ConfigFile.new()
#	if not config.load("scratch_animator.cfg"):
#		aspect.ratio = config.get_value("frame", "aspect_ratio", 16 / 9.0)
#		$ConfigDialog/VBoxContainer/VBoxContainer/HBoxContainer/AspectRatio.value = aspect.ratio 
	
	$ConfigDialog.popup_centered()
	if OS.get_name() == "HTML5":
		$VBoxContainer/HBoxContainer2/VBoxContainer2/HBoxContainer/Save.hide()
	$VBoxContainer/HBoxContainer3/HBoxContainer3/FPSSlider.share($VBoxContainer/HBoxContainer3/HBoxContainer3/FPSSpinBox)
	
	slider.max_value = frames.get_child_count() -1
	
	get_tree().connect("files_dropped", self, "_on_files_dropped")

func _on_files_dropped(files, screen):
	for file_path in files:
		match file_path.get_extension():
			"dict":
				for frame in frames.get_children():
					frame.queue_free()
				
				var file = File.new()
				file.open(file_path, File.READ)
				var paste = file.get_var()
				file.close()
				
				for frame_name in paste:
					var new = _on_Add_pressed()
					new.name = frame_name
					frames.add_child(new)
					print(frame_name)
					for line_points in paste[frame_name]:
						var new_line = new.line.instance()
						new_line.points = line_points
						new.add_child(new_line, true)
			"tres":
				var screen_shader = load(file_path)
				
				if screen_shader is Material:
					shader.material = screen_shader
					shader.show()
				
				

func _on_Next_pressed():
	slider.value = wrapi(slider.value + 1, 0, frames.get_child_count())


func _on_Add_pressed():
	var inst = canvas.instance()
	frames.add_child(inst)
	frames.move_child(inst, frames.current_tab+1)
	
	slider.max_value += 1
	slider.tick_count += 1
	slider.value += 1
	
	return inst


func _on_Play_toggled(button_pressed):
	if button_pressed:
		timer.start()
	else:
		timer.stop()

func _on_FPSTimer_timeout():
	_on_Next_pressed()

func _on_Remove_pressed():
	frames.get_child(slider.value).queue_free()

func _on_Duplicate_pressed():
	var dup = frames.get_current_tab_control().duplicate()
	dup.name += ".2"
	frames.add_child(dup, true)
	frames.move_child(dup, frames.current_tab +1)
	_on_Next_pressed()


func _on_OnionSkinning_toggled(button_pressed):
	onion_skinning = button_pressed
	if slider.value == 0:
		return
		
	var previous_frame = slider.value - 1
	var control = frames.get_child(previous_frame)
	
	control.visible = button_pressed
	if button_pressed:
		control.modulate = Color.red


func _on_Save_pressed():
	file_dialog.filters = ["*.dict"]
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup_centered()
	
func _on_ConfirmationDialog_confirmed():
	file_dialog.filters = ["*.png"]
	file_dialog.mode = FileDialog.MODE_OPEN_DIR
	$FileDialog.popup_centered()

func _on_FileDialog_dir_selected(dir):
	for index in range(frames.get_child_count()):
		slider.value = index
		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		yield(VisualServer, "frame_post_draw")

		var image = get_viewport().get_texture().get_data()
		image.flip_y() # capture is y-flipped
		var frame = frames.get_child(index)
		image = image.get_rect(frame.get_global_rect())
		var file_name = $FileDialog.current_file + "_" + frame.name + ".png"
		image.save_png(dir.plus_file(file_name))
	
	
func _on_FileDialog_file_selected(path):
	match path.get_extension():
		"dict":
			var copy = {}
			for frame in frames.get_children():
				var points = []
				for line in frame.get_children():
					points.append(line.points)
					
				copy[frame.name] = points
			
			var file = File.new()
			file.open_compressed(path, File.WRITE)
			file.store_var(copy)
			file.close()
			
			name_label.text = path.get_file().get_basename()
			file_dir = path.get_base_dir()

	
func _on_Tabs_tab_changed(tab):
	slider.value = bookmarks[tab]

func _on_RichTextLabel_meta_clicked(meta):
	if meta is String: OS.shell_open(meta)


func _on_PanelContainer_gui_input(event):
	if event is InputEventPanGesture:
		frames.current_tab += event.delta.x
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			frames.current_tab += 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			frames.current_tab -= 1


func _on_Capture_pressed():
	
	for index in range(frames.get_child_count()):
		slider.value = index
		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		yield(VisualServer, "frame_post_draw")

		var image = get_viewport().get_texture().get_data()
		image.flip_y() # capture is y-flipped
		image = image.get_rect(frames.get_global_rect())
		image.resize(40 * aspect.ratio, 40, Image.INTERPOLATE_LANCZOS)
		
		var tex = ImageTexture.new()
		tex.create_from_image(image)
		
		$CapturesDialog/GridContainer.get_child(index).texture = tex
		
	$CapturesDialog.popup_centered()


func _on_FPS2_item_selected(index):
	timer.wait_time = 1.0 / [4, 8, 12, 16, 24][index]


func _on_Filename_pressed():
	if file_dir:
		OS.shell_open(ProjectSettings.globalize_path(file_dir))



func _on_ConfigDialog_confirmed():
	var config = ConfigFile.new()
	config.set_value("frame", "aspect_ratio", $ConfigDialog/VBoxContainer/GridContainer/AspectRatio.value)
	
	config.save("scratch_animator.cfg")
	get_tree().reload_current_scene()


func _on_FPSSlider_value_changed(value):
	timer.wait_time = 1 / value



func _on_Undo_pressed():
	frames.get_current_tab_control().time.undo()


func _on_Redo_pressed():
	frames.get_current_tab_control().time.redo()


func _on_Frames_tab_changed(tab):
	frames.get_child(tab).modulate = Color("282832")
	if onion_skinning:
		_on_OnionSkinning_toggled(true)


func _on_ColorPickerButton_color_changed(color):
	frames.get("custom_styles/panel").bg_color = color


func _on_AspectRatio_value_changed(value):
	aspect.ratio = value


func _on_Frames_sort_children():
	pass # Replace with function body.


func _on_Bookmark_pressed():
#	tabs.add_tab(str(slider.value))
	bookmarks.append(slider.value)


func _on_VSlider_value_changed(value):
	frames.current_tab = value


func _on_Previous_pressed():
	slider.value -= 1



func _on_Frames_resized():
	$ConfigDialog/TabContainer/Canvas/Aspect.text = "size: %s px, aspect: %0.3f." % [frames.rect_size, frames.rect_size.x / frames.rect_size.y]



func _on_Config_pressed():
	$ConfigDialog.popup_centered()
