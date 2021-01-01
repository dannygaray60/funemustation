extends Control

func _ready():
	if Config.get_conf_value("misc", "input_mode") == "keyboard":
		set_process_input(false)

func _input(_event):
	if Input.is_action_pressed("combo1") and Input.is_action_pressed("combo2") and Input.is_action_pressed("combo3") and Input.is_action_pressed("combo4") and Global.pid > 0:
		_on_BtnGoMenu_pressed()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		print("focus in")
		if Config.get_conf_value("misc", "input_mode") == "keyboard":
			OS.set_window_maximized(true) 
#		_on_BtnGoMenu_pressed()
		$VBoxContainer/BtnGoMenu.grab_focus()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		print("focus out")


func _on_BtnGoMenu_pressed():
	#regresarle el focus al launcher
	OS.set_window_maximized(true) 
	if Global.pid > 0:
		# warning-ignore:return_value_discarded
		OS.kill(Global.pid)
	set_process_input(false)
	Audio.get_node("Music").play()
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://ScrGamesList.tscn")
