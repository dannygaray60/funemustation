extends Node

var f = File.new()
var d = Directory.new()
var conf = ConfigFile.new()

func _enter_tree():
	load_buttons_config()
	check_configfile()
	

#comprobar archivo de configuracion
#tambien funcionará para guardar toda la configuracion hecha en inputmap
func check_configfile(configfile="user://settings.ini"):
	var err
	err = conf.load("user://settings.ini")
	if err == ERR_FILE_NOT_FOUND:
		#si no existe el archivo se crea uno
		err = conf.save(configfile)
		
	# Store a variable if and only if it hasn't been defined yet
	#recorrer las acciones del inputmap (ui_left, ui_up etc)
	for a in InputMap.get_actions():
		
		#lista de los botones de la accion (teclado)
		var k_btn_lst = []
		#y los del joypad
		var j_btn_lst = []
		
		#referencia de botones de la accion
		for b in InputMap.get_action_list(a):
			#si el tipo es de teclado
			if b is InputEventKey:
				k_btn_lst.append(b.get_scancode_with_modifiers())
			#o el tipo es joypad
			elif b is InputEventJoypadButton:
				j_btn_lst.append(b.button_index)
		#guardar esas referencias
		conf.set_value("key", a, k_btn_lst)
		conf.set_value("joypad", a, j_btn_lst)
	
	#--------- idioma
	if not conf.has_section_key("misc", "lang"):
		var langlocale = TranslationServer.get_locale()
		if langlocale=="es" or langlocale.begins_with("es_") or langlocale.begins_with("es-"):
			langlocale="es"
		elif langlocale=="en" or langlocale.begins_with("en_") or langlocale.begins_with("en-"):
			langlocale="en"
		conf.set_value("misc", "lang", langlocale)
	TranslationServer.set_locale(conf.get_value("misc","lang","en"))

	if not conf.has_section_key("icons_btn", "ui_accept"):
		conf.set_value("icons_btn", "ui_accept", 1)
	if not conf.has_section_key("icons_btn", "ui_cancel"):
		conf.set_value("icons_btn", "ui_cancel", 3)
	
	if not conf.has_section_key("misc", "input_mode"):
		conf.set_value("misc", "input_mode", "keyboard")
	
	if not conf.has_section_key("misc", "gamepad_mapping"):
		conf.set_value("misc", "gamepad_mapping", "")
	
	if conf.get_value("misc","gamepad_mapping") != "":
		#agregar mapping especial de control en caso de no ser reconocido
		Input.add_joy_mapping(conf.get_value("misc", "gamepad_mapping"), true)
	
	if not conf.has_section_key("misc", "nickname"):
		conf.set_value("misc", "nickname", "dannygaray60")
		
	if not conf.has_section_key("misc", "show_btns_developer"):
		conf.set_value("misc", "show_btns_developer", true)
	
	if not conf.has_section_key("misc", "borderless"):
		conf.set_value("misc", "borderless", true)
	
#	if not conf.has_section_key("misc", "wallpaper_darkness"):
#		conf.set_value("misc", "wallpaper_darkness", 0.57)
	
	#establecer si mostrar en pantalla completa o no
	OS.set_borderless_window(conf.get_value("misc","borderless"))
	if OS.window_borderless:	
		OS.set_window_size(OS.get_screen_size())
		OS.set_window_position(Vector2(0, 0))
	
	#guardar cambios predeterminados en el config nuevo
	err = conf.save(configfile)
	
	#problemas guardando el archivo config
	if err != OK:
		print("error guardando archivo config: %d (config.gd)"%[err])
		return
	
	#si no hay problemas
	#establecer volumen en buses de audio
#	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(conf.get_value("audio", "music_ui")))


#cargar toda la configuracion de botones desde .ini
func load_buttons_config(configfile="user://settings.ini"):
	
	var err = conf.load(configfile)
	
	if err == ERR_FILE_NOT_FOUND:
		return

	var sections
	var section_values
	
	sections = conf.get_section_keys("key")
	#s = ui_up etc
	for s in sections:
		#InputMap.action_erase_events(s) #temporal
		section_values = conf.get_value("key", s)
		#si el array con los botones no está vacío
		if !section_values.empty():
#			InputMap.action_erase_events(s)
			#recorrer la lista de los botones
			for b in section_values:
				var event = InputEventKey.new()
				event.scancode = int(b)
				InputMap.action_add_event(s, event)
				
				
	sections = conf.get_section_keys("joypad")
	#s = ui_up etc
	for s in sections:
		section_values = conf.get_value("joypad", s)
		#si el array con los botones no está vacío
		if !section_values.empty():
#			InputMap.action_erase_events(s)
			#recorrer la lista de los botones
			for b in section_values:
				var event = InputEventJoypadButton.new()
				event.button_index = int(b)
				InputMap.action_add_event(s, event)

#guardar un valor de configuracion
func set_conf_value(section,key,value):
	#cargar el archivo
	var err = conf.load("user://settings.ini")
	if err != OK:
		print("error cargando configfile para nuevo valor: %d (config.gd)"%[err])
		return
	conf.set_value(section,key,value)
	err = conf.save("user://settings.ini")
	#si la configuracion es de audio, tambien establecemos el volumen del bus
#	if section == "audio":
#		match key:
#			"music_ui":
#				AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(value))
	return err

#cargar un valor de configuracion
func get_conf_value(section,key):
	#cargar el archivo
	var err = conf.load("user://settings.ini")
	if err != OK:
		print("error cargando configfile para obtener valor: %d (config.gd)"%[err])
		return
	err = conf.get_value(section,key)
	return err
