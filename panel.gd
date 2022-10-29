tool
extends PanelContainer

const blank_color = Color(0.156863,0.156863,0.196078,1) # default line color
var erase = false
var line_color = blank_color 
var line_width = 5
var front = false
var saved_image

onready var background = $CenterContainer/ColorRect
onready var canvas = $CenterContainer/ColorRect/Canvas
onready var undo = $HBoxContainer/Undo
onready var redo = $HBoxContainer/Redo
onready var perpendicular_distance_label = $VBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/Label
onready var width = $LineTools/PanelContainer2/VBoxContainer/Width

func _ready():
	canvas.time.connect("version_changed", self, "_on_Canvas_version_changed")
	
func _on_Line_pressed():
	canvas.line = preload("../canvas/line.tscn")
	

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
	if line.default_color == blank_color:
		line.default_color = background.color if erase else line_color
	if line.width == 4:
		line.width = line_width
	if front:
		canvas.move_child(line, 0)

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


func _on_ToggleMode_toggled(button_pressed):
	canvas.toggle_mode = button_pressed


func _on_Width_item_selected(index):
	line_width = fibonacci_of(index + 2)
	
func fibonacci_of(n):
	if n in [0, 1]:
		return n
	return fibonacci_of(n - 1) + + fibonacci_of(n - 2)

func _on_IncreaseWidth_pressed():
	width.selected += 1
	_on_Width_item_selected(width.selected)


func _on_DecreaseWidth_pressed():
	width.selected -= 1
	_on_Width_item_selected(width.selected)


func _on_BackgroundPickerButton_color_changed(color):
	background.color = color


func _on_OK_pressed():
	_on_Export_pressed()


func _on_Height_value_changed(value):
	background.rect_min_size.y = value


func _on_Pages_value_changed(value):
	var height = $VBoxContainer/HBoxContainer/ScrollContainer.rect_size.y
	background.rect_min_size.y = height * value


func _on_MoveFront_toggled(button_pressed):
	front = button_pressed


func _on_Configure_pressed():
	$Configuration.popup()




func _on_Animate_toggled(button_pressed):
	$Configuration/VBoxContainer/Animate.visible = button_pressed


func _on_Canvas_frame(index):
	$VBoxContainer/ColorRect/LineTools.visible = index == 0


func _on_End_pressed():
	pass # frame = 0


func _on_Fill_toggled(button_pressed):
	pass # if button_pressed: color = fill_color else: color = line_color
