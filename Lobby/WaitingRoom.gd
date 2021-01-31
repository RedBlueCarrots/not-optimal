extends Control

onready var Playerlist = $CenterContainer/ItemList

func _ready():
	Playerlist.clear()


func refresh_players(players):
	Playerlist.clear()
	for player_id in players:
#		printt(players, player_id)
#		var checking_player = players[player_id]["name"]
		Playerlist.add_item(player_id, null, false)



func _on_Button_pressed():
	if get_tree().is_network_server():
		get_parent().rpc("start_game")
