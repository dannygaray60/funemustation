extends Control

var ROMDB = load("res://scripts/ROMDB.gd").new()

var button = preload("res://ui_elements/Button.tscn")
var button_instance = null

var i = 0

func _input(_event):
	
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.get_node("GoBack").play()
		SceneChanger.change_scene("res://screens/MainMenu.tscn")

func _enter_tree():
	if Vars.systems_id.size() <= 1:
		SceneChanger.change_scene("res://screens/MainMenu.tscn")

func _ready():
	
	#debug, ocultar en release
	#ROMDB.load_rom_db()
	
	if !Vars.systems_id.empty():
		
		i = 0
		for sys_key in Vars.systems_id:
			button_instance = button.instance()
			button_instance.text = Vars.sys_data[sys_key]["name"]
			$Scroll/Center/VBx.add_child(button_instance)
			button_instance.connect("pressed",self,"_ob_btnsys_pressed",[i])
			button_instance.connect("focus_exited",self,"_ob_btnsys_focus_exited")
			i += 1

		$Scroll/Center/VBx.get_children()[ Config.get_conf_value("roms","selected_system",0) ].grab_focus()

func _ob_btnsys_focus_exited():
	Audio.get_node("ChangeItem").play()

func _ob_btnsys_pressed(sys_idx):
	Audio.get_node("Accept").play()
	Config.set_conf_value("roms","selected_system",sys_idx)
	SceneChanger.change_scene("res://screens/AllGamesList.tscn")
