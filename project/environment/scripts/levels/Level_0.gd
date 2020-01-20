extends "res://environment/scripts/levels/Level_Base.gd"


func _ready():
	_globals.music_player.stream = preload("res://global/assets/bgm/handdrums.ogg")
	_globals.music_player.play()
	seed(0)

