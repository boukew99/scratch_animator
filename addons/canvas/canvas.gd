extends TextureButton 

var line = preload("line.tscn")
var current_line

func _on_Canvas_toggled(button_pressed):
	if button_pressed:
		current_line = line.instance()
		add_child(current_line)


func _on_Canvas_gui_input(event):
	if event is InputEventMouseMotion and event.relative and pressed:
		current_line.add_point(event.position)

	

