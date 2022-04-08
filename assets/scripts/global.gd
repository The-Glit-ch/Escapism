extends Node
# Generic global script

# Variables
var _mvr : MobileVRInterface = MobileVRInterface.new()

# Accessible
var height : float = _mvr.get_eye_height()
