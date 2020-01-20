extends Spatial

export(NodePath) var PLAYER_PATH = ""

onready var player = get_node(PLAYER_PATH)




func _on_Area_body_entered(body):
	if body == player:
		_globals.next_level()
