extends Control

var selected_color = "blue"

var darkness_alpha = Config.get_conf_value("video","bg_darkness",0.5)

var focused = false

func _ready():

	$ROMBG/Darkness.modulate.a = darkness_alpha	

	$ROMBG.texture = Vars.rom_img_background
	
	selected_color = Config.get_conf_value("video","theme","blue")
	if Vars.colors.has(selected_color):
		$ColorRect.modulate = Color(Vars.colors[selected_color])
	else:
		$ColorRect.modulate = Color(selected_color)
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Config.get_conf_value("input", "input_mode","keyboard") == "keyboard":
		set_process_input(false)

func _input(_event):
	if Input.is_action_pressed("combo1") and Input.is_action_pressed("combo2") and Input.is_action_pressed("combo3") and Input.is_action_pressed("combo4") and Vars.pid > 0:
		focused = true
		_on_BtnGoMenu_pressed()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		#print("focus in")
		focused = true
		if Config.get_conf_value("misc", "input_mode", "keyboard") == "keyboard":
			OS.set_window_maximized(true) 
#		_on_BtnGoMenu_pressed()
		$VBoxContainer/BtnGoMenu.grab_focus()
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#print("focus out")
		focused = false


func _on_BtnGoMenu_pressed():
	#el boton no funcionará hasta que tengamos el focus de la ventana
	if !focused:
		return
	#regresarle el focus al launcher
	OS.set_window_maximized(true) 
	if Vars.pid > 0:
		# warning-ignore:return_value_discarded
		print("Closed content result: %d"%[OS.kill(Vars.pid)])
	set_process_input(false)
	Audio.get_node("Music").play()
	Audio.get_node("Accept").play()
	
	if Vars.paid:
		SceneChanger.change_scene("res://screens/AllGamesList.tscn")
	else:
		SceneChanger.change_scene("res://screens/BuyLauncher.tscn")
