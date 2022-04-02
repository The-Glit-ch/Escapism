extends Node

onready var ui_mos : TextureRect = $Viewport/Control/Mouse
onready var UIWall : MeshInstance = $Panel

func _ready():
	UIWall.transform.origin = Vector3(UIWall.transform.origin.x, Global.height, UIWall.transform.origin.z)

func update_pos(new_value):
	var vect2 : Vector2 = Vector2(new_value.x, new_value.y) + Vector2(0.5,0.5)
	var refined : Vector2 = vect2 * Vector2(1280,720)
	refined.y = -refined.y
	ui_mos.update_pos(refined)
