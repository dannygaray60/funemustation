extends Control

var Functions = load("res://scripts/Functions.gd").new()

var conf = ConfigFile.new()

onready var sys_id = $PanelForm/VBx/HBx/VBxID/LineEdit
onready var sys_name = $PanelForm/VBx/HBx/VBxName/LineEdit
onready var emu_path = $PanelForm/VBx/VBxEmuPath/Hbx/LineEdit
onready var roms_path = $PanelForm/VBx/VBxRomsPath/Hbx/LineEdit
onready var roms_ext = $PanelForm/VBx/Hbx3/VBxRomsExtensions/LineEdit
onready var custom_theme = $PanelForm/VBx/Hbx3/VBxCustomTheme/LineEdit
onready var emu_command = $PanelForm/VBx/VBxEmuCommand/LineEdit

export var edit_mode = "add" #add or edit

var systems_keys = []

var selected_system = 0

func _ready():

	if TranslationServer.get_locale() == "es":
		$ControlHelp/Panel/MarginContainer/ScrollContainer/VBoxContainer/LblEs.visible = true
	else:
		$ControlHelp/Panel/MarginContainer/ScrollContainer/VBoxContainer/LblEn.visible = true
	
	var result_open_ini = open_systems_ini()
	
	if result_open_ini != OK:
		$Notification.notif("Error loading systems.ini %d"%[result_open_ini])
	
	match edit_mode:
	
		"edit":
			
			$TitleWindow.set_title("Edit Systems")
			
			#mostrar botones necesario para editar sistemas
			$PanelForm/VBx/HBx2/BtnReset.visible = false
			$PanelForm/VBx/HBx2/BtnDeleteSys.visible = true
			
			$Panel/VBoxContainer/HSeparator.visible = true
			$Panel/VBoxContainer/BtnPrevSys.visible = true
			$Panel/VBoxContainer/BtnNextSys.visible = true
			
			
			#obtener la lista de secciones (sistemas)
			systems_keys = conf.get_sections()
			
			#si la lista está vacía cambiar modo a add
			if systems_keys.empty():
				edit_mode = "add"
				_ready()
				return
			
			load_system_data()
			
		"add":
			$TitleWindow.set_title("Add new System")
			
			#mostrar botones necesario para añadir sistemas
			$PanelForm/VBx/HBx2/BtnReset.visible = true
			$PanelForm/VBx/HBx2/BtnDeleteSys.visible = false
			
			$Panel/VBoxContainer/HSeparator.visible = false
			$Panel/VBoxContainer/BtnPrevSys.visible = false
			$Panel/VBoxContainer/BtnNextSys.visible = false
			
			reset_form()

	$SelectFileOrDir/Margin/FileEmuDialog.current_path = OS.get_executable_path()

func reset_form():
	sys_id.text = ""
	sys_name.text = ""
	emu_path.text = ""
	roms_path.text = ""
	roms_ext.text = ""
	custom_theme.text = "default"
	emu_command.text = "%%ROMRAW%%"

func data_is_ok():
	if sys_id.text != "" and sys_name.text != "" and roms_path.text != "" and roms_ext.text != "" and emu_command.text != "":
		return true
	else:
		return false

func open_systems_ini():
	# carga de datos de sistemas configurados
	var err
	err = conf.load(Vars.data_path+"/systems.ini")
	if err == ERR_FILE_NOT_FOUND:
		print("Creating new systems.ini")
		#si no existe el archivo se crea uno
		err = conf.save(Vars.data_path+"/systems.ini")
		
	#si no hay problemas debe retornar OK
	return err
	
func save_system():

	if open_systems_ini() == OK:
		
		conf.set_value(sys_id.text, "name",sys_name.text)
		conf.set_value(sys_id.text, "path_emu",emu_path.text)
		conf.set_value(sys_id.text, "path_rom",roms_path.text)
		conf.set_value(sys_id.text, "command",emu_command.text)
		conf.set_value(sys_id.text, "formats",roms_ext.text)
		conf.set_value(sys_id.text, "custom_theme",custom_theme.text)
		conf.set_value(sys_id.text, "selected_file",0)
		
		if edit_mode == "add":
			print("Adding %s configuration to systems.ini"%[sys_id.text])
		else:
			print("Editing %s configuration on systems.ini"%[sys_id.text])
		
		return conf.save(Vars.data_path+"/systems.ini")

func load_system_data():
	selected_system = Functions.get_new_position_on_array(systems_keys,selected_system)
	var current_key = systems_keys[selected_system]
	sys_id.text = current_key
	sys_name.text = conf.get_value(current_key,"name","Unknown")
	emu_path.text = conf.get_value(current_key,"path_emu","")
	roms_path.text = conf.get_value(current_key,"path_rom","")
	emu_command.text = conf.get_value(current_key,"command","%%ROMRAW%%")
	roms_ext.text = conf.get_value(current_key,"formats","")
	custom_theme.text = conf.get_value(current_key,"custom_theme","default")


#-------- señales ------------



func _on_TitleWindow_btn_back_pressed():
	SceneChanger.change_scene("res://screens/OptionsMain.tscn")


func _on_FileEmuDialog_dir_selected(path):
	roms_path.text = path


func _on_FileEmuDialog_file_selected(path):
	emu_path.text = path


func _on_FileEmuDialog_popup_hide():
	$SelectFileOrDir.visible = false





func _on_BtnSelectEmuExe_pressed():
	$SelectFileOrDir.visible = true
	$SelectFileOrDir/Margin/FileEmuDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	$SelectFileOrDir/Margin/FileEmuDialog.popup()


func _on_BtnOpenRomsPath_pressed():
	$SelectFileOrDir.visible = true
	$SelectFileOrDir/Margin/FileEmuDialog.set_mode(FileDialog.MODE_OPEN_DIR)
	$SelectFileOrDir/Margin/FileEmuDialog.popup()

func _on_BtnReset_pressed():
	Audio.get_node("Accept").play()
	reset_form()

func _on_BtnSave_pressed():
	var result = 0
	if data_is_ok():
		result = save_system()
		if result == OK:
			Audio.get_node("Accept").play()
			if edit_mode == "add":
				$Notification.notif("System Added!")
				$LblWarning.visible = true
				reset_form()
			else:
				$Notification.notif("System Edited!")
				$LblWarning.visible = true
		else:
			$Notification.notif("Error adding system: %d"%[result])
			Audio.get_node("Alert").play()
	else:
		$Notification.notif("Incomplete Data")
		Audio.get_node("Alert").play()

func _on_changesys(opt="none"):
	Audio.get_node("ChangeItem").play()
	selected_system = Functions.get_new_position_on_array(systems_keys,selected_system,opt)
	load_system_data()

func _on_BtnDeleteSys_pressed():
	
	if edit_mode == "edit":
		conf.erase_section(systems_keys[selected_system])
		conf.save(Vars.data_path+"/systems.ini")
		$Notification.notif("System deleted!")
		Audio.get_node("GoBack").play()
		$LblWarning.visible = true
		_ready()


func _on_BtnOpenIni_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open(Vars.data_path+"/systems.ini")


func _on_BtnHelp_pressed():
	Audio.get_node("Accept").play()
	$ControlHelp.visible = true
	$ControlHelp/BtnCloseHelp.grab_focus()


func _on_BtnCloseHelp_pressed():
	Audio.get_node("GoBack").play()
	$ControlHelp.visible = false
	$PanelForm/VBx/HBx/VBxID/LineEdit.grab_focus()


func _on_TitleWindow_exit_confirm_dialog_show():
	$ControlHelp.visible = false
