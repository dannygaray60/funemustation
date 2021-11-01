extends Node

var f = File.new()
var d = Directory.new()
var conf = ConfigFile.new()

var output_check_config_file = ""

func _ready():
	load_buttons_config()
	check_config_file()

func check_config_file(configfile=Vars.data_path+"/settings.ini"):
	
	output_check_config_file = ""
	var err
	
	if !d.dir_exists(Vars.data_path):
		output_check_config_file += "[fes_data] directory doesn't exists. Creating Directory... Result: %d\n\n" % [d.make_dir(Vars.data_path)]	
		
	err = conf.load(configfile)
	
	if err == ERR_FILE_NOT_FOUND:
		#si no existe el archivo se crea uno
		err = conf.save(configfile)
		output_check_config_file += "[settings.ini] doesn't exists. Creating File... Result: %d\n\n" % [err]	



	if not conf.has_section_key("misc", "nickname"):
		conf.set_value("misc", "nickname", "dannygaray60")

	if not conf.has_section_key("video", "theme"):
		conf.set_value("video", "theme", "blue")
		
	if not conf.has_section_key("video", "borderless_fullscreen"):
		conf.set_value("video", "borderless_fullscreen", false)
	
	if not conf.has_section_key("video", "fullscreen"):
		conf.set_value("video", "fullscreen", false)
		
	if not conf.has_section_key("video", "bg_darkness"):
		conf.set_value("video", "bg_darkness", 0.5)
	
	if not conf.has_section_key("sound", "music"):
		conf.set_value("sound", "music", 0.5)
		
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"),linear2db(conf.get_value("sound", "music", 0.5)))
	
	if not conf.has_section_key("sound", "effects"):
		conf.set_value("sound", "effects", 0.5)
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("effects"),linear2db(conf.get_value("sound", "effects", 0.5)))	
	
	if not conf.has_section_key("roms", "selected_system"):
		conf.set_value("roms", "selected_system",0)
		
	if not conf.has_section_key("roms", "fav_selected_file"):
		conf.set_value("roms", "fav_selected_file",0)
		
	#ver roms en forma de lista?
#	if not conf.has_section_key("roms", "list_mode"):
#		conf.set_value("roms", "list_mode", false)
	
	#--------- idioma
	if not conf.has_section_key("misc", "lang"):
		var langlocale = TranslationServer.get_locale()
		if langlocale=="es" or langlocale.begins_with("es_") or langlocale.begins_with("es-"):
			langlocale="es"
		elif langlocale=="en" or langlocale.begins_with("en_") or langlocale.begins_with("en-"):
			langlocale="en"
		conf.set_value("misc", "lang", langlocale)
	TranslationServer.set_locale(conf.get_value("misc","lang","en"))
	
	if not conf.has_section_key("input", "input_mode"):
		conf.set_value("input", "input_mode", "keyboard")
	
	if not conf.has_section_key("input", "gamepad_mapping"):
		conf.set_value("input", "gamepad_mapping", "")
	
	if conf.get_value("input","gamepad_mapping") != "":
		#agregar mapping especial de control en caso de no ser reconocido
		Input.add_joy_mapping(conf.get_value("input", "gamepad_mapping"), true)
		
	if not conf.has_section_key("icons_btn", "ui_accept"):
		conf.set_value("icons_btn", "ui_accept", 3)
	if not conf.has_section_key("icons_btn", "ui_alternative_action"):
		conf.set_value("icons_btn", "ui_alternative_action", 7)
	if not conf.has_section_key("icons_btn", "ui_cancel"):
		conf.set_value("icons_btn", "ui_cancel", 5)
		
	# Store a variable if and only if it hasn't been defined yet
	#recorrer las acciones del inputmap (ui_left, ui_up etc)
	for a in InputMap.get_actions():
		
		if a in [
			"ui_accept",
			"ui_alternative_action",
			"ui_cancel",
			"ui_up",
			"ui_down",
			"ui_left",
			"ui_right",
			"combo1",
			"combo2",
			"combo3",
			"combo4",
		]:
		
			#lista de los botones de la accion (teclado)
			var k_btn_lst = []
			#y los del gamepad
			var j_btn_lst = []
			
			#referencia de botones de la accion
			for b in InputMap.get_action_list(a):
				#si el tipo es de teclado
				if b is InputEventKey:
					k_btn_lst.append(b.get_scancode_with_modifiers())
				#o el tipo es gamepad
				elif b is InputEventJoypadButton:
					j_btn_lst.append(b.button_index)
			#guardar esas referencias
			conf.set_value("keyboard", a, k_btn_lst)
			conf.set_value("gamepad", a, j_btn_lst)
	
	#guardar cambios predeterminados en el config nuevo
	err = conf.save(configfile)
	
	if err == OK:
		output_check_config_file += "Settings loaded.\n\n"
		
	#establecer si mostrar en pantalla completa o no
	#si el fullscreen es true
	if conf.get_value("video","fullscreen",false):
		OS.window_fullscreen = true
	else:
		OS.set_borderless_window(conf.get_value("video","borderless_fullscreen"))
	
	if OS.window_borderless:
		OS.set_window_size(OS.get_screen_size())
		OS.set_window_position(Vector2(0, 0))
	else:
		OS.set_window_maximized(true)

	return output_check_config_file

#guardar un valor de configuracion
func set_conf_value(section,key,value):
	#cargar el archivo
	var err = conf.load(Vars.data_path+"/settings.ini")
	if err != OK:
		print("load error with configfile: %d (config.gd)"%[err])
		return
	conf.set_value(section,key,value)
	err = conf.save(Vars.data_path+"/settings.ini")
	return err

#cargar un valor de configuracion
func get_conf_value(section,key,default):
	#cargar el archivo
	var err = conf.load(Vars.data_path+"/settings.ini")
	if err != OK:
		print("load error with configfile: %d (config.gd)"%[err])
		return
	err = conf.get_value(section,key,default)
	return err

#cargar toda la configuracion de botones desde .ini
func load_buttons_config(configfile=Vars.data_path+"/settings.ini"):
	
	var err = conf.load(configfile)
	
	if err == ERR_FILE_NOT_FOUND:
		return

	var sections
	var section_values
	
	sections = conf.get_section_keys("keyboard")
	#s = ui_up etc
	for s in sections:
		#InputMap.action_erase_events(s) #temporal
		section_values = conf.get_value("keyboard", s)
		#si el array con los botones no está vacío
		if !section_values.empty():
#			InputMap.action_erase_events(s)
			#recorrer la lista de los botones
			for b in section_values:
				var event = InputEventKey.new()
				event.scancode = int(b)
				InputMap.action_add_event(s, event)
				
				
	sections = conf.get_section_keys("gamepad")
	#s = ui_up etc
	for s in sections:
		section_values = conf.get_value("gamepad", s)
		#si el array con los botones no está vacío
		if !section_values.empty():
#			InputMap.action_erase_events(s)
			#recorrer la lista de los botones
			for b in section_values:
				var event = InputEventJoypadButton.new()
				event.button_index = int(b)
				InputMap.action_add_event(s, event)
