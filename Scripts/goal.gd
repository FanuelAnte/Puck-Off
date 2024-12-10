extends StaticBody2D

@export_enum("Dark", "Light") var team_color: String

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass
	
func _on_puck_detector_body_entered(body: Node2D) -> void:
	if body.is_in_group("puck"):
		if team_color == "Dark":
			GeneralGlobals.light_team_score += 1
		elif team_color == "Light":
			GeneralGlobals.dark_team_score += 1
