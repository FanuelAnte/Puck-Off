extends Control

@onready var time_lbl: Label = %TimeLbl
@onready var dark_team_score_lbl: Label = %DarkTeamScoreLbl
@onready var light_team_score_lbl: Label = %LightTeamScoreLbl
@onready var accel_lbl: Label = %AccelLbl

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	time_lbl.text = str(GeneralGlobals.time_left)
	dark_team_score_lbl.text = str(GeneralGlobals.dark_team_score)
	light_team_score_lbl.text = str(GeneralGlobals.light_team_score)
	
	accel_lbl.text = str(snappedf(clamp(Input.get_accelerometer().x, -2, 2), 0.01))
	
func vibrate() -> void:
	Input.vibrate_handheld(50, 0.5)

func _on_d_pad_left_pressed() -> void:
	vibrate()
	
func _on_d_pad_right_pressed() -> void:
	vibrate()

func _on_a_button_pressed() -> void:
	vibrate()

func _on_z_button_pressed() -> void:
	vibrate()
