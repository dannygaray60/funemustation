extends Control

var Functions = load("res://scripts/Functions.gd").new()

#ruta o textura
var cover = ""

var bg = ""

func _ready():
	set_visible_elements(false)
	
	
func set_visible_elements(val=true):
	$Margin.visible = val
	$CoverBG.visible = val
	$Cover.visible = val
	$Darkness.visible = val

func set_title(txt=""):
	$Margin/Lbl.text = txt

func _on_RomItemCover_focus_entered():
	$Tween.stop_all()
	$Tween.interpolate_property(
		$Darkness, 
		"color",
		$Darkness.color, 
		Color(0, 0, 0, 0), 
		0.6, 
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()
	pass

func _on_RomItemCover_focus_exited():
	$Tween.stop_all()
	$Tween.interpolate_property(
		$Darkness, 
		"color",
		$Darkness.color, 
		Color(0, 0, 0, 0.5), 
		0.3, 
		Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
	$Tween.start()
	pass


func _on_VisibilityNotifier2D_screen_entered():
	if $Cover.texture == null:
		$Cover.texture = Functions.get_texture_from_path(cover)
		$CoverBG.texture = $Cover.texture
		bg = Functions.get_texture_from_path(bg)
	
	if $Cover.texture != null:
		$Margin/Lbl.visible = false

	set_visible_elements(true)

func _on_VisibilityNotifier2D_screen_exited():
	set_visible_elements(false)
	
