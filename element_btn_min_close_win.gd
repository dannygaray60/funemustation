extends Control

var months = {
	1:
		["January","Enero"],
	2:
		["February","Febrero"],
	3:
		["March","Marzo"],
	4:
		["April","Abril"],
	5:
		["May","Mayo"],
	6:
		["June","Junio"],
	7:
		["July","Julio"],
	8:
		["August","Agosto"],
	9:
		["September","Septiembre"],
	10:
		["October","Octubre"],
	11:
		["November","Noviembre"],
	12:
		["December","Diciembre"],	
}

func _enter_tree():
	if !OS.window_borderless:
		$HBoxContainer.visible = false
	#ocultar info de bateria si es desconocida
	if OS.get_power_percent_left() == -1:
		$InfoDevice/Battery.visible = false
	update_info()

func update_info():
	var datetime = OS.get_datetime()
	#fecha
	match TranslationServer.get_locale():
		"en":
			$InfoDevice/Date/Lbl.text = "%s %s" % [months[datetime["month"]][0],str(datetime["day"]).pad_zeros(2)]
		"es":
			$InfoDevice/Date/Lbl.text = "%s de %s" % [str(datetime["day"]).pad_zeros(2),months[datetime["month"]][1]]	
	#hora
	$InfoDevice/Hour/Lbl.text = "%s:%s" % [str(datetime["hour"]).pad_zeros(2),str(datetime["minute"]).pad_zeros(2)]
	#carga
	if $InfoDevice/Battery.visible:
		var battery_status = OS.get_power_state()
		var battery_percent = OS.get_power_percent_left()
		var battery_icon = "battery-empty"
		$InfoDevice/Battery/Lbl.text = "%s%%" % str(battery_percent).pad_zeros(2)
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
		$InfoDevice/Battery/Icon.icon_name = battery_icon
		#mostrar icono de cargando si el dispositivo se carga
		if battery_status == 3:
			$InfoDevice/Battery/Icon2.visible = true
		else:
			$InfoDevice/Battery/Icon2.visible = false

func _on_BtnMin_pressed():
	$HBoxContainer/BtnMin.release_focus()
	OS.window_minimized = true


func _on_BtnClose_pressed():
#	Audio.get_node("Alert").play()
	$ControlConfirmQuit.visible = true
	$ControlConfirmQuit/VBoxContainer/HBoxContainer/BtnExit.grab_focus()

func _on_BtnExit_pressed():
	get_tree().quit()


func _on_BtnCancelPopup_pressed():
	Audio.get_node("GoBack").play()
	$ControlConfirmQuit.visible = false


func _on_Btn_focus_entered():
	Audio.get_node("ChangeSection").play()


func _on_Timer_timeout():
	update_info()
