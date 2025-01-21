extends Node2D

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if GeneralGlobals.match_timer > 0:
		GeneralGlobals.match_timer -= delta
	else:
		GeneralGlobals.match_timer = 0
		
	var total_seconds: int = int(GeneralGlobals.match_timer)
	var minutes: int = int((total_seconds % 3600) / 60)
	var seconds: int = int(total_seconds % 60)
	var milliseconds: int = int((GeneralGlobals.match_timer - total_seconds) * 100)
	
	GeneralGlobals.time_left = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2) + "." + str(milliseconds).pad_zeros(2)
	
