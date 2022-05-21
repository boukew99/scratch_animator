extends Control

var canvas = preload("canvas/canvas.tscn")
var onion_skinning = false
var loop = true

onready var slider = $VBoxContainer/HBoxContainer2/VBoxContainer/VSlider
onready var aspect = $VBoxContainer/HBoxContainer2/PanelContainer/VBoxContainer/AspectRatioContainer
onready var background = aspect.get_child(0)
onready var tabs = $VBoxContainer/HBoxContainer3/Tabs
onready var file_dialog = $FileDialog
onready var timer = $FPSTimer

func _on_Animator_ready():
	$About.popup_centered()
	if OS.get_name() == "HTML5":
		$VBoxContainer/HBoxContainer/Save.hide()
	for i in range(aspect.get_child_count()):
		tabs.add_tab(str(i))
	
	get_tree().connect("files_dropped", self, "_on_files_dropped")

func _on_files_dropped(files, screen):
	for file in files:
		match file.get_extension():
			"txt":
				pass
	
func _on_Next_pressed():
	slider.value = slider.value + 1 if not loop else wrapi(slider.value + 1, 0, slider.max_value)


func _on_Prev_pressed():
	slider.value -= 1


func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = str(aspect.get_child_count())
	aspect.add_child(inst, true)
	tabs.add_tab(str(aspect.get_child_count()))
	return inst


func _on_Play_toggled(button_pressed):
	if button_pressed:
		timer.start()
	else:
		timer.stop()

func _on_FPS_value_changed(value):
	timer.wait_time = 1 / value

func _on_FPSTimer_timeout():
	_on_Next_pressed()


func _on_VSlider_value_changed(value):
#	frames.current_tab = wrapi(value, 0, frames.get_tab_count())
	tabs.current_tab = value
	tabs.ensure_tab_visible(value)
	aspect.get_child(value).modulate.a = 1
	if onion_skinning:
		_on_OnionSkinning_toggled(true)


func _on_Remove_pressed():
	tabs.remove_tab(aspect.current_tab)
	aspect.get_current_tab_control().queue_free()

func _on_Duplicate_pressed():
	var dup = tabs.get_current_tab_control().duplicate()
	dup.name += ".2"
	aspect.add_child(dup, true)
	aspect.move_child(dup, tabs.current_tab +1)
	tabs.add_tab(dup.name)
	_on_Next_pressed()


func _on_Rename_text_entered(new_text):
	tabs.get_current_tab_control().name = new_text


func _on_OnionSkinning_toggled(button_pressed):
	onion_skinning = button_pressed
	if slider.value == 0:
		return
		
	var previous_frame = slider.value - 1
	var control = aspect.get_child(previous_frame)
	
	control.visible = button_pressed
	if button_pressed:
		control.modulate.a = 0.3


func _on_Copy_pressed():
	var copy = {}
	for frame in aspect.get_children():
		var points = []
		for line in frame.get_children():
			points.append(line.points)
			
		copy[frame.name] = points
		
	OS.clipboard = var2str(copy)

func _on_Paste_pressed():
	for frame in aspect.get_children():
		frame.queue_free()
		
	var paste = str2var(OS.clipboard)
	
	for frame_name in paste:
		var new = _on_Add_pressed()
		new.name = frame_name
		
		for line_points in paste[frame_name]:
			var new_line = new.line.instance()
			new_line.points = line_points
			new.add_child(new_line, true)
		
#		frames.add_child(new)


func _on_Save_pressed():
	file_dialog.filters = ["*.txt"]
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup_centered()
	
func _on_Export_pressed():
	file_dialog.filters = ["*.png"]
	file_dialog.mode = FileDialog.MODE_OPEN_DIR
	file_dialog.popup_centered()


func _on_Screenshot_pressed():
	file_dialog.filters = ["*.png"]
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup_centered()

func _on_FileDialog_dir_selected(dir):
	for index in range(aspect.get_child_count()):
		slider.value = index
		get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
		yield(VisualServer, "frame_post_draw")

		var image = get_viewport().get_texture().get_data()
		image.flip_y() # capture is y-flipped
		var frame = aspect.get_child(index)
		image.get_rect(frame.get_global_rect()).save_png(dir.plus_file(frame.name + ".png"))
	
	
func _on_FileDialog_file_selected(path):
	match path.get_extension():
		"png":
			pass
		"txt":
			pass
			


func _on_Tabs_reposition_active_tab_request(idx_to):
	var child = aspect.get_child(tabs.current_tab)
	aspect.move_child(child, idx_to)
	pass


func _on_Bookmark_pressed():
	tabs.set_tab_icon(tabs.current_tab, preload("icons/bookmark.png"))


func _on_Aspect_item_selected(index):
	aspect.ratio = [16 / 9.0, 4 / 3.0, 1.613, 1][index]


func _on_Loop_toggled(button_pressed):
	loop = button_pressed


func _on_Tabs_tab_changed(tab):
	slider.value = tab

func _on_RichTextLabel_meta_clicked(meta):
	match meta:
		"Godot Engine":
			OS.shell_open("https://godotengine.org/")
		"source":
			OS.shell_open("https://github.com/boukew99/scratch_animator")


func _on_PanelContainer_gui_input(event):
	if event is InputEventPanGesture:
		slider.value += event.delta


func _on_AspectRatioContainer_sort_children():
	slider.max_value = aspect.get_child_count() - 1
	slider.tick_count = slider.max_value+ 1


func _on_Capture_pressed():
	get_viewport().set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	yield(VisualServer, "frame_post_draw")

	var image = get_viewport().get_texture().get_data()
	image.flip_y()
	image = image.get_rect(background.get_global_rect())
	image.resize(20, 20, Image.INTERPOLATE_LANCZOS)
	var tex = ImageTexture.new()
	tex.create_from_image(image)
	
	tabs.set_tab_icon(tabs.current_tab, tex)


func _on_Configuration_pressed():
	$About.popup_centered()


func _on_ScreenShader_item_selected(index):
	$VBoxContainer/HBoxContainer2/PanelContainer/VBoxContainer/AspectRatioContainer/Shader.material = [
		null,
		preload("pixelize.tres"),
	] [index]
