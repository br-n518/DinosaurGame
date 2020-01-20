extends "res://characters/scripts/BattleCharacter.gd"

export(float) var death_persist_time = 5.0

const IDLE_STATE = 1
const ATTACK_STATE = 2
const DEATH_STATE = 3

onready var state = IDLE_STATE setget set_state

onready var target_player = null
onready var target:Vector3 #= _new_position_target()

onready var ap:AudioStreamPlayer = AudioStreamPlayer.new()

func _new_position_target():
	return self.translation + Vector3.BACK.rotated(Vector3.UP, randf()*PI*2)

func _ready(): 
	#self.state = IDLE_STATE
	ap.volume_db = -12
	add_child(ap)
# warning-ignore:return_value_discarded
	connect("damage_taken", self, "hurt_sound")


# warning-ignore:unused_argument
func hurt_sound( amount ):
	ap.stream = preload("res://characters/assets/sfx/robot_hit.wav")
	ap.play()

#func get_attack_rotation():
#	return rotation.y

# warning-ignore:unused_argument
func _process(delta):
	check_state()
	if state == ATTACK_STATE and target_player != null:
		if target_player.hitpoints <= 0:
			target_player = null
			state = IDLE_STATE
		elif target_player in hitbox_targets:
			attack()

func _physics_process(delta):
	process_knockback( delta )
	var coll:KinematicCollision = process_gravity( delta )
	
	if not attacking:
		# get direction
		var target_direction:Vector3 = (target - self.translation)
		target_direction.y = 0
		target_direction = target_direction.normalized()
		
		# rotate
		rotation.y = atan2(target_direction.x, target_direction.z)
		
		# move
		coll = move_and_collide(target_direction * delta)
		if coll and target_player == null:
			target = target_direction.bounce(coll.normal) * target.distance_to(translation)


func check_state():
	match state:
		IDLE_STATE:
			# check for target
			for p in get_tree().get_nodes_in_group(ENEMY_GROUP):
				if p.hitpoints > 0 and p.translation.distance_squared_to(self.translation) <= 16:
					target_player = p
					self.state = ATTACK_STATE
					ap.stream = preload("res://characters/assets/sfx/robot_notice.wav")
					ap.play()
					return
			target_player = null
			
			if  translation.distance_squared_to(target) <= 0.15:
				target = _new_position_target()
			
		ATTACK_STATE:
			if target.distance_squared_to(self.translation) > 20.25:  # 4.5 * 4.5 = 20.25
				self.state = IDLE_STATE
			else:
				target = target_player.translation
				

func set_state(s):
	state = s
	match state:
		IDLE_STATE:
			#anim_player.play("walk-loop")
			target = _new_position_target()
			target_player = null
		ATTACK_STATE:
			target = target_player.translation
		DEATH_STATE:
			set_process(false)
			set_physics_process(false)
			set_collision_layer_bit(0, false)
			set_collision_mask_bit(0, false)
			anim_player.play("death")
			var death_timer:Timer = Timer.new()
			death_timer.autostart = true
			death_timer.wait_time = death_persist_time
			death_timer.one_shot = true
# warning-ignore:return_value_discarded
			death_timer.connect("timeout", self, "queue_free")
			add_child(death_timer)



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "attack":
		if anim_player.has_animation("walk-loop"):
			anim_player.play("walk-loop")
		else:
			anim_player.play("idle")


func queue_death():
	if state != DEATH_STATE:
		# play death sound
		ap.stream = preload("res://characters/assets/sfx/destroy.wav")
		ap.play()
		# change state
		set_state( DEATH_STATE )


#func att():
#	attack()

# AnimationPlayer can't see superclass methods, so proxy here (attack call is ok because it's from GDScript, not AnimationPlayer)
func _do_att():
	_do_attack()



