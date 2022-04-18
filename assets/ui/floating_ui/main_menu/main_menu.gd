extends Node

var _ui : FloatingUI

onready var panel : MeshInstance = $Panel

func _ready():
	var properties : Dictionary = {
		"obj": $Panel,
		"mouse": $Viewport/Control/Mouse,
	}
	_ui = FloatingUI.new(properties)
	_connect_btns()

func update_cursor(pos : Vector2):
	_ui.update_cursor(pos)

func _connect_btns():
	$Viewport/Control/VBoxContainer/Settings_B.connect("pressed", self, "_btn_clicked", [$Viewport/Control/VBoxContainer/Settings_B])
	for btn in Global.return_editable_text_buttons($Viewport/Control):
		btn.connect('pressed', self, '_btn_clicked', [btn])

func _btn_clicked(btn : Button):
	Global.show_vr_keyboard(btn.get_node("Label"))
