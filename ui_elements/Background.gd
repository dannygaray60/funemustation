extends Control

var Functions = load("res://scripts/Functions.gd").new()

var f = File.new()

var default_color = Config.get_conf_value("video","theme","blue")

var selected_color = "blue"

var darkness_alpha = 0.5

func _ready():
	
	default_color = Config.get_conf_value("video","theme","blue")
	
	darkness_alpha = Config.get_conf_value("video","bg_darkness",0.5)
	
	$WallpaperBG/Darkness.modulate.a = darkness_alpha
	$ROMBG/Darkness.modulate.a = darkness_alpha
	
	if f.file_exists(Vars.data_path+"/wallpaper.jpg"):
		$WallpaperBG.texture = Functions.get_texture_from_path(Vars.data_path+"/wallpaper.jpg")
		$WallpaperBG.visible = true
	

	
	
	$ROMBG.modulate.a = 0
	update_launcher_theme()
	$BGGradientWLines/AnimationPlayer.play("lines")

#poner un fondo temporal (para cada rom)
func set_temporal_bg(img=null):
	
	$Tween.stop_all()
	if img is ImageTexture:
		$ROMBG.texture = img
		
		$Tween.interpolate_property($ROMBG,"modulate",$ROMBG.modulate,Color(1,1,1,1),0.3,Tween.TRANS_LINEAR)
		$Tween.start()
		
	else:
		$Tween.interpolate_property($ROMBG,"modulate",$ROMBG.modulate,Color(1,1,1,0),0.2,Tween.TRANS_LINEAR)
		$Tween.start()
		#yield
#		yield($Tween,"tween_all_completed")
#		$ROMBG.texture = null

#colocar tema de colores dependiendo de configuracion principal o uno especificado
func update_launcher_theme(set_color="default"):
	if set_color == "default":
		selected_color = default_color#Config.get_conf_value("video","theme","blue")
	else:
		selected_color = set_color

	if Vars.colors.has(selected_color):
		$BGGradientWLines.modulate = Color(Vars.colors[selected_color])
	else:
		$BGGradientWLines.modulate = Color(selected_color)
