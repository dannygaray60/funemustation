extends Button

var title_btn = ""

func _ready():
	title_btn = text
	$VBx/Label.text = ""

func _on_Button_focus_entered():
	$VBx/Label.text = title_btn

func _on_Button_focus_exited():
	$VBx/Label.text = ""


func _on_Button_pressed():
	$Tween.interpolate_property($VBx/FontAwesome,"rect_rotation",$VBx/FontAwesome.rect_rotation,20,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()

func _on_Tween_tween_all_completed():
	if $VBx/FontAwesome.rect_rotation == 20:
		$Tween.interpolate_property($VBx/FontAwesome,"rect_rotation",$VBx/FontAwesome.rect_rotation,-20,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()
	elif $VBx/FontAwesome.rect_rotation == -20:
		$Tween.interpolate_property($VBx/FontAwesome,"rect_rotation",$VBx/FontAwesome.rect_rotation,0,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
		$Tween.start()
