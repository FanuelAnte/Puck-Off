extends Control

@onready var car_speed_lbl: Label = %CarSpeedLbl
@onready var puck_speed_lbl: Label = %PuckSpeedLbl

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	car_speed_lbl.text = str(Globals.player_speed).pad_zeros(3) + " U"
	puck_speed_lbl.text = str(Globals.puck_speed).pad_zeros(3) + " U"
	
