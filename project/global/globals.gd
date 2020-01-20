extends Node

# warning-ignore:unused_class_variable
var invert_camera:bool = false
# warning-ignore:unused_class_variable
var enable_shadows:bool = false
var level_idx:int = -1

const level_playlist:Array = [preload("res://environment/scenes/levels/campaign/Level_0.tscn"), preload("res://environment/scenes/levels/campaign/Level_1.tscn")]

# warning-ignore:unused_class_variable
onready var player_hitpoints:int = 5
onready var music_player:AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	# intialize music player
	music_player.bus = "Music"
	music_player.pause_mode = PAUSE_MODE_PROCESS
	# add to tree
	add_child(music_player)

func next_level():
	# increase IDX for next level
	level_idx += 1
	if level_idx >= 0:
		# check bounds, go to mainmenu at last level
		if level_idx >= len(level_playlist):
			level_idx = -1
# warning-ignore:return_value_discarded
			get_tree().change_scene("res://scenes/ui/Mainmenu.tscn")
		else:
			# go to next level
# warning-ignore:return_value_discarded
			get_tree().change_scene_to(level_playlist[level_idx])


