extends TextureRect

export(NodePath) var PLAYER_PATH = ""

onready var player = get_node(PLAYER_PATH)

func _gui_input( event ):
	if event is InputEventScreenTouch:
		player.attack()
