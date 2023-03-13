extends TextureButton 

signal drawing()
export(PackedScene) var layer = preload("layer.tscn")
export(Array, PackedScene) var lines = [preload("line.tscn")]
onready var layers = get_children()
var current_layer = 0
var onion_skins = 0
var line_modulate = Color.black
var draw_layer
var current_line
var previous_size = rect_size

func _on_Canvas_ready():
	add_frame()
	draw_layer = get_child(0).get_child(0)

func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
		current_line.add_point_sparsely(event.position)
#		update()
		
func _on_Canvas_button_down():
	Input.set_use_accumulated_input(false)
	current_line = draw_layer.add_line()
	if current_line.default_color == Color.white:
		current_line.modulate = line_modulate
		
	emit_signal("drawing")

func _on_Canvas_button_up():
	Input.set_use_accumulated_input(true)

func add_frame():
	var frame = Node2D.new()
	frame.name = "0"
	for line in lines:
		var child = layer.instance()
		child.line = line
#		child.name = line.resource_path.get_file().get_basename() + "Layer"
		frame.add_child(child)
		
	add_child(frame, true)
	
func duplicate_frame(index):
	add_child(get_child(index))

func free_frame(index):
	get_child(index).queue_free()
	set_frame(index -1)
	
func set_layer(frame_index, layer_index):
	draw_layer = get_child(frame_index).get_child(layer_index)
	current_layer = layer_index
	
func set_frame(index):
	index = wrapi(index, 0, get_child_count())
	var minimum = max(0, index - onion_skins)
	var visible_frames = range(minimum, index+1)
	
	for frame in get_children(): 
		frame.visible = frame.get_index() in visible_frames
	
	set_layer(index, current_layer)
		
func undo():
	draw_layer.undo_redo.undo()

func redo():
	draw_layer.undo_redo.redo()

