extends MarginContainer

const DIM_COLOR:Color = Color8(128, 128, 128, 192)
const NORMAL_COLOR:Color = Color8(255, 255, 255, 255)

onready var pop = ConfirmationDialog.new()

func _ready():
	pop.dialog_text = "Quit to main menu. Are you sure?"
	pop.popup_exclusive = true
	pop.rect_scale = Vector2(2, 2)
	pop.connect("confirmed", self, "_on_confirm_quit")
	add_child(pop)
	
	$HBox/SettingsButton.modulate = DIM_COLOR
	$HBox/SaveButton.hide()
	$HBox/QuitButton.hide()




func _on_SettingsButton_toggled(button_pressed):
	if button_pressed:
		$HBox/SettingsButton.modulate = NORMAL_COLOR
		$HBox/SaveButton.show()
		$HBox/QuitButton.show()
		get_tree().paused = true
	else:
		$HBox/SettingsButton.modulate = DIM_COLOR
		$HBox/SaveButton.hide()
		$HBox/QuitButton.hide()
		get_tree().paused = false


# TODO
func _on_SaveButton_pressed():
	pass # Replace with function body.


func _on_QuitButton_pressed():
	pop.popup(Rect2(256, 256, 64, 1))

func _on_confirm_quit():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://ui/scenes/Mainmenu.tscn")
	
