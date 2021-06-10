extends Control

var input_mode = "keyboard"

func _ready():
	input_mode = Config.get_conf_value("input","input_mode","keyboard")
	match input_mode:
		"keyboard":
			$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/HBoxContainer/CheckBox.pressed = true
		"gamepad":
			$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/HBoxContainer/CheckBox2.pressed = true
	check_if_set_btn_icons()
	$VBxCustomMapping/TextEdit.text = Config.get_conf_value("input","gamepad_mapping","")

func _on_ChangeInputMode(opt):
	Audio.get_node("ChangeItem").play()
	#eliminar los inputmaps anteriormente establecidos
	for m in Config.conf.get_section_keys("keyboard"):
		InputMap.action_erase_events(m)
	for m in Config.conf.get_section_keys("gamepad"):
		InputMap.action_erase_events(m)
		
	InputMap.load_from_globals()
		
	Config.check_config_file()
	
	for b in get_tree().get_nodes_in_group("button_remap"):
		b.pressed = false
		b.emit_signal("button_up")
		b.key_or_gamepad = opt
		b.text = "No key"
	Config.set_conf_value("input","input_mode",opt)
	input_mode = opt#Config.get_conf_value("input","input_mode","keyboard")
	check_if_set_btn_icons()

func check_if_set_btn_icons():
	if input_mode == "keyboard":
		$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/ActionRemapRow7.visible = false
	else:
		$RemapButtonGroupKeyBoard/MarginContainer/ActionsList/ActionRemapRow7.visible = true
	
	for b in get_tree().get_nodes_in_group("button_remap"):
		b.key_or_gamepad = input_mode

func _on_TitleWindow_btn_back_pressed():
	SceneChanger.change_scene("res://screens/OptionsMain.tscn")


func _on_ApplyMapping():
	Audio.get_node("Accept").play()
	var mapping_text = $VBxCustomMapping/TextEdit.text	
	Config.set_conf_value("input","gamepad_mapping",mapping_text)
	if mapping_text != "":
		Input.add_joy_mapping(mapping_text, true)

func _on_ResetMapping():
	Audio.get_node("GoBack").play()
	$VBxCustomMapping/TextEdit.text = ""
	_on_ApplyMapping()
