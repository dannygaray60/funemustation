extends Control

var ROMDB = load("res://scripts/ROMDB.gd").new()

var go_to = ""

func _input(_event):
	
	if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().quit()
		$TitleWindow.show_confirm_quit()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_TitleWindow_exit_confirm_dialog_hide():
	$ScrollContainer.can_move_menu = true


func _on_TitleWindow_exit_confirm_dialog_show():
	$ScrollContainer.can_move_menu = false


func _on_Button_pressed(opt):
	Audio.get_node("Intro").play()
	$ScrollContainer.can_move_menu = false
	$PanelHelp.visible = false
	match opt:
		"show_all_games":
			Vars.show_favorites = false
			go_to = "res://screens/AllGamesList.tscn"
		"random":
			var systems_size = Array(Vars.systems_id).size()
			
			if systems_size == 0:
				$Notification.notif("Systems not configured")
				$ScrollContainer.can_move_menu = true
				return
				
			var random_system_idx = randi() % systems_size - 1
			
			var rom_data_size = Array(Vars.rom_data)[random_system_idx].size()
			
			if rom_data_size == 0:
				$Notification.notif("Empty List")
				$ScrollContainer.can_move_menu = true
				return
			
			var random_rom_idx = randi() % rom_data_size - 1
			
			Config.set_conf_value("roms","selected_system",random_system_idx)
			
			ROMDB.set_conf_value(Vars.systems_id[random_system_idx],"selected_file",random_rom_idx)
			
			Vars.show_favorites = false
			go_to = "res://screens/AllGamesList.tscn"

		"favorites":
			Vars.show_favorites = true
			go_to = "res://screens/AllGamesList.tscn"
		"settings":
			SceneChanger.change_scene("res://screens/OptionsMain.tscn")
		"credits":
			go_to = "res://screens/About.tscn"
		"interest_links":
			go_to = "res://screens/InterestLinks.tscn"
		"exit":
			get_tree().quit()
		_:
			pass
	
	
	$ScrollContainer.can_move_menu = false
	
	var new_pos = $TitleWindow/WindowBar.rect_position
	new_pos.y -= 100
	$Tween.interpolate_property($TitleWindow/WindowBar, "rect_position", $TitleWindow/WindowBar.rect_position, new_pos, 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	$Logo/Label.text = ""
	$Tween.interpolate_property($Logo/TextureRect, "rect_scale", Vector2(1,1), Vector2(1.5,1.5), 0.8, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
	$Tween.interpolate_property($Logo/TextureRect, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()

	$Tween.interpolate_property($ScrollContainer, "modulate", Color(1,1,1,1), Color(1,1,1,0), 0.7, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()


func _on_Tween_tween_all_completed():
	if go_to != "":
		SceneChanger.change_scene(go_to)
