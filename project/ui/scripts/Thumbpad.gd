extends TextureRect

export(NodePath) var PLAYER_PATH = ""

# 64 pixels to right
onready var X_LIMIT = rect_size.x + 64
# 64 pixels above
onready var Y_LIMIT = -64

onready var player = get_node(PLAYER_PATH)



func _gui_input( event ):
	if event is InputEventScreenDrag:
		# check drag is within a margin
		if event.position.x <= X_LIMIT and event.position.y >= Y_LIMIT:
			player.move_direction = ((rect_size / 2) - event.position).normalized()
		# out of bounds, send info to parent
		else:
			# no need to adjust position with how GlassPane only looks at relative X movement
			# This thumbpad uses absolute position so correct position is important (See: GlassPane.gd)
			# also, GlassPane doesn't care about ScreenTouch, but thumbpad needs it for proper response.
			# parent object must be GlassPane
			# get_parent().make_input_local(event) -> InputEvent
			get_parent()._gui_input( event )
	
	elif event is InputEventScreenTouch:
		if event.pressed:
			player.move_direction = ((rect_size / 2) - event.position).normalized()
		else:
			player.move_direction = Vector2.ZERO
	



