extends Control


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass

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
