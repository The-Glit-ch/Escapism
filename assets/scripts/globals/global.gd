extends Node
# Generic global script
# Contains helper functions and variables

# Variables
var _mvr : MobileVRInterface = MobileVRInterface.new()

# Accessible
var height : float = _mvr.get_eye_height()

# Functions

# Handles the spawing of a VR keyboard instance
func show_vr_keyboard(label : Label):
	# Delete the previous keyboard
	if get_tree().get_nodes_in_group("vr_keyboard").size() > 0:
		var _prev = get_tree().get_nodes_in_group("vr_keyboard")
		for keyboard in _prev:
			keyboard.queue_free()
			
	# Instance the keyboard and make a variable for it
	var _keyboard = preload('res://assets/ui/floating_ui/popup_keyboard/keyboard.tscn').instance()
	
	# Set keyboard data
	# Get a refrence to the UI
	var _ui = _keyboard.get_node("Viewport/Control")
	
	# Set text object
	_ui.textObj = label
	
	# Set position TODO: Re do this entire thing
	var _spawn_pos : Position3D = get_node("/root/World/Player").get_node("Origin/Camera/KeyboardSpawn")
	
	var _spawn_transform : Transform = _spawn_pos.global_transform
	var _spawn_origin : Vector3 = _spawn_transform.origin
	var _spawn_basis : Basis = _spawn_transform.basis
	
	_keyboard.global_transform.basis = _spawn_basis
	_keyboard.global_transform.origin = Vector3(_spawn_origin.x, height / 2, _spawn_origin.z)
	_keyboard.rotate_y(-120 * (PI/180))
	
	# Add child to world
	add_child(_keyboard)
	
	# Group it
	_keyboard.add_to_group("vr_keyboard")

# Returns editable text activation buttons
func return_editable_text_buttons(root : Control) -> Array:
	return root.get_tree().get_nodes_in_group("editable")
