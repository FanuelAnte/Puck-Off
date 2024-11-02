extends RigidBody2D

@onready var puck_sprite: Sprite2D = %PuckSprite

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	puck_sprite.global_rotation = 0  
