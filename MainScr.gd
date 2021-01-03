extends Control

var systems_ok = false

var f = File.new()
var dir = Directory.new()

func _ready():
	
	$PanelContainer/MarginContainer/HBoxContainer/Label.text = Config.get_conf_value("misc", "nickname")
	
	#---------cambiar mensaje a uno de bienvenida si se ocultan botones desde configuracion
	if !Config.get_conf_value("misc", "show_btns_developer"):
		$PanelContainer/MarginContainer/HBoxContainer/Label.text = tr("WELCOME_USER")%Config.get_conf_value("misc", "nickname")
		$PanelContainer/MarginContainer/HBoxContainer/HBoxContainer.visible = false
	
	dir.copy("res://config_systems_example.txt","user://config_systems_example.txt")
	#comprobacion de configuracion de sistemas
	if Global.systems_id.empty():
		$PanelContainer/MarginContainer/Hbx/HBoxContainer/element_icon_help_panel.visible = false
		$PanelContainer/MarginContainer/Hbx/HBoxContainer/Label.text = tr("SYS_NOT_CONF")
	else:
		systems_ok = true
		
	if !Config.get_conf_value("misc", "borderless"):
		OS.window_maximized = true

func _process(_delta):
	
	if $element_btn_min_close_win.get_node("ControlConfirmQuit").visible:
		return
	
	if Input.is_action_just_pressed("ui_accept") and systems_ok:
		Audio.get_node("Intro").play()
		$AnimationPlayer.play("hide")
		set_process(false)

	if Input.is_action_just_pressed("ui_cancel"):
#		Audio.get_node("GoBack").play()
		$element_btn_min_close_win.get_node("HBoxContainer/BtnClose").emit_signal("pressed")


func _on_BtnGoConf_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://remapconfig/InputRemapMenu.tscn")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "hide":
		SceneChanger.change_scene("res://ScrGamesList.tscn")

func _unhandled_input(_event):
	var current_focus_ctrl = get_focus_owner()
	if current_focus_ctrl and current_focus_ctrl.is_in_group("dev_btn"):
		current_focus_ctrl.release_focus()

func _on_OpenURL(url):
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open(url)


func _on_BtnGoAbout_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://ScrAbout.tscn")
