tool
extends EditorPlugin

const ICON: Texture = preload("flag-solid.svg")

func _enter_tree() -> void:
	add_custom_type("FontAwesome", "Label",preload("FontAwesome.gd"), ICON)

func _exit_tree() -> void:
	remove_custom_type("FontAwesome")
