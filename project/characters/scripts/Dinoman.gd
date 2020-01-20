extends "res://characters/scripts/BattleCharacter.gd"

onready var direction_matrix = Basis()
onready var move_direction:Vector2 = Vector2()

onready var cam_position = $Camera_Yaw/Camera.translation


func _ready():
	# set hitpoints, avoid setget set_hp
	hitpoints = _globals.player_hitpoints
	$Camera_Yaw.cast_to = cam_position
# warning-ignore:return_value_discarded
	connect("damage_taken", self, "player_hurt")
# warning-ignore:return_value_discarded
	connect("health_gained", self, "player_heal")

# warning-ignore:unused_argument
func player_hurt( amount ):
	_globals.player_hitpoints = hitpoints
	$HurtAudio.play()

# warning-ignore:unused_argument
func player_heal( amount ):
	_globals.player_hitpoints = hitpoints

# proxy... AnimationPlayer can't see extended class for call-track
func _do_att():
	_do_attack()




# warning-ignore:unused_argument
func _process(delta):
	if $Camera_Yaw.is_colliding():
		$Camera_Yaw/Camera.global_transform.origin = $Camera_Yaw.get_collision_point()
	else:
		$Camera_Yaw/Camera.translation = cam_position





func _physics_process(delta):
	process_knockback( delta )
	
	if not attacking:
		# check if moving
		if move_direction != Vector2.ZERO:
			# if on ground and animation isn't of walking
			if can_jump and anim_player.current_animation != "walk-loop":
				anim_player.play("walk-loop")
			# get Vector for camera-adjusted movement directions
			var d:Vector3 = direction_matrix.xform(Vector3(move_direction.x, 0, move_direction.y))
			# apply rotation to mesh object
			$Dinoman.rotation.y = direction_matrix.get_euler().y + atan2(move_direction.x, move_direction.y)
			# move and slide (no delta)
# warning-ignore:return_value_discarded
			move_and_slide( d * 2 )
		# if not moving and animation is walking
		elif anim_player.current_animation == "walk-loop":
			anim_player.play("Idle-loop")
		# jump
		if do_jump:
			player_jump()
	
	var coll:KinematicCollision = process_gravity( delta )
	# check for collision on ground
	if coll:
		if can_jump:
			if anim_player.current_animation == "jump":
				anim_player.play("Idle-loop")
			if coll.collider is preload("res://characters/scripts/BattleCharacter.gd"):
				if attack_target( coll.collider, false ):
					player_jump( 6.0, false )
	# fall to death
	if translation.y <= -10:
		queue_death()






func player_jump( velocity:float = 10.0, play_audio:bool = true ):
	anim_player.play("jump")
	if play_audio:
		$JumpAudio.play()
	do_jump = false
	vert_vel = velocity

func queue_death():
	set_process(false)
	set_physics_process(false)
	invincible_timer.stop()
	$Dinoman.queue_free()
	$CanvasLayer/GlassPane/Thumbpad.hide()
	$CanvasLayer/GlassPane/AttackButton.hide()
	$CanvasLayer/GlassPane/JumpButton.hide()
	$CanvasLayer/GlassPane/SettingsUI.queue_free()
	$CanvasLayer/HitpointsDisplay.hide()
	$CanvasLayer.add_child( preload("res://ui/scenes/GameOverDialog.tscn").instance() )
	



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack" or anim_name == "knockdown":
		anim_player.play("Idle-loop")


