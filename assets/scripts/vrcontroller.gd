extends ARVROrigin

var vr_int = ARVRServer.find_interface("Native mobile")

func _ready():
	if vr_int and vr_int.initialize():
		get_viewport().arvr = true
		
