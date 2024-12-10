extends Node2D

@onready var light_p_1: Marker2D = %LightP1
@onready var light_p_2: Marker2D = %LightP2
@onready var light_p_3: Marker2D = %LightP3
@onready var dark_p_1: Marker2D = %DarkP1
@onready var dark_p_2: Marker2D = %DarkP2
@onready var dark_p_3: Marker2D = %DarkP3
@onready var center_ball_marker: Marker2D = %CenterBallMarker
@onready var light_ball_marker: Marker2D = %LightBallMarker
@onready var dark_ball_marker: Marker2D = %DarkBallMarker

@onready var ball_markers: Array = [center_ball_marker, light_ball_marker, dark_ball_marker]
@onready var dark_team_markers: Array = [dark_p_1, dark_p_2, dark_p_3]
@onready var light_team_markers: Array = [light_p_1, light_p_2, light_p_3]

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
