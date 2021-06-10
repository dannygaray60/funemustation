extends Button

export var key_or_gamepad = "keyboard" #key, gamepad

export(String) var action = "ui_up"

func _ready():
	
	assert(InputMap.has_action(action))
#	set_process_unhandled_key_input(false)
	set_process_input(false)
	display_current_key()


func _toggled(button_pressed):
#	set_process_unhandled_key_input(button_pressed)
	set_process_input(button_pressed)
	if button_pressed:
		text = "... Key"
		release_focus()
	else:
		display_current_key()


#func _unhandled_key_input(event):
func _input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if key_or_gamepad == "keyboard" and event is InputEventKey:
		remap_action_to(event)
		pressed = false
	elif key_or_gamepad == "gamepad" and event is InputEventJoypadButton:
		remap_action_to(event)
		pressed = false

func remap_action_to(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	if event is InputEventKey:
		text = "%s Key" % event.as_text()
	elif event is InputEventJoypadButton:
		text = "%s Button" % str(event.button_index)
	Config.check_config_file()


func display_current_key():
	if !InputMap.get_action_list(action).empty():
		if InputMap.get_action_list(action)[0] is InputEventKey:
			text = "%s Key" % InputMap.get_action_list(action)[0].as_text()
		elif InputMap.get_action_list(action)[0] is InputEventJoypadButton:
			text = "%s Button" % str(InputMap.get_action_list(action)[0].button_index)
	else:
		text = "No key"
