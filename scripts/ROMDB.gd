extends Node

var Functions = load("res://scripts/Functions.gd").new()

var conf = ConfigFile.new()
var dir = Directory.new()

var f = File.new()



var data_path = OS.get_executable_path().get_base_dir()+"/fes_data"

func reset_vars():
	Vars.systems_id = []
	Vars.sys_data = {}
	Vars.rom_data = []

func update_db():
	reset_vars()
	print("Starting rom database update...")
	#y crearla en caso de que no exista
	if !dir.dir_exists(data_path):
		dir.make_dir(data_path)
	
	# carga de datos de sistemas configurados
	var err
	err = conf.load(data_path+"/systems.ini")
	if err == ERR_FILE_NOT_FOUND:
		print("Creating new systems.ini")
		#si no existe el archivo se crea uno
		err = conf.save(data_path+"/systems.ini")
		
	#si al crear systems.ini ocurrió algun error
	if err != OK:
		return err
	
	Vars.systems_id = conf.get_sections()
	
	#si no hay sistemas configurados
	if Vars.systems_id.empty():
		print("systems.ini doesn't have any system configured")
		#archivo de db vacío
		save_rom_db()
		return OK
	
	for s in Vars.systems_id:
		#nombre
		if not conf.has_section_key(s, "name"):
			conf.set_value(s, "name","Unknown")
		var sys_name = conf.get_value(s,"name")
		#ruta del ejecutable del emulador
		#dejar vacío para que el archivo se ejecute directamente (para archivos que no son roms a emular)
		if not conf.has_section_key(s, "path_emu"):
			conf.set_value(s, "path_emu","")
		var path_emu = conf.get_value(s,"path_emu")
		#ruta de los archivos
		if not conf.has_section_key(s, "path_rom"):
			conf.set_value(s, "path_rom","")
		var path_rom = conf.get_value(s,"path_rom")
		#línea de comandos del emulador
		if not conf.has_section_key(s, "command"):
			conf.set_value(s, "command","%%ROMRAW%%")
		var command = conf.get_value(s,"command")
		#formatos validos a escanear
		if not conf.has_section_key(s, "formats"):
			conf.set_value(s, "formats","")
		var formats = conf.get_value(s,"formats")
		#index de archivo elegido
		if not conf.has_section_key(s, "selected_file"):
			conf.set_value(s, "selected_file",0)
		var selected_file = conf.get_value(s,"selected_file")
		#nombre de color (de los disponibles en vars o numero hexadecimal
		#index de archivo elegido
		if not conf.has_section_key(s, "custom_theme"):
			conf.set_value(s, "custom_theme","default")
		var custom_theme = conf.get_value(s,"custom_theme")

		Vars.sys_data[s] = {
			"name" : sys_name,
			"path_emu" : path_emu,
			"path_rom" : path_rom,
			"command" : command,
			"formats" : formats,
			"selected_file" : selected_file,
			"custom_theme" : custom_theme,
		}
	#guardar keys de configuracion  en caso de que no tenía
	conf.save(data_path+"/systems.ini")

	#indice del sistema
	var idx_sys = 0
	#indice del archivo
	# warning-ignore:unused_variable
	var idx_file = 0
		
	# i representará el idx del sistema elegido
	#recorremos los sistemas disponibles
	for s in Vars.systems_id:
		#lista con las roms o archivos validos del sistema
		var system_valid_files = []
		#añadir a lista el array vacio del sistema en la iteracion actual
		Vars.rom_data.append([])
		
		#convertir string a array
		Vars.sys_data[s]["formats"] = Vars.sys_data[s]["formats"].split(", ")
		
		#y recorremos los archivos asociados al sistema
		for fi in Functions.get_files(Vars.sys_data[s]["path_rom"]):
			#extraemos el formato del archivo y comprobamos si es un formato valido
			if Array(fi.rsplit(".",true,0)).back().to_lower() in Vars.sys_data[s]["formats"]:
				system_valid_files.append(fi)
		
		#crear una carpeta "media" dentro del path_rom
		#es en donde se guardaran los covers
		if !dir.dir_exists(Vars.sys_data[s]["path_rom"]+"/media"):
			dir.make_dir(Vars.sys_data[s]["path_rom"]+"/media")
		
		#recorrer los archivos validos, o sea las roms
		idx_file = 0
		for v_fi in system_valid_files:
			
			#nombre de archivo (sin su extensión)
			var basename = v_fi.get_basename()
			
			#guardar textura del cover o la ruta
			var cover_texture = null
			#si existe ruta del cover del juego
			if f.file_exists(Vars.sys_data[s]["path_rom"]+"/media/"+basename+".jpg"):
				cover_texture = Vars.sys_data[s]["path_rom"]+"/media/"+basename+".jpg"
			
			#y del wallpaper
			var wallpaper_texture = null
			if f.file_exists(Vars.sys_data[s]["path_rom"]+"/media/"+basename+"_bg.jpg"):
				wallpaper_texture = Vars.sys_data[s]["path_rom"]+"/media/"+basename+"_bg.jpg"

			#y finalmente guardar toda la informacion importante de la rom/archivo en la lista
			#nombre archivo,ruta y/o textura cover, ruta y/o textura wallpaper,
			#key del sistema
			Vars.rom_data[idx_sys].append([
				basename+"."+v_fi.get_extension(),
				cover_texture,
				wallpaper_texture,
				s
			])
			idx_file += 1 #fin del for de archivos validos en el sistema actual
		
		idx_sys += 1 #fin del for de systems

	#al final de todo guardar los datos escaneados a la db
	return save_rom_db()


#guardar un valor de configuracion
func set_conf_value(section,key,value):
	#cargar el archivo
	var err = conf.load(Vars.data_path+"/systems.ini")
	if err != OK:
		print("load error with configfile: %d (config.gd)"%[err])
		return
	conf.set_value(section,key,value)
	err = conf.save(data_path+"/systems.ini")
	return err

#cargar un valor de configuracion
func get_conf_value(section,key,default):
	#cargar el archivo
	var err = conf.load(data_path+"/systems.ini")
	if err != OK:
		print("load error with systems.ini: %d (ROMDB.gd)"%[err])
		return
	err = conf.get_value(section,key,default)
	return err

#guardar cambios a systems.ini
func save_system_conf():
	conf.save(data_path+"/systems.ini")
	
#guardar datos a archivo roms.fesdb
func save_rom_db():
	# guardar datos de sistemas configurados
	var err = 0
	var filepath = data_path+"/roms.fesdb"
	
	err = f.open(filepath,File.WRITE)

	if err == OK:
		f.store_var(serialize_persistent_variables())
		print("Saving scanned data on roms.fesdb")
	
	f.close()
	return err

func load_rom_db(force_update=false):
	var err = 0
	var filepath = data_path+"/roms.fesdb"

	err = f.open(filepath,File.READ)
	var romsdata = []
	
	#si no hay archivo db o se fuerza escanear de nuevo
	if err == ERR_FILE_NOT_FOUND or force_update:
		err = update_db()
	elif err == OK:
		romsdata = f.get_var()
		Vars.systems_id = romsdata["systems_id"]
		Vars.sys_data = romsdata["sys_data"]
		Vars.rom_data = romsdata["rom_data"]
		Vars.favorite_roms = romsdata["favorite_roms"]


	f.close()
	return err

func serialize_persistent_variables():
	var save_dict = {}
	save_dict = {
		"systems_id": Vars.systems_id,
		"sys_data": Vars.sys_data,
		"rom_data": Vars.rom_data,
		"favorite_roms": Vars.favorite_roms,
	}
	return save_dict
