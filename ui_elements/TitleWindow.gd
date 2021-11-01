extends Control

var Functions = load("res://scripts/Functions.gd").new()

signal exit_confirm_dialog_show
signal exit_confirm_dialog_hide

signal btn_back_pressed
signal btn_minimize_pressed
signal btn_close_pressed

export var title_visible = true
export var title = "Window Title"
export var btn_back_visible = true
export var btn_window_visible = true

var prev_owner_focus = null

func set_title(txt="Title Window"):
	$WindowBar/LblTitle.text = txt

func _ready():
	
	var theme_color = Config.get_conf_value("video","theme","blue")
	if Vars.colors.has(theme_color):
		$ConfirmQuit.self_modulate = Color(Vars.colors[theme_color])
		$ConfirmQuit/ColorRect.self_modulate = Color(Vars.colors[theme_color])
	
	get_tree().set_auto_accept_quit(false)
	
	if title == "WELCOME_USER":
		var nickname = Config.get_conf_value("misc","nickname","danny")
		if nickname == "":
			$WindowBar/LblTitle.text = ""
		else:
			$WindowBar/LblTitle.text = tr(title)%[nickname]
	else:
		$WindowBar/LblTitle.text = tr(title)
	$WindowBar/LblTitle.visible = title_visible
	$WindowBar/BtnArrowLeft.visible = btn_back_visible
	$WindowBar/HBxBtnWindow.visible = btn_window_visible
	
	if Config.get_conf_value("video","borderless_fullscreen",false) or Config.get_conf_value("video","fullscreen",false):
		$WindowBar/HBxBtnWindow.visible = true
	else:
		$WindowBar/HBxBtnWindow.visible = false
	
	update_status_info()


func _process(_delta):
	
	if $ConfirmQuit.visible and (Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right")):
		Audio.get_node("ChangeItem").play()

func update_status_info():
	
	$WindowBar/InfoDevice/Date/Lbl.text = Functions.get_date()
	$WindowBar/InfoDevice/Hour/Lbl.text = Functions.get_time()
	
	#estado de batería
	if $WindowBar/InfoDevice/Battery.visible:
		
		var battery_status = OS.get_power_state()
		var battery_percent = OS.get_power_percent_left()
		var battery_icon = "battery-empty"
		
		$WindowBar/InfoDevice/Battery/Lbl.text = "%s%%" % str(battery_percent).pad_zeros(2)
		
		#cambiar icono dependiendo de porcentaje
		if battery_percent < 15:
			battery_icon = "battery-empty"
		elif battery_percent < 40:
			battery_icon = "battery-quarter"
		elif battery_percent < 60:
			battery_icon = "battery-half"
		elif battery_percent < 80:
			battery_icon = "battery-three-quarters"
		else:
			battery_icon = "battery-full"
			
		$WindowBar/InfoDevice/Battery/Icon.icon_name = battery_icon
		
		#mostrar icono de cargando si el dispositivo se carga
		if battery_status == 3:
			$WindowBar/InfoDevice/Battery/Icon2.visible = true
		else:
			$WindowBar/InfoDevice/Battery/Icon2.visible = false
			
func show_confirm_quit():
	emit_signal("exit_confirm_dialog_show")
	prev_owner_focus = get_focus_owner()
	if prev_owner_focus == null:
		prev_owner_focus = get_tree().current_scene
	
	Audio.get_node("Alert").play()
	$ConfirmQuit/VBx/HBx/BtnClose.grab_focus()
	$ConfirmQuit.visible = true
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		show_confirm_quit()

func _on_Btn_confirm_quit(opt):
	match opt:
		"quit":
			get_tree().quit()
		"cancel":
			emit_signal("exit_confirm_dialog_hide")
			Audio.get_node("GoBack").play()
			$ConfirmQuit.visible = false
			prev_owner_focus.grab_focus()

func _on_Btn_pressed(opt):
	match opt:
		"back":
			Audio.get_node("GoBack").play()
			emit_signal("btn_back_pressed")
		"minimize":
			Audio.get_node("BtnPressed").play()
			OS.window_minimized = true
			emit_signal("btn_minimize_pressed")
		"close":
			show_confirm_quit()
			emit_signal("btn_close_pressed")


func _on_TimerRefreshInfo_timeout():
	update_status_info()
