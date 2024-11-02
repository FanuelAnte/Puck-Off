extends Line2D

@export var is_active: bool = true
@export var max_trail_length: int = 35
var point: Vector2

func _ready() -> void:
	set_as_top_level(true)
	
func _process(delta: float) -> void:
	if is_active:
		point = get_parent().global_position
		add_point(point)
		if points.size() > max_trail_length:
			remove_point(0)

func clear_all_points() -> void:
	points = []
	pass
	
