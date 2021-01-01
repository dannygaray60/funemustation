extends CenterContainer

export var action = "ui_accept"

var icons = [
	"res://assets/btn.png",
	"res://assets/btn_a.png",
	"res://assets/btn_a_v2.png",
	"res://assets/btn_b.png",
	"res://assets/btn_b_v2.png",
	"res://assets/btn_x.png",
	"res://assets/btn_x_v2.png",
	"res://assets/btn_y.png",
	"res://assets/btn_y_v2.png",
]

func _ready():
	var input_mode = Config.get_conf_value("misc", "input_mode")
	var current_pos = Config.get_conf_value("icons_btn",action)
	
	var key_name = InputMap.get_action_list(action)
	
	if !key_name.empty():
		key_name = key_name[0].as_text()
	else:
		key_name = ""
	
	if input_mode == "keyboard":
		$Label.text = "[%s]" % key_name
		$Icon.visible = false
	else:
		$Label.text = ""
		$Icon.visible = true
		if current_pos == null:
			current_pos = 0
		$Icon.texture = load(icons[current_pos])

