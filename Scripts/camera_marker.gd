extends Marker2D

var puck_position: Vector2

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	puck_position = get_tree().get_nodes_in_group("puck")[0].global_position
	
	var direction: Vector2 = (puck_position - self.global_position).normalized()
	var target_angle: float = direction.angle()
	
	self.global_rotation = lerp_angle(self.global_rotation, target_angle, 2 * delta)
