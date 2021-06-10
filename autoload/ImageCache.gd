extends Node

## --------------
## Intento fallido de guardar texturas en archivos...
## --------------

var f = File.new()

# elementos: path: textura / null
var images = {}

func _ready():
	load_cache()

func load_image_texture(img_path):
	
	if img_path is StreamTexture:
		return img_path
	
	elif !images.has(img_path) and typeof(img_path) == TYPE_STRING:
		images[img_path] = create_texture_from(img_path)
		#guardar
		save_cache()
		return images[img_path]
	
	elif images.has(img_path):
		print(str(images[img_path]))
		return images[img_path]

	else:
		return null

func save_cache():
	# guardar datos de sistemas configurados
	var err = 0
	var filepath = Vars.data_path+"/images.fescache"
	
	err = f.open(filepath,File.WRITE)

	if err == OK:
		f.store_var(serialize_persistent_variables())
		print("Saving image cache images.fescache")
	
	f.close()
	return err

func load_cache():
	var err = 0
	var filepath = Vars.data_path+"/images.fescache"

	err = f.open(filepath,File.READ)
	var data = []
	
	#si no hay archivo db o se fuerza escanear de nuevo
	if err == ERR_FILE_NOT_FOUND:
		err = save_cache()
	elif err == OK:
		data = f.get_var()
		images = data["images"]

	f.close()
	return err


func serialize_persistent_variables():
	var save_dict = {}
	save_dict = {
		"images": images,
	}
	return save_dict

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
