extends Node

var dir = Directory.new()
var f = File.new()

#para saber si un array está dentro de otro array
func is_array_in_array(array_find,array_base):
	
	for arr in array_base:
		if array_find == arr: 
			return true
	
	return false

func get_dirs(path):
	var dirs = []
	dir.open(path)
	dir.list_dir_begin(true)
	var d = dir.get_next()
	while d != "":
		if dir.current_is_dir():
			dirs+= [d]
		d = dir.get_next()
	#retornara un string con los nombres de las carpetas
	return dirs

func get_files(path):
	var files = []
	dir.open(path)
	dir.list_dir_begin(true)
	var fd = dir.get_next()
	while fd !="":
		files+= [fd]
		fd = dir.get_next()
	#retornara un string con el nombre y extension del archivo
	return files

#para obtener el anterior/siguiente index de elemento de un array, a partir del item actual
#arr = array para navegar
#current_pos = posicion actual en el array
#direction = hacia donde movernos en relacion a current_pos (next o prev)
#retornara la nueva posicion dentro del array elegido
func get_new_position_on_array(arr,current_pos=0,direction="none"):
	# warning-ignore:unused_variable
	var new_pos = current_pos
	var arr_size = arr.size()
	
	#si no es ninguna direccion pero se excede el limite del array
	if direction == "none" and current_pos > arr_size-1:
		return 0
	
	#si la posicion actual es la ultima del array y queremos ir adelante
	#regresamos a la primera posicion
	if current_pos==arr_size-1 and direction=="next":
		new_pos = 0
	#si la posicion actual es la primera y queremos ir atrás
	#avanzamos hasta la ultima posicion
	elif current_pos==0 and direction=="prev":
		new_pos = arr_size-1
	#las demás posibilidades dentro de los limites anteriores
	else:
		if direction=="next":
			new_pos=current_pos+1
		elif direction=="prev":
			new_pos=current_pos-1
	#si por alguna razon la nueva posicion es mayor o menor del index del array
	#cambiamos este valor a 0
	if new_pos<0 or new_pos>arr_size-1:
		new_pos=0
		print("la nueva posicion sobrepasa index del array, regresamos 0")
	#retornamos valor final, este será la nueva posicion del array
	return new_pos

#Retornar una fecha convertida a texto amigable
#o solo mostrar el formato pero con los elementos reordenados según el lenguaje
#from_date format : 31-12-2021
func get_date(from_date="now", friendly=true):

	var locale = TranslationServer.get_locale()
	var date_now = OS.get_date()
	var date = from_date

	if from_date == "now":
		#obtener fecha actual ya agregada a un array simple
		date = [ date_now["day"],date_now["month"],date_now["year"] ]
	else:
		#convertir a array
		date = from_date.split("-")
		#si el array de la fecha es incorrecto
		if date.size() < 3:
			return "ERROR_WITH_DATE:" + from_date

	#convertir a texto amigable o reordenar

	if locale == "es" and friendly:
		date = "%s de %s, %s" % [ str(date[0]).pad_zeros(2), Vars.months[date[1]][1], date[2] ]

	elif locale == "es" and !friendly:
		date = "%s-%s-%s" % [date[0], date[1], date[2]]

	elif friendly:
		date = "%s %s, %s" % [ Vars.months[date[1]][0], str(date[0]).pad_zeros(2), date[2] ]

	elif !friendly:
		date = "%s-%s-%s" % [date[1], date[0], date[2]]

	return date

#Retornar tiempo ya sea en formato 24 o 12
#from_time = 24:00
func get_time(from_time="now", ampm=true):
	
	var time = OS.get_time()
	var ampm_string = "AM"
	
	if from_time == "now":
		time = "%s:%s" % [ str(time["hour"]).pad_zeros(2), str(time["minute"]).pad_zeros(2) ]

	time = time.split(":")
	time = [ int(time[0]), int(time[1]) ]
	
	#si el array del tiempo es incorrecto
	if time.size() < 2:
		return "ERROR_WITH_TIME:" + from_time
		
	if ampm:
		if time[0] > 12:
			ampm_string = "PM"
			time[0] = time[0] - 12
		time = "%s:%s %s" % [ str(time[0]).pad_zeros(2), str(time[1]).pad_zeros(2), ampm_string]
	else:
		time = from_time

	return time

#retorna una textura a partir de p (path) o retorna textura si p es textura
func get_texture_from_path(p):
	if p == null:
		return
	if typeof(p) == TYPE_STRING:
		p = create_texture_from(p)
	return p

func create_texture_from(filepath):
	if !f.file_exists(filepath):
		"Error loading image, doesn't exists."
		return null
#	print("creando textura de %s"%filepath)
	var img = Image.new()
	var err = img.load(filepath)
	if err!=0:
		print("Error loading image: "+filepath)
		return null

	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img,7)#el 7, todo por defecto
#	print("Textura creada para: "+filepath)
	return img_tex
