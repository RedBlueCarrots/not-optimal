extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var player_name = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	player_name = Network.own_name
	Network.peer.close_connection()
	Network.connect_to_server(0, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Call_Uno"):
		Network.connect_to_server(0, 0)

sync func start_game():
	Network.own_name = player_name
	get_tree().change_scene("res://Game/Game.tscn")
