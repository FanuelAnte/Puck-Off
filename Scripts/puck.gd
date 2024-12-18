extends RigidBody2D

@onready var puck_sprite: Sprite2D = %PuckSprite

var max_speed: int = 600

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > max_speed:
		state.linear_velocity = state.linear_velocity.normalized() * max_speed
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	puck_sprite.global_rotation = 0
