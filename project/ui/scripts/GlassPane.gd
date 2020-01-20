extends Control

export(NodePath) var PLAYER_PATH = ""
export(NodePath) var CAMERA_YAW = ""

onready var player = get_node(PLAYER_PATH)
onready var cam_yaw = get_node(CAMERA_YAW)

func _gui_input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		# check thumbpad area
		if $Thumbpad.get_rect().has_point(event.position):
			$Thumbpad._gui_input( $Thumbpad.make_input_local(event) )
			
		elif event is InputEventScreenDrag:
			# drag distance to rotation angle
			var angle:float = (event.relative.x / 128.0)
			# check camera inversion
			if not _globals.invert_camera:
				angle *= -1
			# rotate player matrix
			player.direction_matrix = player.direction_matrix.rotated(Vector3.UP, angle)
			# get camera rotation
			cam_yaw.rotation = player.direction_matrix.get_euler()
