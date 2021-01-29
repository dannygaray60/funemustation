extends HBoxContainer

func _ready():
	visible = false
	modulate.a = 0
#	notif("Notificacion de prueba")

func notif(txt="",secs=5):
	$Panel.rect_size = Vector2(0,0)
	$Panel/HBoxContainer/Label.text = ""
	hide()
	$Panel/HBoxContainer/Label.text = txt
	show()
	modulate.a = 0
	visible = true
	$Timer.start(secs)
	
	$Tween.interpolate_property(self,"modulate",Color(1,1,1,0),Color(1,1,1,1),1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$Tween.start()
	yield($Timer,"timeout")
	$Tween.interpolate_property(self,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.5,Tween.TRANS_LINEAR,Tween.EASE_IN)
	$Tween.start()


func _on_Button_pressed():
	if $Tween.is_active():
		$Tween.stop_all()
	visible = false
