extends RigidBody2D

@onready var camera: Camera2D = %Camera
@onready var center_marker: Marker2D = %CenterMarker
@onready var stall_timer: Timer = %StallTimer
@onready var stall_progress_bar: TextureProgressBar = %StallProgressBar

@export var is_player: bool = false

signal zoom_camera(zoom_value: Vector2)

var has_zoomed_out: bool = false
var has_zoomed_in: bool = true

var engine_power: int = 600
var max_speed: int = 350
var velocity: Vector2 = Vector2.ZERO
var turn_direction: int = 0
var turn_speed: int = 1200

var is_steering: bool = true
var has_stalled: bool = false

var right_direction: Vector2
var lateral_sliding_reduction: float = 0.9

var puck_position: Vector2

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed

func _ready() -> void:
	center_of_mass = center_marker.position
	
func _physics_process(delta: float) -> void:
	get_input(delta)
	apply_central_force(velocity)
	
	var normalized_speed: float = snapped(remap(linear_velocity.length(), 0, max_speed, 0, 1), 0.01)
	
	if linear_velocity.length() > 15:
		apply_torque(turn_direction * turn_speed * normalized_speed)
	else:
		angular_velocity = 0
	
	right_direction = transform.y.rotated(PI/2)
	var lateral_velocity: Vector2 = right_direction * linear_velocity.dot(right_direction)
	linear_velocity -= lateral_velocity * lateral_sliding_reduction
	
	
func _process(delta: float) -> void:
	if has_stalled and !stall_timer.is_stopped():
		stall_progress_bar.show()
		stall_progress_bar.value = remap(snapped(stall_timer.time_left, 0.01), 0, stall_timer.wait_time, 0, 100) 
	else:
		stall_progress_bar.hide()
		
	puck_position = get_tree().get_nodes_in_group("puck")[0].global_position
	
	if is_player:
		if clamp(linear_velocity.length(), 0, max_speed) > (max_speed)/2:
			if !has_zoomed_out:
				emit_signal("zoom_camera", Vector2(0.5, 0.5))
				has_zoomed_out = true
				has_zoomed_in = false
		else:
			if !has_zoomed_in:
				emit_signal("zoom_camera", Vector2(1, 1))
				has_zoomed_in = true
				has_zoomed_out = false
	
func get_input(delta: float) -> void:
	if is_player:
		if !has_stalled:
			if Input.is_action_pressed("accelerate"):
				velocity = transform.y * engine_power * -1
			elif Input.is_action_pressed("decelerate"):
				velocity = transform.y * engine_power * 0.9
			else:
				velocity = Vector2.ZERO
			
			if Input.is_action_pressed("right"):
				turn_direction = 1
				is_steering = true
			elif Input.is_action_pressed("left"):
				turn_direction = -1
				is_steering = true
			else:
				turn_direction = 0
				is_steering = false
				
			if Input.is_action_pressed("engage drift"):
				lateral_sliding_reduction = 0
			else:
				if lateral_sliding_reduction < 0.9:
					lateral_sliding_reduction += 0.1 * delta
		else:
			velocity = Vector2.ZERO
			turn_direction = 0
			
func move_camera(amount: Vector2) -> void:
	camera.offset = Vector2(randf_range(-amount.x, amount.x), randf_range(-amount.y, amount.y))
			
func camera_shake(length: float, power: float) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_method(move_camera, Vector2(power, power), Vector2(0, 0), length)
	
func _on_zoom_camera(zoom_value: Vector2) -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(camera, "zoom", zoom_value, 2)
	
func _on_stall_timer_timeout() -> void:
	has_stalled = false
	angular_damp = 2
	linear_damp = 1

func _on_body_entered(body: Node) -> void:
	var shake_factor: float = 0
	
	if (body.is_in_group("puck") or body.is_in_group("cars")) and linear_velocity.length() < body.linear_velocity.length():
		shake_factor = remap(body.linear_velocity.length(), 0, max_speed, 0.2, 1)
	else:
		shake_factor = remap(linear_velocity.length(), 0, max_speed, 0.5, 1)
	
	camera_shake(Globals.shake_length_factor * shake_factor, Globals.shake_power_factor * shake_factor)
	
	if !has_stalled:
		if !body.is_in_group("puck"):
			if linear_velocity.length() > (max_speed * 0.5):
				has_stalled = true
				angular_damp = 10
				linear_damp = 2
				stall_timer.start()
