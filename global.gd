extends Node

var conf = ConfigFile.new()

var f = File.new()

#textura para wallpaper principal
var main_wallpaper_texture = null

#ids alfabeticos de los sistemas
var systems_id = []

#toda informacion referente a los sistemas configurados
var sys_data = {}#null

#aqui se almacenaran todas las texturas de covers (y wallpapers) de juegos de cada sistema (si no tienen será null)
#cada item (su index es del sistema) es otro array:nombre,textura cover, textura wallpaper,ruta del archivo
var systems_data_filtered = []

var pid = -1

func _enter_tree():
	#establacer textura de wallpaper principal si existe uno
	if f.file_exists("user://wallpaper.jpg"):
		main_wallpaper_texture = Functions.create_texture_from("user://wallpaper.jpg")
	
	# carga de datos de sistemas configurados
	
	var err
	err = conf.load("user://systems.ini")
	if err == ERR_FILE_NOT_FOUND:
		#si no existe el archivo se crea uno
		err = conf.save("user://systems.ini")
	
	systems_id = conf.get_sections()
	
	#si no hay sistemas configurados
	if systems_id.empty():
		return
	
	for s in systems_id:
		#nombre
		if not conf.has_section_key(s, "name"):
			conf.set_value(s, "name","Unknown")
		var sys_name = conf.get_value(s,"name")
		#es emulador?
		if not conf.has_section_key(s, "emulator"):
			conf.set_value(s, "emulator",true)
		var is_emu = conf.get_value(s,"emulator")
		#ruta del ejecutable del emulador
		if not conf.has_section_key(s, "path_emu"):
			conf.set_value(s, "path_emu","")
		var path_emu = conf.get_value(s,"path_emu")
		#ruta de los archivos
		if not conf.has_section_key(s, "pathrom"):
			conf.set_value(s, "pathrom","")
		var pathrom = conf.get_value(s,"pathrom")
		#argumentos de emulador
		if not conf.has_section_key(s, "args"):
			conf.set_value(s, "args",[])
		var args = conf.get_value(s,"args")
		#formatos validos a escanear
		if not conf.has_section_key(s, "formats"):
			conf.set_value(s, "formats",[])
		var formats = conf.get_value(s,"formats")
		#index de archivo elegido
		if not conf.has_section_key(s, "selected_file"):
			conf.set_value(s, "selected_file",0)
		var selected_file = conf.get_value(s,"selected_file")
		#usar solo nombre de archivo (para poder usar emuladores como winkawaks)
		#nope... no ha funcionado
#		if not conf.has_section_key(s, "use_just_name"):
#			conf.set_value(s, "use_just_name",0)
#		var use_just_name = conf.get_value(s,"use_just_name")

		sys_data[s] = {
			"name" : sys_name,
			"emulator" : is_emu,
			"path_emu" : path_emu,
			"pathrom" : pathrom,
			"args" : args,
			"formats" : formats,
			"selected_file" : selected_file,
#			"use_just_name" : use_just_name
		}
	#guardar keys de configuracion  en caso de que no tenía
	conf.save("user://systems.ini")
	
	#indice del sistema
	var idx_sys = 0
	#indice del archivo
	# warning-ignore:unused_variable
	var idx_file = 0
		
	# --------- creando texturas ---------
	# i representará el idx del sistema elegido
	#recorremos los sistemas disponibles
	for s in systems_id:
		#lista con las roms o archivos validos del sistema
		var system_valid_files = []
		#añadir a lista el array vacio del sistema en la iteracion actual
		systems_data_filtered.append([])
		
		#y recorremos los archivos asociados al sistema
		for fi in Functions.get_files(sys_data[s]["pathrom"]):
			#extraemos el formato del archivo y comprobamos si es un formato valido
			if Array(fi.rsplit(".",true,0)).back().to_lower() in sys_data[s]["formats"]:
				system_valid_files.append(fi)
		
		#recorrer los archivos validos, o sea las roms
		idx_file = 0
		for v_fi in system_valid_files:
			
			#nombre de archivo (sin su extensión)
			var basename = v_fi.get_basename()
			#ruta del cover del juego
			var path_cover = sys_data[s]["pathrom"]+"\\"+basename+".jpg"
			#y del wallpaper
			var path_wallpaper = sys_data[s]["pathrom"]+"\\"+basename+"_bg.jpg"
			
			#si el archivo tiene asociado un .jpg con su mismo nombre
			#este es el cover
			var cover_texture = null
			if f.file_exists(path_cover):
				cover_texture = Functions.create_texture_from(path_cover)

			var wallpaper_texture = null	
			#y si tiene otro como el anterior jpg pero que al final del nombre lleve _bg
			#este es el wallpaper
			if f.file_exists(path_wallpaper):
				wallpaper_texture = Functions.create_texture_from(path_wallpaper)
		
			#y finalmente guardar toda la informacion importante de la rom/archivo en la lista
			#nombre,textura cover, textura wallpaper, ruta archivo
			systems_data_filtered[idx_sys].append([
				basename,cover_texture,wallpaper_texture,sys_data[s]["pathrom"]+"\\"+v_fi
			])
			idx_file += 1 #fin del for de archivos validos en el sistema actual
		
		idx_sys += 1 #fin del for de systems

func save_system_conf():
	conf.save("user://systems.ini")
