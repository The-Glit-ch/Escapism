extends Node
# Generic global script
# Contains helper functions and variables

# Variables
var _mvr : MobileVRInterface = MobileVRInterface.new()

# Accessible
var height : float = _mvr.get_eye_height()

# Functions

# Handles the spawing of a VR keyboard instance
func show_vr_keyboard(label : Label, requester_position : Vector3):
	# Delete the previous keyboard
	if get_tree().get_nodes_in_group("vr_keyboard").size() > 0:
		var _prev = get_tree().get_nodes_in_group("vr_keyboard")[0]
		_prev.queue_free()
	
	# Instance the keyboard and make a variable for it
	var _keyboard = preload('res://assets/ui/floating_ui/popup_keyboard/keyboard.tscn').instance()
	
	# Set keyboard data
	# Get a refrence to the UI
	var _ui = _keyboard.get_node("Viewport/Control")
	
	# Set text object
	_ui.textObj = label
	
	# Set position
	_keyboard.transform.origin = Vector3(requester_position.x + 1.5, height / 2, requester_position.z + 1.5)
	_keyboard.rotation.y = -90
	
	# Add child to world
	add_child(_keyboard)
	
	# Group it
	_keyboard.add_to_group("vr_keyboard")

# Returns editable text activation buttons
func return_editable_text_buttons(root : Control) -> Array:
	return root.get_tree().get_nodes_in_group("editable")
