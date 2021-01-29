extends Control

var input_mode = "keyboard"

func _ready():

	input_mode = Config.get_conf_value("misc", "input_mode")
	
	$ControlOtherSettings/MarginContainer2/VBoxContainer/Gamepadmapping/VBoxContainer/TextEdit.text = Config.get_conf_value("misc","gamepad_mapping")

	$ControlOtherSettings/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/ChkLstMode.pressed = Config.get_conf_value("roms", "list_mode")
#	$ControlOtherSettings/MarginContainer2/VBoxContainer/HBoxContainer/VBoxContainer2/ChkDinamicLoad.pressed = Config.get_conf_value("roms", "dinamic_load")

#	_on_ChangeInputMode(input_mode)
	
	match input_mode:
		"keyboard":
			$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/HBoxContainer/CheckBox.pressed = true
		"gamepad":
			$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/HBoxContainer/CheckBox2.pressed = true

	$HbxNickname/LineEdit.text = Config.get_conf_value("misc", "nickname")

	check_if_set_btn_icons()

func check_if_set_btn_icons():
	
	if input_mode == "keyboard":
		$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/ActionRemapRow7.visible = false
		$MarginContainer/Block.visible = true
		$ControlOtherSettings/MarginContainer2/VBoxContainer/Gamepadmapping.visible = false
	else:
		$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/ActionRemapRow7.visible = true
		$MarginContainer/Block.visible = false
		$ControlOtherSettings/MarginContainer2/VBoxContainer/Gamepadmapping.visible = true
	
	for b in get_tree().get_nodes_in_group("button_remap"):
		b.key_or_gamepad = input_mode

func _on_ChangeInputMode(opt):
	Audio.get_node("ChangeItem").play()
	#eliminar los inputmaps anteriormente establecidos
	for m in Config.conf.get_section_keys("key"):
		InputMap.action_erase_events(m)
	for m in Config.conf.get_section_keys("joypad"):
		InputMap.action_erase_events(m)
		
	InputMap.load_from_globals()
		
	Config.check_configfile()
	
	for b in get_tree().get_nodes_in_group("button_remap"):
		b.pressed = false
		b.emit_signal("button_up")
		b.key_or_gamepad = opt
		b.text = "No key"
	Config.set_conf_value("misc","input_mode",opt)
	input_mode = Config.get_conf_value("misc", "input_mode")
	check_if_set_btn_icons()

func _on_BtnGoMenu_pressed():
	Audio.get_node("GoBack").play()
	Config.set_conf_value("misc", "nickname",$HbxNickname/LineEdit.text)
	SceneChanger.change_scene("res://MainScr.tscn")


func _on_ChangeLang(lang):
	Audio.get_node("Accept").play()
	Config.set_conf_value("misc","lang",lang)
	TranslationServer.set_locale(lang)


func _on_OpenURL(url):
	Audio.get_node("Accept").play()
	if url == "data_dir":
		# warning-ignore:return_value_discarded
#		OS.shell_open( OS.get_user_data_dir() )
		OS.shell_open( Global.data_path )
	else:
		# warning-ignore:return_value_discarded
		OS.shell_open(url)


func _on_ApplyMapping():
	Audio.get_node("Accept").play()
	var mapping_text = $ControlOtherSettings/MarginContainer2/VBoxContainer/Gamepadmapping/VBoxContainer/TextEdit.text	
	Config.set_conf_value("misc","gamepad_mapping",mapping_text)
	if mapping_text != "":
		Input.add_joy_mapping(mapping_text, true)


func _on_ResetMapping():
	Audio.get_node("GoBack").play()
	$ControlOtherSettings/MarginContainer2/VBoxContainer/Gamepadmapping/VBoxContainer/TextEdit.text = ""
	_on_ApplyMapping()

#cuando el valor del check cambia
func _on_Chk_toggled(button_pressed, opt):
	Config.set_conf_value("roms",opt,button_pressed)

#al presionar un check
func _on_Chk_pressed():
	Audio.get_node("ChangeItem").play()
