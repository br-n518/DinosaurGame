extends Control



func _ready():
	get_tree().paused = false
	$CenterContainer/OptionsDialog/VBoxContainer/ShadowButton.pressed = _globals.enable_shadows
	$CenterContainer/OptionsDialog/VBoxContainer/InvertCameraButton.pressed = _globals.invert_camera
	_globals.level_idx = -1
	_globals.player_hitpoints = 10
	_globals.music_player.stream = preload("res://global/assets/bgm/title.ogg")
	_globals.music_player.play()
	$CenterContainer/VBoxContainer/PlayButton.grab_focus()




func _on_PlayButton_pressed():
	_globals.next_level()




func _on_OptionsButton_pressed():
	$CenterContainer/OptionsDialog.popup()
	
func _on_ShadowButton_toggled(button_pressed):
	_globals.enable_shadows = button_pressed

func _on_InvertCameraButton_toggled(button_pressed):
	_globals.invert_camera = button_pressed




func _on_LicenseButton_pressed():
	$CenterContainer/LicenseDialog.popup()




func _on_QuitButton_pressed():
	get_tree().quit()


func _on_LoadButton_pressed():
	pass # Replace with function body.
