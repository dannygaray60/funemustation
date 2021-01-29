extends Control

var i = 0

var last_action = "none"

#index del sistema seleccionado
var idx_sys_now = 0
#su key de diccionario
var sys_key = ""
#nombre del sistema
var sys_name = ""
#path del sistema
var sys_path = ""

#index del archivo elegido
var f_idx = 0
#y la ruta del archivo
var f_path = ""


var total_loaded_games = 0

#lista de roms del sistema elegido
var roms

func _ready():
	
#	if Global.view_favs:
#		pass
	
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


	
	if Global.random_game:
		randomize()
		idx_sys_now = Functions.get_new_position_on_array(
			Global.systems_id,
			randi() % Global.systems_id.size(),
			"none"
		)
		load_system_data()
	
	else:
		idx_sys_now = Functions.get_new_position_on_array(
			Global.systems_id,
			Config.get_conf_value("misc","selected_system"),
			"none"
		)
		load_system_data()
		$TimerToShowWallpaper.start()
	
func _process(_delta):
	
	if $element_btn_min_close_win.get_node("ControlConfirmQuit").visible:
		return
	
	if $AnimationPlayer.is_playing():
		return
	
	if Input.is_action_just_pressed("ui_up"):
		$GameBG.texture = null
		last_action = "none"
		Audio.get_node("ChangeSection").play()
		$AnimationPlayer.play("change_to_up")
		
	elif Input.is_action_just_pressed("ui_down"):
		$GameBG.texture = null
		last_action = "none"
		Audio.get_node("ChangeSection").play()
		$AnimationPlayer.play("change_to_down")
		
	elif Input.is_action_just_pressed("ui_left") and total_loaded_games > 0:
		$Timer.start(0.4)
		Audio.get_node("ChangeItem").play()
		last_action = "prev"
		load_system_file_data("prev")
		
	elif Input.is_action_just_pressed("ui_right") and total_loaded_games > 0:
		$Timer.start(0.4)
		Audio.get_node("ChangeItem").play()
		last_action = "next"
		load_system_file_data("next")
		
	elif Input.is_action_just_pressed("ui_accept") and total_loaded_games > 0:
		last_action = "none"
		$AnimationPlayer.play("wait")
		$ControlEmuExec.visible = true
		#con los process desactivados evitamos activar la accion una segunda vez
		set_process(false)
		set_process_input(false)
		Config.set_conf_value("misc","selected_system",idx_sys_now) 
		Global.save_system_conf()
		$TimerToStartEmu.start()

	elif Input.is_action_just_pressed("ui_cancel"):
		last_action = "none"
		Audio.get_node("GoBack").play()
		Config.set_conf_value("misc","selected_system",idx_sys_now) 
		Global.save_system_conf()
		SceneChanger.change_scene("res://MainScr.tscn")
		
	elif Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		last_action = "none"
		$Timer.stop()
		$TimerToShowWallpaper.start()
		Config.set_conf_value("misc","selected_system",idx_sys_now) 
		Global.save_system_conf()
		
#	elif Input.is_action_just_pressed("ui_accept2"):
#		if Functions.add_rom_to_fav([idx_sys_now,f_idx]):
#			$Notification.notif($ControlSection/PanelTitle/Label.text+" "+tr("ADDED_FAV"))
#		else:
#			$Notification.notif(tr("ALREADY_ADDED_FAV"))
#		Audio.get_node("ChangeItem").play()
		

	
func load_system_data(opt="none"):
	
	idx_sys_now = Functions.get_new_position_on_array(
		Global.systems_id,
		idx_sys_now,
		opt
	)
	roms = Global.systems_data_filtered[idx_sys_now]
	
	#sin archivos no cargamos nada
	if roms.size() < 1:
		$ControlSection.visible = false
		$PanelHelp/MarginContainer/HBoxContainer/A.visible = false
		return
	else:
		$PanelHelp/MarginContainer/HBoxContainer/A.visible = true
		$ControlSection.visible = true
	
	Config.set_conf_value("misc","selected_system",idx_sys_now) 
	sys_key = Global.systems_id[idx_sys_now]
	sys_name = Global.sys_data[sys_key]["name"]
	total_loaded_games = roms.size()
	
	#guardar ruta del sistema
	sys_path = Global.sys_data[sys_key]["path_emu"]
	
	#nombre del sistema
	$ControlSection/TitleEmu/VBx/HBx/Name.text = sys_name
	#la cantidad de juegos
	$ControlSection/TitleEmu/VBx/HBx/NumGames.text = tr("NUM_GAMES") % [total_loaded_games]

	if total_loaded_games > 1:
		$ControlSection/TitleEmu/VBx/HSlider.max_value = total_loaded_games-1
	else:
		$ControlSection/TitleEmu/VBx/HSlider.max_value = 1
	
	#dependiendo de la cantidad de juegos cargados mostrar espacio de covers necesarios
	for item in $ControlSection/GameCovers/HBoxContainer.get_children():
		item.modulate.a = 0
	if total_loaded_games == 1:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
	elif total_loaded_games == 2:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/ItemPrev.modulate.a = 1
	elif total_loaded_games == 3:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/ItemPrev.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item1.modulate.a = 1
	elif total_loaded_games == 4:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/ItemPrev.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item1.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item2.modulate.a = 1
	elif total_loaded_games == 5:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/ItemPrev.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item1.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item2.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item3.modulate.a = 1
	else:
		$ControlSection/GameCovers/HBoxContainer/Item0.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/ItemPrev.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item1.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item2.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item3.modulate.a = 1
		$ControlSection/GameCovers/HBoxContainer/Item4.modulate.a = 1
		
	#si es random, se cambia aleatoriamente el selected file
	if Global.random_game:
		Global.random_game = false
		randomize()
		var random_game_idx = Functions.get_new_position_on_array(
			roms,
			randi() % roms.size(),
			"none"
		)
		Global.conf.set_value(sys_key,"selected_file",random_game_idx)

	load_system_file_data()

func load_system_file_data(opt="none"):
#	print(str(roms[f_idx]))
	$Tween.stop_all()
	$TimerToShowWallpaper.stop()
	#quitar cualquier textura del wallpaper
	$GameBG.texture = null
	$GameBG.modulate.a = 0
	f_idx = Functions.get_new_position_on_array(
		roms,
		Global.conf.get_value(sys_key,"selected_file",0),
		opt
	)

	$ControlSection/TitleEmu/VBx/HSlider.value = f_idx

	Global.conf.set_value(sys_key,"selected_file",f_idx)
	Global.save_system_conf()
	var f_idx_extra = 0
	
	f_path = roms[f_idx][3]
	
	#el nombre de rom elegida
	#todo este bloque es para que el panel se ajuste al texto
	$ControlSection/PanelTitle.rect_size = Vector2(0,0)
	$ControlSection/PanelTitle/Label.text = ""
	$ControlSection/PanelTitle/Label.hide()
	$ControlSection/PanelTitle.rect_size = Vector2(712,77)
	$ControlSection/PanelTitle/Label.text = roms[f_idx][0]
	$ControlSection/PanelTitle/Label.show()
	
	roms[f_idx][1] = Functions.get_texture_from_path(roms[f_idx][1])
	
	#el cover de la rom
	if roms[f_idx][1] == null:
		$ControlSection/GameCovers/HBoxContainer/Item0/TextureRect.texture = load("res://assets/no_cover.jpg")
	else:
		$ControlSection/GameCovers/HBoxContainer/Item0/TextureRect.texture = roms[f_idx][1]
	$ControlSection/GameCovers/HBoxContainer/Item0/TextureRect2.texture = $ControlSection/GameCovers/HBoxContainer/Item0/TextureRect.texture
	
	#colocar cover al espacio izquierdo del cover principal
	f_idx_extra = Functions.get_new_position_on_array(
		roms,
		f_idx,
		"prev"
	)
	roms[f_idx_extra][1] = Functions.get_texture_from_path(roms[f_idx_extra][1])
	$ControlSection/GameCovers/HBoxContainer/ItemPrev/MarginContainer/Label.text = roms[f_idx_extra][0]
	$ControlSection/GameCovers/HBoxContainer/ItemPrev/TextureRect.texture = roms[f_idx_extra][1]
	$ControlSection/GameCovers/HBoxContainer/ItemPrev/TextureRect2.texture = $ControlSection/GameCovers/HBoxContainer/ItemPrev/TextureRect.texture
	
	f_idx_extra = f_idx
	#recorremos el resto de lugares para colocar los covers faltantes a partir del cover principal
	for n in [1,2,3,4]:
		f_idx_extra = Functions.get_new_position_on_array(
			roms,
			f_idx_extra,
			"next"
		)
		roms[f_idx_extra][1] = Functions.get_texture_from_path(roms[f_idx_extra][1])
		get_node("ControlSection/GameCovers/HBoxContainer/Item%d/MarginContainer/Label"%[n]).text = roms[f_idx_extra][0]
		get_node("ControlSection/GameCovers/HBoxContainer/Item%d/TextureRect"%[n]).texture = roms[f_idx_extra][1]
		get_node("ControlSection/GameCovers/HBoxContainer/Item%d/TextureRect2"%[n]).texture = get_node("ControlSection/GameCovers/HBoxContainer/Item%d/TextureRect"%[n]).texture

func _on_Timer_timeout():
	$Timer.wait_time = 0.09
	if last_action != "none":
		Audio.get_node("ChangeItem").play()
		load_system_file_data(last_action)

func _on_TimerToShowWallpaper_timeout():
	if total_loaded_games > 0 and roms[f_idx][2] != null:
		roms[f_idx][2] = Functions.get_texture_from_path(roms[f_idx][2])
		$GameBG.texture = roms[f_idx][2]
		$Tween.interpolate_property($GameBG,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.3,
			Tween.TRANS_LINEAR,Tween.TRANS_LINEAR)
		$Tween.start()


#---- lanzar emulador
func _on_TimerToStartEmu_timeout():
	var emu_args = Global.sys_data[sys_key]["args"]
	#añadir el path del archivo como ultimo argumento
	
	#si el sistema se configuró para solo usar el nombre
	#entonces en vez del path de la rom, se usará el nombre del archivo
	#útil para el emulador winkawaks
	if Global.sys_data[sys_key]["use_just_name"]:
		f_path = roms[f_idx][0]
		#en linea de comando sería nombrerom
		f_path = "%s" % [f_path]
	
	if emu_args.empty():
		emu_args.append(f_path)
	else:
		i = 0
		for a in emu_args:
			#de entre argumentos, reemplazar file por el path
			if a == "fi":
				emu_args[i] = f_path
			i += 1
	#process id
	Global.pid = -1
	var output = []
	if Global.sys_data[sys_key]["emulator"]:
		# guardamos el id del proceso para poder cerrarlo
		Global.pid = OS.execute(sys_path,emu_args,false,output)
	else:
		#metodo usando cmd
		#el OS.kill() no funcionaría con este...
#		f_path = f_path.replace("/","\\")
#		Global.pid = OS.execute("cmd.exe",["/C",f_path],false,output)
		# warning-ignore:return_value_discarded
		OS.shell_open(f_path)
	
	#crear una lista de argumentos quitando la referencia al archivo
	#ya que por alguna razón el emu_args y los argumentos de variable data están enlazados, ni idea de por qué
	i = 0
	for a in emu_args:
		#de entre argumentos, el path (o el nombre de rom) por "fi"
		if "\\" in a or a == f_path:
			emu_args[i] = "fi"
		i += 1
	
	Audio.get_node("Music").stop()
	SceneChanger.change_scene("res://MsgEmuExec.tscn")
