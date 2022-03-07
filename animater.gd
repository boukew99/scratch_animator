extends Control

var canvas = preload("res://addons/canvas/canvas_with_background.tscn")

onready var frames = $VBoxContainer/TabContainer


func _on_Next_pressed():
	frames.current_tab += 1


func _on_Prev_pressed():
	frames.current_tab -= 1


func _on_Tag_text_entered(new_text):
	frames.get_current_tab_control().name = new_text


func _on_Sub_pressed():
	frames.get_current_tab_control().queue_free()


func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = "0"
	frames.add_child(inst, true)
	_on_Next_pressed()


func _on_TabContainer_tab_changed(tab):
	$VBoxContainer/HBoxContainer/Tag.text = frames.get_child(tab).name


func _on_FPS_value_changed(value):
	$FPSTimer.wait_time = 1 / value


func _on_Play_toggled(button_pressed):
	if button_pressed:
		$FPSTimer.start()
	else:
		$FPSTimer.stop()


func _on_FPSTimer_timeout():
	frames.current_tab = wrapi(frames.current_tab + 1, 0, frames.get_child_count())
