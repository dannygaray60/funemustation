extends Control

var ROMDB = load("res://scripts/ROMDB.gd").new()
var Functions = load("res://scripts/Functions.gd").new()


var available_colors = Vars.colors.keys()
var selected_color = Config.get_conf_value("video","theme","blue")
var selected_color_index = available_colors.find(selected_color,0)

func _ready():
	
	#si no se encuentra el nombre de color en colores disponibles se establece el predeterminado
	if selected_color_index < 0:
		selected_color_index = 0
	_on_BtnChangeTheme_pressed("none")
	
	$Margin/Grid/PanelNickname/VBx/LineEdit.text = Config.get_conf_value("misc","nickname","dannygaray60")
	
	_onChangeLang()
	
	$Margin/Grid/PanelVideo/VBx/ChkBtnFullscreen.pressed = Config.get_conf_value("video","borderless_fullscreen",true)

	$Margin/Grid/PanelAudio/VBx/VBxHSliderSFX/HSlider.value = Config.get_conf_value("sound","effects",0.5)
	$Margin/Grid/PanelAudio/VBx/VBxHSliderBGM/HSlider.value = Config.get_conf_value("sound","music",0.5)

	$Margin/Grid/PanelBGAlpha/VBx/SliderBGAlpha/HSlider.value = Config.get_conf_value("video", "bg_darkness", 0.5)

#	if $Background/WallpaperBG.texture == null:
#		$Margin/Grid/PanelBGAlpha.visible = false

func _on_TitleWindow_btn_back_pressed():
	Config.set_conf_value("misc", "nickname",$Margin/Grid/PanelNickname/VBx/LineEdit.text)
	if Vars.paid:
		SceneChanger.change_scene("res://screens/MainMenu.tscn")
	else:
		SceneChanger.change_scene("res://screens/BuyLauncher.tscn")

func _on_BtnChangeTheme_pressed(arg_0):
	selected_color_index = Functions.get_new_position_on_array(available_colors,selected_color_index,arg_0)
	selected_color = available_colors[selected_color_index]
	if arg_0 != "none":
		Config.set_conf_value("video","theme",selected_color)
		$Background._ready()
		$TitleWindow._ready()
		Audio.get_node("ChangeItem").play()
	$Margin/Grid/PanelVideo/VBx/HBxTheme/LblName.text = "Theme-%s"%[selected_color]

func _onChangeLang(lang=Config.get_conf_value("misc","lang","en"),saveconf=false):
	match lang:
		"en":
			$Margin/Grid/PanelLang/VBx/ChkBtnEng.pressed = true
		"es":
			$Margin/Grid/PanelLang/VBx/ChkBtnEsp.pressed = true
	if saveconf:
		Audio.get_node("BtnPressed").play()
		Config.set_conf_value("misc","lang",lang)
		TranslationServer.set_locale(lang)

func _on_ChkBtnFullscreen_toggled(button_pressed):
	Audio.get_node("BtnPressed").play()
	Config.set_conf_value("video","borderless_fullscreen",button_pressed)
#	$Margin/Grid/PanelVideo/VBx/LblRestartToApply.visible = true
	OS.set_borderless_window(button_pressed)
	if OS.window_borderless:
		OS.set_window_size(OS.get_screen_size())
		OS.set_window_position(Vector2(0, 0))
	$TitleWindow._ready()


func _on_SoundSlider_value_changed(opt):
	match opt:
		"sfx":
			Audio.get_node("BtnPressed").play()
			Config.set_conf_value("sound", "effects",$Margin/Grid/PanelAudio/VBx/VBxHSliderSFX.slider_value)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("effects"),linear2db($Margin/Grid/PanelAudio/VBx/VBxHSliderSFX.slider_value))
		"bgm":
			Config.set_conf_value("sound", "music", $Margin/Grid/PanelAudio/VBx/VBxHSliderBGM.slider_value)
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("music"),linear2db($Margin/Grid/PanelAudio/VBx/VBxHSliderBGM.slider_value))


func _on_BtnGmpdIcons_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/OptionsGamepadIcons.tscn")


func _on_BtnBindings_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/OptionsKeyBinding.tscn")


func _on_BtnUpdateDB_pressed():
	Audio.get_node("Accept").play()
	$Margin/Grid/PanelGameDB/VBx/LblWaitMsg.visible = true
	$Margin/Grid/PanelGameDB/VBx/BtnUpdateDB.visible = false
	$Timer.start()
	yield($Timer,"timeout")
	var err = ROMDB.load_rom_db(true)
	if err == OK:
		$Margin/Grid/PanelGameDB/VBx/LblWaitMsg.text = tr("DONE")
		$Margin/Grid/PanelGameDB/VBx/BtnUpdateDB.visible = true
	else:
		$Margin/Grid/PanelGameDB/VBx/LblWaitMsg.text = "Error with db: %s" % [err]


func _on_SliderBGAlpha_value_changed():
	Config.set_conf_value("video", "bg_darkness", $Margin/Grid/PanelBGAlpha/VBx/SliderBGAlpha.slider_value)
	$Background._ready()


func _on_BtnAddSys_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/AddSystem.tscn")

func _on_BtnEditSys_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/EditSystems.tscn")


func _on_BtnOpenIni_pressed():
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open(Vars.data_path+"/systems.ini")

func _on_BtnOpenData_pressed():
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open( Vars.data_path )


func _on_BtnFavChangeOrder_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/ReorderFavoritesRoms.tscn")
