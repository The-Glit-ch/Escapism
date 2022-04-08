extends ARVROrigin

var vr = ARVRServer.find_interface("Native mobile")

func _ready():
	if vr and vr.initialize():
		get_viewport().arvr = true
