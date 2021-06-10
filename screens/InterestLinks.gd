extends Control

func _ready():
	$VBoxContainer/Button.grab_focus()

func _process(_delta):
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		Audio.get_node("ChangeItem").play()

func _on_TitleWindow_btn_back_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")


func _on_OpenUrl(url):
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open(url)


func _on_BtnBack_pressed():
	Audio.get_node("GoBack").play()
	SceneChanger.change_scene("res://screens/MainMenu.tscn")
