extends KinematicBody

# Player Logic
# Handles VR mouse and VR movement using HMD and controller

var speed : float = 7
var acceleration : int = 14
var gravity : float = 0.98
var terminal_vel : float = 54
var jump_power : float = 10
var velocity : Vector3
var y_vel : float

onready var _mouse : RayCast = $Origin/Camera/RayCast
onready var _cam : Camera = $Origin/Camera


func _physics_process(dt):
	_movement_handler(dt)
	_ui_mouse_handler()

func _movement_handler(dt):
	# Handle movement using controller
	var direction : Vector3
	var trans : Transform = Transform(transform)
	trans.basis = _cam.transform.basis

	if Input.is_action_pressed("move_foward"):
		direction -= trans.basis.z
	if Input.is_action_pressed("move_backwards"):
		direction += trans.basis.z
	if Input.is_action_pressed("move_left"):
		direction -= trans.basis.x
	if Input.is_action_pressed("move_right"):
		direction += trans.basis.x
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * dt)
	
	if is_on_floor():
		velocity.y = -0.01
	else:
		y_vel = clamp(y_vel - gravity, -terminal_vel, terminal_vel)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_vel = jump_power
	
	velocity.y = y_vel
	
	move_and_slide(velocity,Vector3.UP)

func _ui_mouse_handler():
	# Handle mouse movment using HMD and controller
	# I spent 3 days trying to get this to work. The fix? Change Vector2(x,y) to Vector2(x,z)
	if _mouse.is_colliding():
		# Convert to a relative area
		var obj = _mouse.get_collider()
		var panel_size = obj.get_node("../").mesh.size
		var viewport = obj.get_node("../../").get_node("Viewport")
		var mouse_pos3d = obj.global_transform.affine_inverse() * _mouse.get_collision_point()

		# 3D to 2D
		var mouse_pos2d = Vector2(mouse_pos3d.x, mouse_pos3d.z)

		# Convert
		mouse_pos2d.x += panel_size.x / 2
		mouse_pos2d.y += panel_size.y / 2

		mouse_pos2d.x = mouse_pos2d.x / panel_size.x
		mouse_pos2d.y = mouse_pos2d.y / panel_size.y

		mouse_pos2d.x = mouse_pos2d.x * viewport.size.x
		mouse_pos2d.y = mouse_pos2d.y * viewport.size.y

		obj.get_node("../../").update_cursor(mouse_pos2d)
		
		# Send fake mouse motion to UI
		var event = InputEventMouseMotion.new()
		event.position = mouse_pos2d
		viewport.input(event)
		
		# Trigger left click
		if Input.is_action_just_pressed("ui_left_click"):
			var left_click = InputEventMouseButton.new()
			
			left_click.pressed = true
			left_click.button_index = 1
			left_click.position = mouse_pos2d
			
			viewport.input(left_click)
			
			left_click.pressed = false
			viewport.input(left_click)
