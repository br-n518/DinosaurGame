extends Spatial



func _ready():
	var enemies = get_tree().get_nodes_in_group("enemy")
	for e in enemies:
		e.connect("dead", self, "enemy_died")
	enemy_died() #check for zero enemies spawned

func enemy_died():
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		# Animate door opening
		$Walls/WallDoor/AnimationPlayer.play("door_open")
		# Remove collision box for gate.
		$Walls/WallDoor/wall_door/wall_door_gate_skele/Skeleton/wall_door_gate/col.queue_free()
