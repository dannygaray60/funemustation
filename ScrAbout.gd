extends Control

func _on_BtnBack_pressed():
	Audio.get_node("GoBack").play()
	SceneChanger.change_scene("res://MainScr.tscn")


func _on_GoURL(url):
	Audio.get_node("Accept").play()
	# warning-ignore:return_value_discarded
	OS.shell_open(url)
