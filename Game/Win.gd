extends Node2D

var catchphrases = [
	"CHAAAAAAAAAAAAAAAS",
	"Who done goofed?",
	"And everybody lived happily ever after",
	"Well, that was sub-optimal",
	"ScoMo would be disappointed",
	"That was almost as horrific as the presidential debate!",
	"Finally, it's over"
]

func _ready():
	$Timer.start()

func set_nam(nam, catch):
	$PanelContainer/CenterContainer/VBoxContainer/Player.text = nam
	$PanelContainer/CenterContainer/VBoxContainer/Line.text = catchphrases[catch]

func _on_Timer_timeout():
	for ty in $Node2D.get_children():
		ty.emitting = true
	$PanelContainer.visible = true


func _on_New_pressed():
	Network.reset_lobby()
	get_tree().change_scene("res://Lobby/Lobby.tscn")


func _on_Exit_pressed():
	Network.reset_everything()
	get_tree().change_scene("res://Lobby/Lobby.tscn")
