extends ColorRect

signal change_order(idx_node,dir)

var name_rom = "Rom's Name"
var rom = []

func _ready():
	self_modulate.a = 0
	$Hbx/HBx/Label.text = name_rom


func _on_Btn_Change_Order(dir):
	Audio.get_node("ChangeItem").play()
	emit_signal("change_order",get_index(),dir)


func _on_Btn_focus_entered():
	self_modulate.a = 0.52


func _on_Btn_focus_exited():
	self_modulate.a = 0
