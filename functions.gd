extends Node

var dir = Directory.new()

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

func create_texture_from(filepath):
#	print("creando textura de %s"%filepath)
	var img = Image.new()
	var err = img.load(filepath)
	if err!=0:
		print("Error cargando la imagen: "+filepath)
		return null

	var img_tex = ImageTexture.new()
	img_tex.create_from_image(img,7)#el 7, todo por defecto
#	print("Textura creada para: "+filepath)
	return img_tex

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
