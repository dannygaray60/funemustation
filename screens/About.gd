extends Control

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		Audio.get_node("GoBack").play()
		_on_TitleWindow_btn_back_pressed()

func _ready():
	$HBoxContainer/Button.grab_focus()


func _on_GoURL(url):
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open(url)


func _on_Button_focus_exited():
	Audio.get_node("ChangeItem").play()


func _on_TitleWindow_btn_back_pressed():
	SceneChanger.change_scene("res://screens/MainMenu.tscn")
