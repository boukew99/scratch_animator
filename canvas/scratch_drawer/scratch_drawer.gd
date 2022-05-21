extends HBoxContainer

var clear_color = Color(0.298039, 0.298039, 0.298039) # default clear color
var erase = false
var line_color = Color("#282832") # default line color

onready var canvas = $Canvas


func _on_CanvasOptimized_drawing(line):
	line.default_color = clear_color if erase else line_color


func _on_Line_pressed():
	canvas.line = preload("../line.tscn")


func _on_Rounded_pressed():
	canvas.line = preload("line_rounded.tscn")


func _on_Thick_pressed():
	canvas.line = preload("line_thick.tscn")


func _on_WidthCurve_pressed():
	canvas.line = preload("line_width_curve.tscn")


func _on_Gradient_pressed():
	canvas.line = preload("line_gradient.tscn")


func _on_Rainbow_pressed():
	canvas.line = preload("line_rainbow.tscn")


func _on_Clear_pressed():
	for line in canvas.get_children():
		line.queue_free()
		
	canvas.texture_normal = null


func _on_MaxDistance_value_changed(value):
	canvas.max_distance = value


func _on_Bias_value_changed(value):
	canvas.bias = value


func _on_Canvas_drawing(line):
	line.default_color = clear_color if erase else line_color


func _on_Erase_toggled(button_pressed):
	erase = button_pressed


func _on_ColorPickerButton_color_changed(color):
	line_color = color
