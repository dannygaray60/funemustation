extends Button

func _ready():
	var btn_color = Config.get_conf_value("video","theme","blue")
	if Vars.colors.has(btn_color):
		self_modulate = Color(Vars.colors[btn_color])
