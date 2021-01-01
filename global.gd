extends Node

var f = File.new()

#textura para wallpaper principal
var main_wallpaper_texture = null

#ids alfabeticos de los sistemas
var systems_id = []

#toda informacion referente a los sistemas configurados
var sys_data = null

#aqui se almacenaran todas las texturas de covers (y wallpapers) de juegos de cada sistema (si no tienen será null)
#cada item (su index es del sistema) es otro array:nombre,textura cover, textura wallpaper,ruta del archivo
var systems_data_filtered = []

var pid = -1

func _enter_tree():
	#establacer textura de wallpaper principal si existe uno
	if f.file_exists("user://wallpaper.jpg"):
		main_wallpaper_texture = Functions.create_texture_from("user://wallpaper.jpg")
	#comprobacion de config
	if f.open("user://config_systems.txt", File.READ) != OK:
		return
	
	var data_text = f.get_as_text()
	f.close()
	var data_parse = JSON.parse(data_text)
	
	if data_parse.error != OK:
		print(str(data_parse.error))
		return
	
	#datos con los que trabajar
	sys_data = data_parse.result

	#si no hay sistemas configurados
	if sys_data["systems"].size() == 0:
		return

	systems_id = sys_data["systems"].keys()
	
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
		for fi in Functions.get_files(sys_data["systems"][s]["pathrom"]):
			#extraemos el formato del archivo y comprobamos si es un formato valido
			if Array(fi.rsplit(".",true,0)).back().to_lower() in sys_data["systems"][s]["formats"]:
				system_valid_files.append(fi)
		
		#recorrer los archivos validos, o sea las roms
		idx_file = 0
		for v_fi in system_valid_files:
			
			#nombre de archivo (sin su extensión)
			var basename = v_fi.get_basename()
			#ruta del cover del juego
			var path_cover = sys_data["systems"][s]["pathrom"]+"\\"+basename+".jpg"
			#y del wallpaper
			var path_wallpaper = sys_data["systems"][s]["pathrom"]+"\\"+basename+"_bg.jpg"
			
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
				basename,cover_texture,wallpaper_texture,sys_data["systems"][s]["pathrom"]+"\\"+v_fi
			])
			idx_file += 1 #fin del for de archivos validos en el sistema actual
		
		idx_sys += 1 #fin del for de systems

func save_system_json_conf():
	f.open("user://config_systems.txt", File.WRITE)
	f.store_string(JSON.print(sys_data, "  ", true))
	f.close()
