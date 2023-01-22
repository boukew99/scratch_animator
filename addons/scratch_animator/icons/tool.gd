extends PanelContainer

var canvas = preload("res://canvas/canvas.tscn")
onready var tab_con = $"%TabContainer"
func _on_DrawArea_value_changed(value):
	tab_con.rect_min_size = Vector2.ONE * value /2
#	$"%TabContainer".rect_min_size.x = aspect

func _unhandled_input(event):
	if event.is_action_pressed("fullscreen"):
		$ScrollContainer/CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer.visible = OS.window_fullscreen
		$ScrollContainer/CenterContainer/VBoxContainer/HFlowContainer.visible = OS.window_fullscreen
		tab_con.tabs_visible = OS.window_fullscreen
		
		OS.window_fullscreen = not OS.window_fullscreen

func _on_OK_pressed():
	get_tree().change_scene("res://main.tscn")
	OS.window_fullscreen = false


func _on_TabContainer_child_entered_tree(node):
	$ScrollContainer/CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/VSlider.max_value += 1


func _on_Next_pressed():
	#unoo
	tab_con.current_tab += 1

func _on_Add_pressed():
	var inst = canvas.instance()
	inst.name = "0"
	tab_con.add_child(inst, true)


func _on_VSlider_value_changed(value):
	tab_con.current_tab = wrapi(value, 0, tab_con.get_tab_count())


func _on_LineEdit_text_entered(new_text):
	tab_con.get_current_tab_control().name = new_text


func _on_TabContainer_tab_changed(tab):
	$ScrollContainer/CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/VSlider.value = tab
	tab_con.get_current_tab_control().modulate = Color.black
	if $"%OnionSkinning".pressed and tab != 0:
		var previous = tab_con.get_child(tab -1)
		previous.show()
		previous.modulate = Color.gray
		
		
