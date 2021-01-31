extends Timer

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 19288
const MAX_PLAYERS = 10

sync var game_start = false

var local_player_id = 0
sync var players = {}
remote var game_state = {}
remote var player_data = {}

var own_name = ""

var game_win = false
var peer

var server_info = []

var second_game = false

signal player_disconnected
signal server_disconnected

var host = true


func _ready():
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	randomize()

func create_server(port):
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
	
	add_to_player_list()
	print("CREATED SERVER")
	print("My ID is " + str(local_player_id))
	game_state["pile"] = 1
	game_state["turn"] = 0
	game_state["direction"] = 1
	game_state["effect"] = 0


func connect_to_server(ip, port):
	peer = NetworkedMultiplayerENet.new()
	if server_info == []:
		server_info = [ip, port]
		get_tree().connect("connected_to_server", self, "_connected_to_server")
		get_tree().connect("server_disconnected", self, "_server_disconnected")
	peer.create_client(server_info[0], server_info[1])
	get_tree().set_network_peer(peer)



remote func add_to_player_list():
	local_player_id = get_tree().get_network_unique_id()
	players[local_player_id] = player_data
	create_player(get_tree().current_scene.player_name)


func _connected_to_server():
	set_network_master(1)
	if get_tree().current_scene.name == "Game":
		get_tree().current_scene.reconnected()
#	add_to_player_list()

func _server_disconnected():
#	get_tree().quit()
	print(server_info)
	if get_tree().current_scene.name == "Game":
		get_tree().current_scene.reconnect()
	
##	peer.create_client(server_info[0], server_info[1])
#	connect_to_server(0, 0)

sync func _send_player_info(nam, player_info):
	if get_tree().is_network_server():
		print("ID: " + str(nam) + " has connected owo")
		if not player_data.has(nam):
			player_data[nam] = player_info[nam]
			player_data[nam]["num"] = player_data.size() - 1
			if game_start:
				for bhrif in range(4):
					player_data[nam]["hand"][0].append(randi()%54 + 1)
				for bhrif in range(3):
					player_data[nam]["hand"][1].append(randi()%54 + 1)
				player_data[nam]["hand"][0].sort()
				player_data[nam]["hand"][1].sort()
				rset("player_data", player_data)
				rpc_id(player_data[nam]["id"], "new_player_start")
		rset("player_data", player_data)
		print(player_data)
		rpc("update_waiting_room")
		if game_start:
			get_tree().current_scene.rpc("new_player", nam)

func _on_player_connected(id):
	print( str(id) + " has probably connected")
	if game_win:
		return
	if get_tree().is_network_server():
		if game_start:
			rset_id(id, "game_start", true)
			printt("oi", player_data)
			rset_id(id, "player_data", player_data)
			rpc_id(id, "rejoin_start")
		else:
			rset_id(id, "player_data", player_data)
			rpc_id(id, "add_to_player_list")
#			rpc_id(id, "init_hand")

func _on_player_disconnected(id):
	if get_tree().is_network_server():
		print("ID: " + str(id) + " has disconnected owo")
		players.erase(id)
		rset("players", players)
		if get_tree().current_scene.name == "Lobby":
			for x in player_data:
				if player_data[x]["id"] == id:
					player_data.erase(x)
			rset("player_data", player_data)
			rpc("update_waiting_room")
			
		for i in player_data:
			if player_data[i]["id"] == id:
				player_data[i]["active"] = false
				rset("player_data", player_data)
				return


sync func update_waiting_room():
	get_tree().call_group("WaitingRoom", "refresh_players", player_data)

func create_player(player_name):
	own_name = player_name
	if not get_tree().is_network_server():
		if player_data.has(player_name):
			if player_data[player_name]["active"]:
				peer.close_connection()
				get_tree().current_scene.get_node("WaitingRoom").visible = false
				get_tree().current_scene.get_node("Aaa").popup_centered()
				print("joi")
				return
	print("hoijoi")
	player_data[player_name] = {"id": get_tree().get_network_unique_id(), "num": 0, "hand": [[], []], "active": true}
#	player_data[get_tree().get_network_unique_id()] = {"name": player_name, "num": 0, "hand": [[], []]}
	rpc("_send_player_info", player_name, player_data)
#	rpc("_send_player_info", local_player_id, player_data)

func game__start():
	if get_tree().is_network_server():
		for f in player_data:
			player_data[f] = {"id": player_data[f]["id"], "num": 0, "hand": [[], []], "active": true}
		rset("player_data", player_data)
		game_start = true
		var players_nums = []
		for i in range(player_data.size()):
			players_nums.append(i)
		players_nums.shuffle()
		for i in player_data:
			player_data[i]["num"] = players_nums.front()
			players_nums.remove(0)
#			for bhrif in range(3):
#				player_data[i]["hand"][0].append(2)
#			for bhrif in range(1):
#				player_data[i]["hand"][1].append(2)
			for bhrif in range(4): #4
				player_data[i]["hand"][0].append(randi()%54 +1)
			for bhrif in range(3): #3
				player_data[i]["hand"][1].append(randi()%54 +1)
			player_data[i]["hand"][0].sort()
			player_data[i]["hand"][1].sort()
		rset("player_data", player_data)
		rpc("init_hand")
#		get_tree().current_scene.next_turn(0)
#		for i in player_data:
#			if i != get_tree().get_network_unique_id():
#				get_tree().current_scene.create_someone_else(player_data[i]["hand"], player_data[i]["num"], i)

sync func init_hand():
#	var own_num = player_data[get_tree().get_network_unique_id()]["num"]
	second_game = false
	var own_num = player_data[own_name]["num"]
	printt(own_name, own_num, player_data)
	var total_order = []
	for n in range(player_data.size()):
		for p in player_data:
			print(p)
			if player_data[p]["num"] == (n+own_num)%player_data.size():
				total_order.append(p)
	printt(total_order, player_data)
	var radius = 300
	var angles = []
	for i in total_order:
		angles.append([(360/player_data.size())*total_order.find(i), radius])
	for i in total_order:
		if i != own_name:
			get_tree().current_scene.create_someone_else(player_data[i]["hand"], player_data[i]["num"], player_data[i]["id"], angles[total_order.find(i)], i)
		else:
			get_tree().current_scene.get_node("Players/Player_1").init(player_data[i]["hand"], player_data[i]["num"], angles[total_order.find(i)], own_name)

func reset_player_data():
	pass
#	rpc_id(1, "server_update_data", get_tree().get_network_unique_id(), player_data)

sync func server_update_data(id, data):
	print("network_called")
#	player_data[id] = data[id]
#	rset("player_data", player_data)

func set_game_data(a, b, c, d):
	rpc_id(1, "server_update_game_state", a, b, c, d)


sync func server_update_game_state(a, b, c, d):
	game_state["pile"] = a
	game_state["turn"] = b
	game_state["direction"] = c
	game_state["effect"] = d
	rset("game_state", game_state)

sync func check_game_state():
	return
#	get_tree().current_scene.check_params(game_state["pile"], game_state["turn"], game_state["direction"], game_state["effect"])




remote func rejoin_start():
	if get_tree().current_scene.name == "Game":
		get_tree().current_scene.get_node("Players/Player_1").reset_id()
		return
	var player_name = get_tree().current_scene.player_name
	if not get_tree().is_network_server():
		if player_data.has(player_name):
			if player_data[player_name]["active"]:
				peer.close_connection()
				get_tree().current_scene.number_entered = 0
				get_tree().current_scene.alert_error(5)
				print("joi")
				return
	if player_data.has(player_name):
		player_data[player_name]["active"] = true
		rset("player_data", player_data)
		get_tree().current_scene.start_game()
	else:
		add_to_player_list()

remote func new_player_start():
	get_tree().current_scene.start_game()

func reset_everything():
	peer.close_connection()
	game_start = false
	local_player_id = 0
	players = {}
	game_state = {}
	player_data = {}
	own_name = ""
	peer = null
	server_info = []

func reset_lobby():
	second_game = true
	printt("New Game", own_name)

func leave_game():
	rpc_id(1, "boot_player", own_name)


sync func finally_leave():
	peer.close_connection()
	get_tree().change_scene("res://Menus/Start_Scene.tscn")

sync func boot_player(nam):
	rpc_id(player_data[nam]["id"], "finally_leave")
	var num_store = player_data[nam]["num"]
	for y in player_data:
		if player_data[y]["num"] > num_store:
			player_data[y]["num"] -= 1
	player_data.erase(nam)
	print("ioi")
	rset("player_data", player_data)
	get_tree().current_scene.rpc("remove_player", nam)
