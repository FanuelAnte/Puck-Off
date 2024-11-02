extends RigidBody2D

@onready var center_marker: Marker2D = %CenterMarker

@export var is_player: bool = false

var engine_power: int = 300
var velocity: Vector2 = Vector2.ZERO
var turn_direction: int = 0
var turn_speed: int = 1000

var right_direction: Vector2

var lateral_sliding_reduction: float = 0.8

func _ready() -> void:
	center_of_mass = center_marker.position
	
func _physics_process(delta: float) -> void:
	get_input()
	apply_central_force(velocity)
	var normalized_speed: float = snapped(remap(linear_velocity.length(), 0, engine_power, 0, 1), 0.01)
	
	if linear_velocity.length() > 30:
		apply_torque(turn_direction * turn_speed * normalized_speed)
	else:
		angular_velocity = 0
	
	right_direction = transform.y.rotated(PI/2)
	var lateral_velocity: Vector2 = right_direction * linear_velocity.dot(right_direction)
	linear_velocity -= lateral_velocity * lateral_sliding_reduction

func get_input() -> void:
	if is_player:
		if Input.is_action_pressed("accelerate"):
			velocity = transform.y * engine_power * -1
		elif Input.is_action_pressed("decelerate"):
			velocity = transform.y * engine_power * 0.8
		else:
			velocity = Vector2.ZERO
		
		if Input.is_action_pressed("right"):
			turn_direction = 1
		elif Input.is_action_pressed("left"):
			turn_direction = -1
		else:
			turn_direction = 0
			
		if Input.is_action_pressed("engage drift"):
			lateral_sliding_reduction = 0
		else:
			if lateral_sliding_reduction < 0.8:
				lateral_sliding_reduction += 0.01
