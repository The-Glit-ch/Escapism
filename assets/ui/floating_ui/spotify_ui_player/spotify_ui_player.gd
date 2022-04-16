extends Spatial

var _ui : FloatingUI

onready var panel : MeshInstance = $Panel

func _ready():
	var properties : Dictionary = {
		"obj": $Panel,
		"mouse": $Viewport/Control/Mouse,
	}
	_ui = FloatingUI.new(properties)

func update_cursor(pos : Vector2):
	_ui.update_cursor(pos)
