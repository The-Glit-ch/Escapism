extends Node

var mouse_pos_2d : Vector2 setget set_mouse_pos

onready var UIWall : MeshInstance = $UIWall
onready var touch_area : Area = $UIWall/TestUI
onready var ui : Control = $Viewport/Control

func _ready():
	UIWall.transform.origin = Vector3(UIWall.transform.origin.x, Global.height, UIWall.transform.origin.z)


func set_mouse_pos(new_value):
	#mouse_pos_2d.x = 1280 * new_value.x
	#mouse_pos_2d.y = 720 * new_value.y
	#print(mouse_pos_2d)
	print(new_value)
	#ui.get_node("Mouse").update_pos(mouse_pos_2d)
	
