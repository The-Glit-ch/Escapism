extends Control

signal delete

var textObj : Label
var isUpper : bool = false

func _ready():
	# Base container
	var container : VBoxContainer = $KeyboardContainer
	
	# Get the individual keyboard rows
	var row_one : HBoxContainer = container.get_child(1)
	var row_two : HBoxContainer = container.get_child(3)
	var row_three : HBoxContainer = container.get_child(5)
	var row_four : HBoxContainer = container.get_child(7)
	
	# Loop through each row and connect the buttons to the function handler
	_loop_through(row_one)
	_loop_through(row_two)
	_loop_through(row_three)
	_loop_through(row_four)

func deletion_connection(obj, callback : String):
	connect("delete", obj, callback)

func _loop_through(row : HBoxContainer):
	for btn in row.get_children():
		if btn.get_class() == "Button":
			btn.connect("pressed", self, "_keyboard_handler", [btn])

func _keyboard_handler(btn : Button):
	match btn.name:
		"Backspace-Btn":
			var _temp = textObj.text
			_temp.erase(_temp.length() - 1, 1)
			textObj.text = _temp
		"Enter-Btn":
			emit_signal("delete")
		"Upper-Btn":
			isUpper = !isUpper
		"Upper-Btn2":
			isUpper = !isUpper
		"Symbols-Btn":
			pass
		"Spacebar-Btn":
			textObj.text = textObj.text + " "
		"Symbols-Btn2":
			pass
		_:
			textObj.text = textObj.text + btn.text if isUpper == false else textObj.text + btn.text.to_upper()
