extends Node

onready var UIWall : MeshInstance = $UIWall
onready var ta : Area = $UIWall/Area

func _ready():
	UIWall.transform.origin = Vector3(UIWall.transform.origin.x, Global.height, UIWall.transform.origin.z)
	ta.connect("mouse_entered",self,"_mouse")

func _mouse():
	print("no fucking way")
