extends PanelContainer

var line_color = Color("#282832")
var line_width = 4

func _on_Background_color_changed(color):
	$HSplitContainer/ColorRect.color = color


func _on_Canvas_drawing(line):
	line.default_color = line_color
	line.width = line_width


func _on_LineColor_color_changed(color):
	line_color = color


func _on_Width_value_changed(value):
	line_width = value


func _on_OK_pressed():
	get_tree().change_scene("res://main.tscn")
