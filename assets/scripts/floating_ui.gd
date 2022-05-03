class_name FloatingUI

# Main 3D UI class
# All other 3D UI's will be built and handled under this class
# DOES NOT HANDLE UI LOGIC ONLY APPEARANCE

# Options
var match_height : bool = true setget enable_height_match, get_height_matched
var mouse_enabled : bool = true setget enable_mouse, get_mouse_enabled

# Required
var obj : MeshInstance
var mouse : TextureRect

func _init(properties : Dictionary):
	# Required
	obj = properties.obj if properties.has("obj") else null
	mouse = properties.mouse if properties.has("mouse") else null
	
	# Optional
	match_height = properties.match_height if properties.has("match_height") else true
	mouse_enabled = properties.mouse_enabled if properties.has("mouse_enabled") else true

	# Set UI to eye height if we have a valid object and match height is true
	if obj != null and match_height == true:
		obj.global_transform.origin = Vector3(obj.global_transform.origin.x, Global.height * 1.5, obj.global_transform.origin.z)

func _update():
	# Enable mouse option
	mouse.visible = mouse_enabled

	# Match height option
	if match_height == true:
		obj.transform.origin = Vector3(obj.transform.origin.x, Global.height, obj.transform.origin.z)
	else:
		obj.transform.origin.y -= Global.height

# Mouse Functionality
func update_cursor(pos : Vector2):
	# Stops game from crashing
	if is_instance_valid(mouse):
		mouse.set_global_position(pos)

# Set
func enable_height_match(value : bool):
	match_height = value
	_update()

func enable_mouse(value : bool):
	mouse_enabled = value
	_update()

# Get
func get_mouse_enabled():
	return mouse_enabled

func get_height_matched():
	return match_height
