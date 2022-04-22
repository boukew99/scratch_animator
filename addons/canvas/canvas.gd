extends TextureButton 

var line = preload("line.tscn")
var current_line


func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
		current_line.add_point(event.position)


func _on_Canvas_button_down():
	current_line = line.instance()
	add_child(current_line)

