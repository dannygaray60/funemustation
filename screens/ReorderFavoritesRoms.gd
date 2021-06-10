extends Control

var ROMDB = load("res://scripts/ROMDB.gd").new()
var Functions = load("res://scripts/Functions.gd").new()

var reorder_btn = preload("res://ui_elements/FavRomReorderButton.tscn")
var reorder_btn_instance = null

func _ready():
	#debug, ocultar en release
	#ROMDB.load_rom_db()

	for r in Vars.favorite_roms:
		reorder_btn_instance = reorder_btn.instance()
		reorder_btn_instance.name_rom = r[0].get_file()
		reorder_btn_instance.name = r[0].get_file()
		reorder_btn_instance.rom = r
		$Scroll/Vbx.add_child(reorder_btn_instance)
		reorder_btn_instance.connect("change_order",self,"_on_change_order")


func save_changes():
	Array(Vars.favorite_roms).clear()
	for r in $Scroll/Vbx.get_children():
		Vars.favorite_roms.append(r.rom)
	ROMDB.save_rom_db()
	ROMDB.load_rom_db()


func _on_change_order(idx,dir):

	var destination_idx_node = 0
	
	if dir == "up":
		destination_idx_node = Functions.get_new_position_on_array($Scroll/Vbx.get_children(),idx,"prev")
	else:
		destination_idx_node = Functions.get_new_position_on_array($Scroll/Vbx.get_children(),idx,"next")
	
	$Scroll/Vbx.move_child( $Scroll/Vbx.get_children()[idx], destination_idx_node )
	


func _on_TitleWindow_btn_back_pressed():
	save_changes()
	SceneChanger.change_scene("res://screens/OptionsMain.tscn")
