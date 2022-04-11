extends Spatial

var _ui : FloatingUI

func _ready():
	var properties : Dictionary = {
		"obj": $Panel,
		"mouse": $Viewport/Control/Mouse,
	}
	_ui = FloatingUI.new(properties)
	
	$Viewport/Control.deletion_connection(self, "_delete_signal")
	
func update_cursor(pos : Vector2):
	_ui.update_cursor(pos)

func _delete_signal():
	self.queue_free()
