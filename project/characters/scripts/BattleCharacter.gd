extends KinematicBody

export(NodePath) var MESH_PATH = null #surface material modulation
export(NodePath) var HITBOX = null #Area hitbox
export(NodePath) var ANIM_PLAYER = null
export(NodePath) var ROTATION_OBJECT = "."
export(int) var hitpoints:int = 4 setget set_hp
export(float) var invincible_time = 0.25
export(int) var attack_damage:int = 1
export(float) var attack_timeout:float = 1.0 setget set_attack_timeout
export(String) var FRIENDLY_GROUP = null
export(String) var ENEMY_GROUP = null

const MIN_ATT_TIMEOUT:float = 0.15
const MAX_ATT_TIMEOUT:float = 3.35
const DIM_ALBEDO_COLOR = Color8(212, 128, 128)
const TERM_VELOCITY:float = -8.0
const GRAVITY:float = 0.55

signal damage_taken (amount)
signal health_gained (amount)
signal dead ()

onready var vert_vel:float = -0.05

onready var invincible_timer:Timer = Timer.new()
onready var invincible:bool = false setget set_invincible

onready var attack_timer:Timer = Timer.new()
onready var attacking:bool = false
onready var knockback_vec:Vector3 = Vector3.ZERO
onready var knockback_force:float = 20.0

onready var can_jump:bool = false
onready var do_jump:bool = false

onready var hitbox = get_node(HITBOX)
onready var hitbox_targets:Array = []

onready var anim_player:AnimationPlayer = get_node(ANIM_PLAYER)

onready var char_mesh:MeshInstance = get_node(MESH_PATH)
onready var start_albedo_color:Color = char_mesh.mesh.surface_get_material(0).albedo_color

func _ready():
	add_to_group(FRIENDLY_GROUP)
	char_mesh.set_surface_material(0, char_mesh.mesh.surface_get_material(0).duplicate())
# warning-ignore:return_value_discarded
	attack_timer.wait_time = attack_timeout
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	add_child(attack_timer)
	
	invincible_timer.wait_time = invincible_time
	invincible_timer.one_shot = true
# warning-ignore:return_value_discarded
	invincible_timer.connect("timeout", self, "_on_invincible_timer_timeout")
	add_child(invincible_timer)
	
	if hitbox:
		hitbox.connect("body_entered", self, "_on_Hitbox_body_entered")
		hitbox.connect("body_exited", self, "_on_Hitbox_body_exited")
	


func queue_death():
	queue_free()





func set_hp(val:int):
	# check if dead
	if val <= 0:
		remove_from_group(FRIENDLY_GROUP)
		val = hitpoints
		hitpoints = 0
		emit_signal("damage_taken", val)
		emit_signal("dead")
		queue_death()
	else:
		var old_hp:int = hitpoints
		hitpoints = val
		# check gain/loss of HP (val > zero)
		if val < old_hp:
			emit_signal("damage_taken", old_hp - val)
		elif val > old_hp:
			emit_signal("health_gained", val - old_hp)




# direction should be pre-normalized for correct Y-axis movement
# this applies knockback to the current object
func knockback( rotation:float, force:float ):
	var direction:Vector3 = Vector3.BACK.rotated( Vector3.UP, rotation )
	direction.y = 0.25
	knockback_vec += direction.normalized() * force


func process_knockback( delta:float ):
	if knockback_vec != Vector3.ZERO:
		if knockback_vec.length_squared() <= 2:
			knockback_vec = Vector3.ZERO
		else:
			var knock_step:Vector3 = knockback_vec * delta
			knockback_vec -= knockback_vec * 0.3333
# warning-ignore:return_value_discarded
			move_and_collide( knock_step )



func process_gravity( delta:float ) -> KinematicCollision:
	# apply gravity
	vert_vel -= GRAVITY
	if vert_vel < TERM_VELOCITY:
		vert_vel = TERM_VELOCITY
	
	# move vertically
	var coll:KinematicCollision = move_and_collide( Vector3.UP * vert_vel * delta )
	# collide with ground
	if coll and coll.normal.y > 0.6:
		can_jump = true
		vert_vel = -0.05 #reset velocity
	else:
		can_jump = false
	# bump head (separate coll check for better ground detection)
	if coll and coll.normal.y < -0.2:
		vert_vel = 0.0
	return coll



func _on_Hitbox_body_entered(body):
	if body.is_in_group(ENEMY_GROUP):
		hitbox_targets.append(body)


func _on_Hitbox_body_exited(body):
	hitbox_targets.erase(body)



func set_attack_timeout(n:float):
	if n < MIN_ATT_TIMEOUT:
		attack_timeout = MIN_ATT_TIMEOUT
	elif n > MAX_ATT_TIMEOUT:
		attack_timeout = MAX_ATT_TIMEOUT
	else:
		attack_timeout = n

func _on_attack_timer_timeout():
	attacking = false

func set_invincible( b:bool ):
	invincible = b
	if invincible:
		char_mesh.get_surface_material(0).albedo_color = DIM_ALBEDO_COLOR
	else:
		char_mesh.get_surface_material(0).albedo_color = start_albedo_color

func _on_invincible_timer_timeout():
	self.invincible = false



func jump():
	if can_jump:
		can_jump = false
		do_jump = true


# subclasses must include animation "attack" with a call track for "_do_attack"
func attack():
	if not attacking:
		attacking = true
		attack_timer.start()
		anim_player.play("attack")

func attack_target( t, use_knockback:bool = true ) -> bool:
	if (not t == self) and t.has_method("set_hp") and (not t.invincible):
		t.invincible = true
		t.invincible_timer.start()
		t.hitpoints -= attack_damage
		if use_knockback:
			t.knockback( get_attack_rotation(), knockback_force )
		return true
	return false

func _do_attack():
	if attacking:
		for t in hitbox_targets:
			attack_target( t, true )


func get_attack_rotation() -> float:
	return get_node(ROTATION_OBJECT).rotation.y
