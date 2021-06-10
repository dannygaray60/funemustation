extends VBoxContainer

signal value_changed

export var title = ""
var slider_value = 0

func _ready():
	if title != "":
		$Label.text = title

func _on_HSlider_value_changed(value):
	slider_value = value
	emit_signal("value_changed")
