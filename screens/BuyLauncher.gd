extends Control

func _ready():
	$HBoxContainer/BtnBuy.grab_focus()

func _on_BtnBuy_pressed():
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open("https://dannygaray60.itch.io/funemustation-launcher")


func _on_BtnGoMainMenu_pressed():
	Audio.get_node("Accept").play()
	SceneChanger.change_scene("res://screens/MainMenu.tscn")
