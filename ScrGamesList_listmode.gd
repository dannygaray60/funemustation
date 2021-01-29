extends Control

var btn_rom = preload("res://Button_rom_list.tscn")
var btn_rom_instance = null

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

var roms_btns = []

func _ready():
	

	idx_sys_now = Functions.get_new_position_on_array(
		Global.systems_id,
		Config.get_conf_value("misc","selected_system"),
		"none"
	)
	load_system_data()
	$TimerToShowWallpaper.start()

func _process(_delta):
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		Audio.get_node("ChangeItem").play()
		
	elif Input.is_action_just_pressed("ui_cancel"):
		Audio.get_node("GoBack").play()
		Config.set_conf_value("misc","selected_system",idx_sys_now) 
		Global.save_system_conf()
		SceneChanger.change_scene("res://MainScr.tscn")
		
	elif Input.is_action_just_pressed("ui_left"):
		$GameBG.texture = null
		last_action = "none"
		Audio.get_node("ChangeSection").play()
		$AnimationPlayer.play("change_to_left")
		
	elif Input.is_action_just_pressed("ui_right"):
		$GameBG.texture = null
		last_action = "none"
		Audio.get_node("ChangeSection").play()
		$AnimationPlayer.play("change_to_right")

func load_system_data(opt="none"):
	
	#sin archivos no cargamos nada
	if Global.systems_data_filtered[idx_sys_now].size() < 1:
		$ControlSection.visible = false
		return
	else:
		$ControlSection.visible = true

	idx_sys_now = Functions.get_new_position_on_array(
		Global.systems_id,
		idx_sys_now,
		opt
	)
	Config.set_conf_value("misc","selected_system",idx_sys_now) 
	sys_key = Global.systems_id[idx_sys_now]
	sys_name = Global.sys_data[sys_key]["name"]
	total_loaded_games = Global.systems_data_filtered[idx_sys_now].size()
	
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
	
	#cargar roms y asignarles un boton
	
#	Input.is_action_just_pressed("ui_down")
#	$ControlSection/ControlList/Scrll.scroll_vertical = 100
#	print(str( Global.conf.get_value(sys_key,"selected_file",0) ))
	#primero limpiar la lista de botones
	for b in get_node("ControlSection/ControlList/Scrll/Margin/VBxRoms").get_children():
		$ControlSection/ControlList/Scrll/Margin/VBxRoms.remove_child(b)
	#recorrer lista de roms del sistema elegido
	i = 0
	for r in Global.systems_data_filtered[idx_sys_now]:
		btn_rom_instance = btn_rom.instance()
		btn_rom_instance.rom_data = r
		btn_rom_instance.text = r[0]
		btn_rom_instance.idx = i
		$ControlSection/ControlList/Scrll/Margin/VBxRoms.add_child(btn_rom_instance)
		btn_rom_instance.connect("focused",self,"_on_rom_focus")
		i += 1
	
	roms_btns = get_node("ControlSection/ControlList/Scrll/Margin/VBxRoms").get_children()
	if !roms_btns.empty():
		roms_btns[Global.conf.get_value(sys_key,"selected_file",0)].grab_focus()

func load_system_file_data(idx=-1):
	$Tween.stop_all()
	$TimerToShowWallpaper.stop()
	#quitar cualquier textura del wallpaper
	$GameBG.texture = null
	$GameBG.modulate.a = 0
	
	if idx < 0:
		f_idx = Global.conf.get_value(sys_key,"selected_file",0)
	else:
		f_idx = Functions.get_new_position_on_array(
			Global.systems_data_filtered[idx_sys_now],
			idx,
			"none"
		)

	Global.conf.set_value(sys_key,"selected_file",f_idx)
	Global.save_system_conf()
	
	f_path = Global.systems_data_filtered[idx_sys_now][f_idx][3]
	
#	roms_btns = get_node("ControlSection/ControlList/Scrll/Margin/VBxRoms").get_children()
#	if !roms_btns.empty():
#		roms_btns[f_idx].grab_focus()
		
	Global.systems_data_filtered[idx_sys_now][f_idx][1] = Functions.get_texture_from_path(Global.systems_data_filtered[idx_sys_now][f_idx][1])
	if Global.systems_data_filtered[idx_sys_now][f_idx][1] == null:
		$ControlSection/ControlList/Cover/Img1.texture = load("res://assets/no_cover.jpg")
	else:
		$ControlSection/ControlList/Cover/Img1.texture = Global.systems_data_filtered[idx_sys_now][f_idx][1]

func _on_rom_focus(index,_rom_data):
	load_system_file_data(index)


func _on_TimerToStartEmu_timeout():
	pass # Replace with function body.


func _on_TimerToShowWallpaper_timeout():
	pass # Replace with function body.
