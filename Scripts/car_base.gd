extends RigidBody2D

@onready var camera: Camera2D = %Camera
@onready var center_marker: Marker2D = %CenterMarker
@onready var stall_timer: Timer = %StallTimer
@onready var stall_progress_bar: TextureProgressBar = %StallProgressBar
@onready var car_sprite: Sprite2D = %CarSprite
@onready var body_collider: CollisionShape2D = %BodyCollider
@onready var bumper_collider: CollisionShape2D = %BumperCollider
@onready var chase_timer: Timer = %ChaseTimer

@export var is_player: bool = false
@export var car_resource_file: Resource
@export_enum("Dark", "Light") var team_color: String

signal zoom_camera(zoom_value: Vector2)

var has_zoomed_out: bool = false
var has_zoomed_in: bool = true

var velocity: Vector2 = Vector2.ZERO
var turn_direction: int = 0

var can_chase_ball: bool = true

var engine_power: int = 600
var max_speed: int = 350
var turn_speed: int = 1200

var is_steering: bool = true
var has_stalled: bool = false

var right_direction: Vector2
var max_lateral_sliding_reduction: float = 0
var lateral_sliding_reduction: float = 0

var reverse_speed_factor: float = 0

var puck_position: Vector2
var center_field_postion: Vector2 = Vector2(0, 0)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
		
func _ready() -> void:
	center_of_mass = car_resource_file.center_of_mass_position
	
	if team_color == "Dark":
		car_sprite.frame = car_resource_file.car_sprite + 6
	elif team_color == "Light":
		car_sprite.frame = car_resource_file.car_sprite
	
	var body_collider_shape: CapsuleShape2D = CapsuleShape2D.new()
	body_collider_shape.radius = 7
	body_collider_shape.height = car_resource_file.collider_height
	body_collider.shape = body_collider_shape
	
	var bumper_collider_shape: CapsuleShape2D = CapsuleShape2D.new()
	bumper_collider_shape.radius = 2
	bumper_collider_shape.height = car_resource_file.bumper_collider_height
	bumper_collider.shape = bumper_collider_shape
	
	bumper_collider.position = car_resource_file.bumper_collider_position
	
	engine_power = car_resource_file.engine_power
	max_speed = car_resource_file.max_speed
	turn_speed = car_resource_file.turn_speed
	
	max_lateral_sliding_reduction = car_resource_file.max_lateral_sliding_reduction
	lateral_sliding_reduction = car_resource_file.max_lateral_sliding_reduction
	
	reverse_speed_factor = car_resource_file.reverse_speed_factor
	
func _physics_process(delta: float) -> void:
	get_input(delta)
	apply_central_force(velocity)
	
	var normalized_speed: float = snappedf(remap(linear_velocity.length(), 0, max_speed, 0, 1), 0.01)
	var dynamic_steering_factor: float = snappedf(car_resource_file.steering_graph.sample(normalized_speed), 0.01)
	
	if linear_velocity.length() > 15:
		apply_torque(turn_direction * turn_speed * dynamic_steering_factor)
	else:
		angular_velocity = 0
	
	right_direction = transform.y.rotated(PI/2)
	var lateral_velocity: Vector2 = right_direction * linear_velocity.dot(right_direction)
	linear_velocity -= lateral_velocity * lateral_sliding_reduction
	
func _process(delta: float) -> void:
	if has_stalled and !stall_timer.is_stopped():
		stall_progress_bar.show()
		stall_progress_bar.value = remap(snappedf(stall_timer.time_left, 0.01), 0, stall_timer.wait_time, 0, 100) 
	else:
		stall_progress_bar.hide()
		
	puck_position = get_tree().get_nodes_in_group("puck")[0].global_position
	
	if is_player and SettingsGlobals.dynamic_zooming:
		if clamp(linear_velocity.length(), 0, max_speed) > (max_speed)/2:
			if !has_zoomed_out:
				emit_signal("zoom_camera", Vector2(0.8, 0.8))
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
				velocity = transform.y * engine_power * reverse_speed_factor
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
				if lateral_sliding_reduction <= max_lateral_sliding_reduction:
					lateral_sliding_reduction += 0.1 * delta
		else:
			velocity = Vector2.ZERO
			turn_direction = 0
			
	else:
		var direction: Vector2 = center_field_postion - self.global_position
		
		if !has_stalled:
			if (puck_position - self.global_position).length() > 32:
				if can_chase_ball:
					direction = (puck_position - self.global_position)
			else:
				can_chase_ball = false
				chase_timer.start(snappedf(randf_range(1, 3), 0.5))
				
			var angle: int = rad_to_deg(self.transform.y.angle_to(direction) * -1)
			
			turn_direction = sign(angle) * 1
			
			if abs(angle) >= 65:
				velocity = transform.y * engine_power * -1
				
			elif abs(angle) < 65:
				velocity = transform.y * engine_power * reverse_speed_factor
				
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
	
	camera_shake(SettingsGlobals.shake_length_factor * shake_factor, SettingsGlobals.shake_power_factor * shake_factor)
		
	#if !has_stalled:
		#if body.is_in_group("arena"):
			#if linear_velocity.length() > (max_speed * 0.6):
				#has_stalled = true
				#angular_damp = 15
				#linear_damp = 5
				#stall_timer.start()
				
func _on_chase_timer_timeout() -> void:
	can_chase_ball = true
