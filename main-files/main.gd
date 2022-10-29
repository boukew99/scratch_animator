extends PanelContainer



func _on_Configure_pressed():
	get_tree().change_scene("res://line-configure.tscn")


func _on_Tool_pressed():
	get_tree().change_scene("res://tool.tscn")


func _on_LinkButton_pressed():
	OS.shell_open("exports/")
