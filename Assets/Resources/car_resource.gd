extends Resource

class_name car_resource

@export_enum("Charger", "GTI", "Stratos", "Stingray", "2002 Tii", "250 GT") var car_name: String

@export var engine_power: int = 600
@export var boost_engine_power: int = 2400

@export var max_speed: int = 400
@export var boost_max_speed: int = 600

@export var max_lateral_sliding_reduction: float = 0.9

@export var turn_speed: int = 500
@export var steering_graph: Curve

@export var collider_height: int
@export var bumper_collider_position: Vector2
@export var center_of_mass_position: Vector2
@export var bumper_collider_height: int

@export var car_sprite: int
