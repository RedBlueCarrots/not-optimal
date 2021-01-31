extends Control
var val_set = false

func _process(delta):
	if val_set:
		Network.get_node("Brightness").modulate = Color(0, 0, 0, 1-$GridContainer/HSlider.value/255)
#		$GridContainer/HSlider.value
	OS.window_fullscreen = $GridContainer/CheckButton.pressed

func _ready():
	$GridContainer/HSlider.value = 255 - Network.get_node("Brightness").modulate.a * 255
	val_set = true

func _on_Exit_pressed():
	visible = false


func _on_Exit2_pressed():
	Network.leave_game()
