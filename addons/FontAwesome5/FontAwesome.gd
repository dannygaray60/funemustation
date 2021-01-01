tool
extends Label

export(int, 0, 1000, 1) var icon_size := 16 setget set_icon_size
export(String, "solid", "regular", "brands") var icon_type := "solid" setget set_icon_type
export(String) var icon_name := "" setget set_icon_name

const icon_font: Dictionary = {
	"solid": preload("fa-solid-900.ttf"),
	"regular": preload("fa-regular-400.ttf"),
	"brands": preload("fa-brands-400.ttf")
}

const cheatsheet: Dictionary = preload("Cheatsheet.gd").cheatsheet_lut

var font: DynamicFont = DynamicFont.new()

func _init():
	match icon_type:
		"solid", "regular", "brands":
			font.set_font_data(icon_font[icon_type])
			set("custom_fonts/font", font)

func set_icon_size(size: int):
	icon_size = size
	font.set_size(icon_size)

func set_icon_type(type: String):
	icon_type = type
	match icon_type:
		"solid", "regular", "brands":
			font.set_font_data(icon_font[icon_type])
			set_icon_name(icon_name)

func set_icon_name(name: String):
	icon_name = name
	var iconcode = ""
	if icon_name in cheatsheet[icon_type]:
		iconcode = cheatsheet[icon_type][icon_name]
		set_text(iconcode)
