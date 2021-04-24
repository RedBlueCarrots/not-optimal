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
	if not get_tree().is_network_server():
		$Node/VBoxContainer/New.visible = false

func set_nam(nam, catch):
	$Node/VBoxContainer/Player.text = nam + " Wins!"
	$Node/VBoxContainer/Line.text = catchphrases[catch]


func _on_New_pressed():
	Network.reset_lobby()
	get_tree().change_scene("res://Lobby/Lobby.tscn")


func _on_Exit_pressed():
	Network.reset_everything()
	get_tree().change_scene("res://Lobby/Lobby.tscn")
