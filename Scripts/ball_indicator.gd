extends Marker2D

@onready var ball_indicator_sprite: Sprite2D = %BallIndicatorSprite

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	self.look_at(get_tree().get_nodes_in_group("puck")[0].global_position)
	#rotation_degrees = snapped(rotation_degrees, 45)
