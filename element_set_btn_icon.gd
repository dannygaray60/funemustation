extends HBoxContainer

export var action = "ui_accept" #ui_accept,ui_cancel

var current_pos = 0

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
	current_pos = Config.get_conf_value("icons_btn",action)
	match action:
		"ui_accept":
			$Label.text = tr("ACCEPT")
		"ui_accept2":
			$Label.text = tr("ACCEPT2")
		"ui_cancel":
			$Label.text = tr("CANCEL")
			
	if current_pos == null:
		current_pos = 0
	
	$TextureRect.texture = load(icons[current_pos])



func _on_BtnChangeIcon(opt):
	Audio.get_node("ChangeItem").play()
	current_pos = Functions.get_new_position_on_array(icons,current_pos,opt)
	$TextureRect.texture = load(icons[current_pos])
	Config.set_conf_value("icons_btn",action,current_pos)
