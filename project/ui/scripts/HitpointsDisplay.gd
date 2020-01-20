extends MarginContainer

export(NodePath) var PLAYER_PATH = null
onready var player = get_node(PLAYER_PATH)  # BattleCharacter Player

onready var heart_sprite = preload("res://ui/scenes/Heart.tscn")  # TextureRect

func add_hearts( n:int ):
# warning-ignore:unused_variable
	for i in range(n):
		$HitpointsGrid.add_child(heart_sprite.instance())

func remove_hearts( n:int ):
# warning-ignore:unused_variable
	for i in range(n):
		$HitpointsGrid.get_child(0).queue_free()



func _ready():
	add_hearts( _globals.player_hitpoints )
	player.connect("health_gained", self, "add_hearts")
	player.connect("damage_taken", self, "remove_hearts")

