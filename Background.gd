extends Control

#var f = File.new()

#func _enter_tree():
#	$TextureRect.visible = false

func _ready():

#hay un bajon de rendimiento si se establece un wallpaper
	if Global.main_wallpaper_texture != null:
		$lines.visible = false
		$lines2.visible = false
		$Darkness.visible = true
#		$Darkness.modulate.a = Config.get_conf_value("misc","wallpaper_darkness")	
		$TextureRect.texture = Global.main_wallpaper_texture
	else:
		$AnimationPlayer.play("idle")
	$TextureRect.visible = true
	$AnimationPlayer.play("idle")

