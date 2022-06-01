extends Panel

var erase = false
var line_color = Color("#282832") # default line color
var saved_image

onready var clear_color = $VBoxContainer/HBoxContainer/ColorRect.color
onready var canvas = $VBoxContainer/HBoxContainer/ColorRect/Canvas
onready var undo = $VBoxContainer/PanelContainer/HBoxContainer/Undo
onready var redo = $VBoxContainer/PanelContainer/HBoxContainer/Redo
onready var perpendicular_distance_label = $VBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/Label

func _ready():
	canvas.time.connect("version_changed", self, "_on_Canvas_version_changed")
	
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


func _on_Dash_pressed():
	canvas.line = preload("line_dash.tscn")

func _on_Blue_pressed():
	canvas.line = preload("line_blue.tscn")


func _on_Green_pressed():
	canvas.line = preload("line_green.tscn")


func _on_Red_pressed():
	canvas.line = preload("line_red.tscn")

func _on_Fence_pressed():
	canvas.line = preload("line_fence.tscn")
	

func _on_Underline_pressed():
	canvas.line = preload("line_underlined.tscn")
	
func _on_Road_pressed():
	canvas.line = preload("line_road.tscn")


func _on_Canvas_drawing(line):
	if line.default_color == Color(0.156863,0.156863,0.196078,1):
		line.default_color = clear_color if erase else line_color


func _on_Erase_toggled(button_pressed):
	erase = button_pressed


func _on_ColorPickerButton_color_changed(color):
	line_color = color


func _on_PerpendicularDistance_value_changed(value):
	canvas.perpendicular_distance = value
	perpendicular_distance_label.text = "%04.1f"% [value]
	

func _on_Undo_pressed():
	canvas.time.undo()


func _on_Redo_pressed():
	canvas.time.redo()

func _on_Clear_pressed():
	canvas.clear()

func _on_Canvas_version_changed():
	undo.disabled = not canvas.time.has_undo()
	redo.disabled = not canvas.time.has_redo()
	

func _on_Export_pressed():
	canvas.capture_lines("export/screenshot.png")


func _on_Capture_pressed():
	canvas.capture_lines()
