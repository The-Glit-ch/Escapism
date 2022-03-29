extends KinematicBody


onready var mouse : RayCast = $Origin/Camera/RayCast
onready var debug : Label = $Label

var speed : float = 20
var acceleration : int = 15
var gravity : float = 0.98
var terminal_vel : float = 54
var jump_power : float = 20
var velocity : Vector3
var y_vel : float

func _ready():
	pass
	
func _physics_process(dt):
	_movement_handler(dt)
	
	#if mouse.is_colliding():
	debug.text = str(mouse.get_collider())

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
