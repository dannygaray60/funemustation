extends Button

# warning-ignore:unused_signal
signal focused(index,data)
signal selected(index,data)

var idx = 0

#todos los datos pertenecientes a la rom asignada a este boton
var rom_data = []


#al ganar focus emitir señal dando el index del rom y el sistema
func _on_Button_rom_list_focus_entered():
	emit_signal("focused",idx,rom_data)


func _on_Button_rom_list_pressed():
	emit_signal("selected",idx,rom_data)
