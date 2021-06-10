extends Node

var paid = true

var show_favorites = false

#id de proceso lanzado desde launcher -1 es default indicando que nada se lanzó
var pid = -1

#-------- variables que usa ROMDB.gd ----------------
#ids alfabeticos de los sistemas
var systems_id = []
#toda informacion referente a los sistemas configurados
var sys_data = {}#null
#cada item (su index es del sistema) es otro array:nombre,textura cover, textura wallpaper,ruta del archivo
var rom_data = {}

#funciona igual que rom_data solo que sin diccionario
var favorite_roms = [] #cada item es otro array con dos items: el idx de sistema, el idx de archivo

var months = {
	1:
		["January","Enero"],
	2:
		["February","Febrero"],
	3:
		["March","Marzo"],
	4:
		["April","Abril"],
	5:
		["May","Mayo"],
	6:
		["June","Junio"],
	7:
		["July","Julio"],
	8:
		["August","Agosto"],
	9:
		["September","Septiembre"],
	10:
		["October","Octubre"],
	11:
		["November","Noviembre"],
	12:
		["December","Diciembre"],
}

var colors = {
	"blue": "0081ff",
	"red": "be0202",
	"yellow": "d8c600",
	"blue-dark": "007dd0",
	"cyan": "00c0bc",
	"purple": "9617d0",
	"pink": "e846d3",
	"gray": "8f8f8f",
}

var data_path = OS.get_executable_path().get_base_dir()+"/fes_data"

#ruta o textura del fondo de una rom
var rom_img_background = ""
