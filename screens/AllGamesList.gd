extends Control

var f = File.new()

var rom_cover = preload("res://ui_elements/RomItemCover.tscn")
var rom_cover_instance = null

var Functions = load("res://scripts/Functions.gd").new()
var ROMDB = load("res://scripts/ROMDB.gd").new()

#ruta emulador o "
var path_emu = ""
#ruta de carpetas de juegos de un sistema o ""
var path_roms = ""
#ruta de un archivo incluyendo extensión
var path_file = ""

#index del sistema seleccionado
var idx_sys_now = Config.get_conf_value("roms","selected_system",0)

var empty_list = true

#lista de roms del sistema (o de favoritos)
var list_roms = []

func _process(_delta):
	
	if !empty_list and Input.is_action_just_pressed("ui_accept") and !$CtrlLoadingRom.visible:
		
		if Vars.show_favorites:
			#pasar key a index
			idx_sys_now = Array(Vars.systems_id).find(list_roms[$ScrollContainer.card_current_index][3])
		
		path_emu = ROMDB.get_conf_value(Vars.systems_id[idx_sys_now],"path_emu","")
		path_roms = ROMDB.get_conf_value(Vars.systems_id[idx_sys_now],"path_rom","")
		path_file = "%s/%s" % [ path_roms, list_roms[$ScrollContainer.card_current_index][0] ]
		
		if !f.file_exists(path_file):
			print("Error opening %s"%[path_file])
			$Notification.notif("File doesn't exists (read log)")
			return
		else:
			set_rom_background_image($ScrollContainer.card_current_index)
			execute_file()
			
	elif !Vars.show_favorites and Input.is_action_just_pressed("ui_down") and !$CtrlLoadingRom.visible:
		if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			change_system("next")
	
	elif !Vars.show_favorites and Input.is_action_just_pressed("ui_up") and !$CtrlLoadingRom.visible:
		if !Input.is_action_pressed("ui_left") and !Input.is_action_pressed("ui_right"):
			change_system("prev")
	
	elif !empty_list and Input.is_action_just_pressed("ui_alternative_action") and !$CtrlLoadingRom.visible:
		
		Audio.get_node("Alert").play()
		var fav_item = list_roms[$ScrollContainer.card_current_index]
		
		if Vars.show_favorites:
			if Functions.is_array_in_array(fav_item,Vars.favorite_roms):
				Vars.favorite_roms.erase(fav_item)
				ROMDB.save_rom_db()
				$Notification.notif("FAVREMOVED")
				# warning-ignore:return_value_discarded
				get_tree().reload_current_scene()

		else:
				
			if Functions.is_array_in_array(fav_item,Vars.favorite_roms):
				Vars.favorite_roms.erase(fav_item)
				ROMDB.save_rom_db()
				$Notification.notif("FAVREMOVED")
			else:
				#añadir a favoritos
				Vars.favorite_roms.append(fav_item)
				ROMDB.save_rom_db()
				$Notification.notif("FAVADDED")
	
	elif Input.is_action_just_pressed("ui_cancel") and !$CtrlLoadingRom.visible:
		Audio.get_node("GoBack").play()
		_on_TitleWindow_btn_back_pressed()

func _ready():
	
	#debug, ocultar en release
	#ROMDB.load_rom_db()
	
	if Vars.systems_id.size() <= 0:
		empty_list = true
		load_roms()
		#SceneChanger.change_scene("res://screens/AddSystem.tscn")
		return
	
	#arreglar error de index
	if idx_sys_now > Vars.systems_id.size() - 1:
		idx_sys_now = 0
	
	
	#establecer lista de roms sobre el cual trabajar
	if Vars.show_favorites:
		$PanelHelp/Hbx2/UD.visible = false
		$PanelHelp/Hbx/HBoxContainer2/Label.text = tr("FAVREMOVE")
		list_roms = Vars.favorite_roms
	else:
		list_roms = Vars.rom_data[idx_sys_now]	

	
	#ocultar mouse
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	#si no hay sistemas configurados
	if Vars.systems_id.empty():
		$ScrollContainer.visible = false
		$CtrlTitle.visible = false
		$HbxSliderTotalGames.visible = false
		return
	#si hay sistemas ocultar mensaje
	else:
		$LblEmptySystems.visible = false

	if Vars.show_favorites:
		$TitleWindow.set_title("FAVORITES")
	else:
		$TitleWindow.set_title(Vars.sys_data[Vars.systems_id[idx_sys_now]]["name"])

	load_roms()

func change_system(opt="next"):
	
	#clear_list()
	
	idx_sys_now = Functions.get_new_position_on_array(
		Vars.systems_id,
		idx_sys_now,
		opt
	)
	Config.set_conf_value("roms","selected_system",idx_sys_now)
	
	Audio.get_node("ChangeSection").play()
	SceneChanger.change_scene("res://screens/AllGamesList.tscn")
	#load_roms()

func load_roms():
	
	#total de elementos cargados
	var i = 0
	
	#agregar elementos según cuantas roms haya del sistema elegido
	for r in list_roms:
		rom_cover_instance = rom_cover.instance()
		rom_cover_instance.set_title(r[0].get_basename())
		rom_cover_instance.cover = r[1]
		rom_cover_instance.bg = r[2]
		$ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.add_child(rom_cover_instance)
		i += 1

	#si hay objetos cargar titulo panel u ocultar
	if i > 0:
		
		if Vars.show_favorites:
			$ScrollContainer.card_current_index = Functions.get_new_position_on_array($ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children(),Config.get_conf_value("roms","fav_selected_file",0)) #
		else:
			$ScrollContainer.card_current_index = Functions.get_new_position_on_array($ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children(),ROMDB.get_conf_value(Vars.systems_id[idx_sys_now],"selected_file",0))
		
		$ScrollContainer._ready()
		update_title_panel()
		empty_list = false
		set_rom_background_image($ScrollContainer.card_current_index)
	else:
		empty_list = true
		$CtrlTitle/Panel/Label.text = tr("EMPTYLIST")
		$HbxSliderTotalGames.visible = false
		return
		
	$HbxSliderTotalGames/VBxHSlider/HSlider.min_value = 1
	$HbxSliderTotalGames/VBxHSlider/HSlider.max_value = i
	$HbxSliderTotalGames/VBxHSlider/HSlider.value = $ScrollContainer.card_current_index + 1

	$HbxSliderTotalGames/Label.text = tr("NUM_GAMES") % [i]

#func clear_list():
#	for c in $ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children():
#		c.queue_free()

func update_title_panel():
	###########errores con fuera de index en array, y el selected file de systems.ini---------------
	
	#el nombre de rom elegida
	#todo este bloque es para que el panel se ajuste al texto
	$CtrlTitle/Panel/Label.text = ""
	$CtrlTitle/Panel.rect_size = Vector2(0,0)
	$CtrlTitle/Panel/Label.hide()
	$CtrlTitle/Panel.rect_size = Vector2(144,77)
	
	#arreglar idx fuera de index
	$ScrollContainer.card_current_index = Functions.get_new_position_on_array($ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children(),$ScrollContainer.card_current_index)
	
	$CtrlTitle/Panel/Label.text = list_roms[$ScrollContainer.card_current_index][0].get_basename()
	$CtrlTitle/Panel/Label.show()
	pass


func execute_file():
	$ScrollContainer.can_move_menu = false
	$CtrlLoadingRom/Tween.interpolate_property($CtrlLoadingRom/VBx/FontAwesome,"rect_rotation",0,360,5,Tween.TRANS_LINEAR)
	$CtrlLoadingRom/Tween.start()
	$CtrlLoadingRom.visible = true
	$CtrlLoadingRom/Timer.start()
	yield($CtrlLoadingRom/Timer,"timeout")
	
	#ejecutar juego
	
	#clave del sistema (nes, wii, snes...) a partir del index numerico
	var sys_key = Vars.systems_id[idx_sys_now]
	
	#texto con el comando
	var sys_command = Vars.sys_data[sys_key]["command"]
	
	#reemplazar ROM, ROMRAW, ROMNAME, ROMNAMERAW con el archivo elegido
	#ruta de rom entre comillas
	if '%%ROM%%' in sys_command:
		sys_command = sys_command.replace('%%ROM%%','"%s"'%[path_file])
	#ruta de rom sin comillas
	elif '%%ROMRAW%%' in sys_command:
		sys_command = sys_command.replace('%%ROMRAW%%','%s'%[path_file])
	#solo el nombre de rom sin extensión entre comillas
	elif '%%ROMNAME%%' in sys_command:
		sys_command = sys_command.replace('%%ROMNAME%%','"%s"'%[path_file.get_file().get_basename()])
	#solo el nombre de rom sin extensión sin comillas
	elif '%%ROMNAMERAW%%' in sys_command:
		sys_command = sys_command.replace('%%ROMNAMERAW%%','%s'%[path_file.get_file().get_basename()])	
	#sin ninguna de las condiciones anteriores entonces command necesita al menos un ROM en el texto
	else:
		failed_execute_file("Command String Incomplete")
		return
	
	print("Loading content...")
	print("Command: %s %s"%[path_emu,sys_command.replace(",","")])	
	#convertir sys_command de string a array para OS.execute()
	sys_command = sys_command.split(", ",true)

	Vars.pid = -1
	#output del proceso lanzado
	var output = []
	var shell_open_err = 0
	
	#si no hay ruta de emulador el archivo se lanzará directamente
	if path_emu == "":
		#metodo usando cmd
		#el OS.kill() no funcionaría con este...
		shell_open_err = OS.shell_open(path_file)
	else:
		Vars.pid = OS.execute(path_emu,sys_command,false,output)
	
	if path_emu == "":
		#archivo lanzado!
		if shell_open_err == OK:
			Audio.get_node("Music").stop()
			print("Loaded file")
			$CtrlLoadingRom/VBx.visible = false
			SceneChanger.change_scene("res://screens/ExecutedContent.tscn")
		else:
			failed_execute_file("Error Loading Content %d %s"%[shell_open_err])
			return
	else:
		#emulador cargado!
		if Vars.pid > 0:
			Audio.get_node("Music").stop()
			print("Loaded content with emulator %s"%[str(output)])
			$CtrlLoadingRom/VBx.visible = false
			SceneChanger.change_scene("res://screens/ExecutedContent.tscn")
		else:
			failed_execute_file("Error Loading Content %d %s"%[Vars.pid,str(output)])
			return

func failed_execute_file(txt="Error Loading Content"):
	$ScrollContainer.can_move_menu = true
	$CtrlLoadingRom/Tween.stop_all()
	$CtrlLoadingRom.visible = false
	$Notification.notif(txt)


func set_rom_background_image(idx):

	if !Vars.show_favorites:
		$Background.update_launcher_theme(Vars.sys_data[Vars.systems_id[idx_sys_now]]["custom_theme"])
	
	#evitar error de index invalido
	if list_roms.size()-1 < idx:
		return
	
	var rom_bg = $ScrollContainer/CenterContainer/MarginContainer/HBoxContainer.get_children()[idx].bg
	rom_bg = Functions.get_texture_from_path(rom_bg)
	Vars.rom_img_background = rom_bg
	$Background.set_temporal_bg(rom_bg)

#----------- señales --------------

func _on_TitleWindow_btn_back_pressed():
	if Vars.systems_id.size() <= 1 or Vars.show_favorites:
		SceneChanger.change_scene("res://screens/MainMenu.tscn")
	else:
		SceneChanger.change_scene("res://screens/SelectSystemList.tscn")

func _on_TitleWindow_exit_confirm_dialog_show():
	set_process_input(false)
	$ScrollContainer.can_move_menu = false


func _on_TitleWindow_exit_confirm_dialog_hide():
	set_process_input(true)
	$ScrollContainer.can_move_menu = true

#al hacer scroll se actualiza cual rom se habia elegido y se guarda en systems.ini
func _on_ScrollContainer_scrolled(current_index):
	
	$Background.set_temporal_bg()
	
	if Vars.show_favorites:
		Config.set_conf_value("roms","fav_selected_file",current_index)
	else:
		ROMDB.set_conf_value(Vars.systems_id[idx_sys_now],"selected_file",current_index)
	
	update_title_panel()
	$HbxSliderTotalGames/VBxHSlider/HSlider.value = current_index + 1
	
	$TimerShowBG.start()
	yield($TimerShowBG,"timeout")
	
	set_rom_background_image(current_index)
	
