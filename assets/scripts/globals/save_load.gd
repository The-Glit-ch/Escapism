class_name ESLS
extends Node

var _save_game_dir : String = "user://save_games/"


func _ready():
	var dir : Directory = Directory.new()
	
	# Check if we have valid data directories
	if dir.open(_save_game_dir) == OK:
		pass
	else:
		dir.make_dir(_save_game_dir)
	
	new_save("dick.dat")


func new_save(save_name : String):
	# Save game function
	# Takes in a save name
	var save_file : File = File.new()
	var dir : Directory = Directory.new()
	
	# Open the save file
	save_file.open(_save_game_dir + save_name, File.WRITE)
	
	# Persistent save objects are underneath the
	var save_objects : Array = get_tree().get_nodes_in_group("Persistent")
	
	for node in save_objects:
		# Check if the node has a save function
		if !node.has_method("save"):
			continue
		
		var node_data : Dictionary = node.save()
		
		save_file.store_line(to_json(node_data))

func load_save(save_name : String):
	var save_file : File = File.new()
	
	if !save_file.file_exists(_save_game_dir + save_name):
		return
	
	
