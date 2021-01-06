extends Control

func _ready() -> void:
	$VBoxContainer/HBoxMusic/SliderMusic.value = Config.get_conf_value("sound", "music")
	$VBoxContainer/HBoxEffects/SliderEffects.value = Config.get_conf_value("sound", "effects")

func _on_SliderMusic_value_changed(value: float) -> void:
	for music_node in get_tree().get_nodes_in_group("music"):
		music_node.volume_db = linear2db(value)
	Audio.get_node("ChangeItem").play()
	Config.set_conf_value("sound", "music", value)

func _on_SliderEffects_value_changed(value: float) -> void:
	for effect_node in get_tree().get_nodes_in_group("effects"):
		effect_node.volume_db = linear2db(value)
	Audio.get_node("ChangeItem").play()
	Config.set_conf_value("sound", "effects", value)
