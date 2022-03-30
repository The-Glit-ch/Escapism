extends KinematicBody

var speed : float = 20
var acceleration : int = 15
var gravity : float = 0.98
var terminal_vel : float = 54
var jump_power : float = 20
var velocity : Vector3
var y_vel : float

#Mouse
var inUIMode : bool = false
var prevloc : Vector2

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.warp_mouse_position(Vector2(1280/2,720/2))
	
func _physics_process(dt):
	_movement_handler(dt)
	_mouse_handler(dt)

func _movement_handler(dt):
	#Handle movement using controller
	var direction : Vector3 = Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),0,Input.get_action_strength("move_backwards") - Input.get_action_strength("move_foward"))
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * dt)
	
	if is_on_floor():
		velocity.y = -0.01
	else:
		y_vel = clamp(y_vel - gravity, -terminal_vel, terminal_vel)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		y_vel = jump_power
	
	velocity.y = y_vel
	
	move_and_slide(velocity,Vector3.UP)

func _mouse_handler(dt):
	#Handle mouse movment using joystick
	if inUIMode:
		var mouse_dir : Vector2 = Vector2(Input.get_action_strength("ui_mouse_right") - Input.get_action_strength("ui_mouse_left"),Input.get_action_strength("ui_mouse_down") - Input.get_action_strength("ui_mouse_up")) + prevloc
		var mouse_vel : Vector2
		mouse_vel = mouse_vel.linear_interpolate(mouse_dir * 30, dt * 30)
		
		if mouse_vel != Vector2.ZERO:
			Input.warp_mouse_position(mouse_vel)
			prevloc = mouse_dir
	
	if Input.is_action_just_pressed("ui_toggle"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			inUIMode = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			inUIMode = false
		
