extends Node2D

@onready var light_close: PointLight2D = %LightClose
@onready var light_far: PointLight2D = %LightFar
@onready var light_farthest: PointLight2D = %LightFarthest
@onready var light_far_headlights: PointLight2D = %LightFarHeadlights

@export var is_puck: bool = false
@export var car_has_stalled: bool = false

func _ready() -> void:
	if is_puck:
		light_close.hide()
		light_far_headlights.hide()
		
func _physics_process(delta: float) -> void:
	if !is_puck:
		if car_has_stalled:
			light_far_headlights.hide()
		else:
			light_far_headlights.show()
		
func _flash(duration: float) -> void:
	pass
