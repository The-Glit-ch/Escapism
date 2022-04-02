extends KinematicBody

#Player
var speed : float = 20
var acceleration : int = 15
var gravity : float = 0.98
var terminal_vel : float = 54
var jump_power : float = 20
var velocity : Vector3
var y_vel : float

#Mouse
onready var mouse : RayCast = $Origin/Camera/RayCast

func _ready():
	pass
	
func _physics_process(dt):
	_movement_handler(dt)
	_mouse_handler()

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
	
# warning-ignore:return_value_discarded
	move_and_slide(velocity,Vector3.UP)

func _mouse_handler():
	#Handle mouse movment using HMD and controller
	if mouse.is_colliding():
		var t = transform.affine_inverse() * mouse.get_collision_point()
		mouse.get_collider().get_node("../../").update_pos(t)
	
		
