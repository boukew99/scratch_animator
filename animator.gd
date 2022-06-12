extends Control

var canvas = preload("canvas/canvas.tscn")
var onion_skinning = false
var file_dir = ""
var undo_redo = UndoRedo.new()

onready var slider = $VBoxContainer/HBoxContainer2/VBoxContainer2/VSlider
onready var aspect = $VBoxContainer/HBoxContainer2/VBoxContainer/AspectRatioContainer
onready var frames = $VBoxContainer/HBoxContainer2/VBoxContainer/AspectRatioContainer/Frames
onready var tabs = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer3/Tabs
onready var file_dialog = $FileDialog
onready var timer = $FPSTimer
onready var name_label = $VBoxContainer/HBoxContainer/Filename
onready var shader = $VBoxContainer/HBoxContainer2/VBoxContainer/AspectRatioContainer/Shader
onready var fps_controls = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer3/FPSControls

func _on_Animator_ready():
	var config = ConfigFile.new()
	if not config.load("scratch_animator.cfg"):
		aspect.ratio = config.get_value("frame", "aspect_ratio", 16 / 9.0)
		$ConfigDialog/VBoxContainer/GridContainer/AspectRatio.value = aspect.ratio 
	
	$ConfigDialog.popup_centered()
	if OS.get_name() == "HTML5":
		$VBoxContainer/HBoxContainer/Save.hide()
	fps_controls.hide()
	
	slider.max_value = frames.get_child_count() -1
	for i in range(frames.get_child_count()):
		tabs.add_tab(str(i))
	
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


func _on_Prev_pressed():
	slider.value -= 1


func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = str(frames.get_child_count())
	frames.add_child(inst, true)
	tabs.add_tab(str(frames.get_child_count()))
	return inst


func _on_Play_toggled(button_pressed):
	if button_pressed:
		timer.start()
		fps_controls.show()
	else:
		timer.stop()
		fps_controls.hide()

func _on_FPSTimer_timeout():
	_on_Next_pressed()


func _on_VSlider_value_changed(value):
	undo_redo.create_action("switch_frame")
	undo_redo.add_do_property(frames, "current_tab", value)
	undo_redo.add_undo_property(frames, "current_tab", frames.current_tab)
	undo_redo.commit_action()


func _on_Remove_pressed():
	tabs.remove_tab(slider.value)
	frames.get_child(slider.value).queue_free()

func _on_Duplicate_pressed():
	var dup = tabs.get_current_tab_control().duplicate()
	dup.name += ".2"
	frames.add_child(dup, true)
	frames.move_child(dup, tabs.current_tab +1)
	tabs.add_tab(dup.name)
	_on_Next_pressed()


func _on_OnionSkinning_toggled(button_pressed):
	onion_skinning = button_pressed
	if slider.value == 0:
		return
		
	var previous_frame = slider.value - 1
	var control = frames.get_child(previous_frame)
	
	control.visible = button_pressed
	if button_pressed:
		control.modulate.a = 0.3


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


func _on_Tabs_reposition_active_tab_request(idx_to):
	var child = frames.get_child(tabs.current_tab)
	frames.move_child(child, idx_to)
	
func _on_Tabs_tab_changed(tab):
	slider.value = tab

func _on_RichTextLabel_meta_clicked(meta):
	if meta is String:
		OS.shell_open(meta)


func _on_PanelContainer_gui_input(event):
	if event is InputEventPanGesture:
		slider.value += event.delta


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
	$VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer3/FPSControls/Label.text = String(value)



func _on_Undo_pressed():
	frames.get_current_tab_control().time.undo()


func _on_Redo_pressed():
	frames.get_current_tab_control().time.redo()


func _on_Frames_tab_changed(tab):
	tabs.current_tab = tab
	tabs.ensure_tab_visible(tab)
	frames.get_child(tab).modulate.a = 1
	if onion_skinning:
		_on_OnionSkinning_toggled(true)
