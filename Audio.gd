extends Node

func _ready():
	for audio_player in get_children():
		if audio_player.is_in_group("music"):
			audio_player.volume_db = linear2db(Config.get_conf_value("sound", "music"))
		elif audio_player.is_in_group("effects"):
			audio_player.volume_db = linear2db(Config.get_conf_value("sound", "effects"))
	$Music.play()
