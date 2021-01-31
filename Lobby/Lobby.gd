extends Control

var player_name = ""
var player_ip = "127.0.0.1"
var player_port = 1928
var connected = false

onready var NameTextBox = $VBoxContainer/CenterContainer/GridContainer/NameBox

func _ready():
	if Network.second_game:
		create_waiting_room()
		Network.update_waiting_room()
		player_name = Network.own_name
	get_tree().connect("network_peer_connected", self, "_on_player_connected")


func _on_HostButton_pressed():
	get_textedit_values()
	create_waiting_room()
	Network.create_server(player_port)
	print(player_name)
	
#	Network.create_player(player_name)

func _on_JoinButton_pressed():
	get_textedit_values()
	create_waiting_room()
	Network.connect_to_server(player_ip, player_port)
	Network.own_name = player_name
#	Network.create_player(player_name)

	

func get_textedit_values():
	player_name = $VBoxContainer/CenterContainer/GridContainer/NameBox.text
	player_ip = $VBoxContainer/CenterContainer/GridContainer/IPBox.text

	player_port = int($VBoxContainer/CenterContainer/GridContainer/PortBox.text)
	


func _on_player_connected(id):
	connected = true



func create_waiting_room():
	$WaitingRoom.visible = true
#	$WaitingRoom.refresh_players(Network.players)

sync func start_game():
	Network.own_name = player_name
	get_tree().change_scene("res://Game/Game.tscn")


func _on_AcceptDialog_confirmed():
	get_tree().reload_current_scene()
