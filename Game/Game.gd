extends Node2D

var value_array = [[-1, -1]]

sync var current_card = [[0, 0], [0, 0]]
sync var current_effect = [0, 0]
sync var current_turn = 0
sync var current_direction = 1

sync var pile_eight = [false, false]

var wild_vals = ["r", "y", "g", "b"]

var reconnectt = false

sync var last_draw = 0

var piles_names = ["Closed", "Open"]
var players = 2

var own_nam = ""

var id_node = {}

var complete_waiting = false

var store_open_deck = 0

var seek_store = 0.0

sync var restricted_piles = [false, false]

var someone_else = preload("res://Game/Someone_Else.tscn")

sync var stacking = [0, 0]

sync var can_play_ = true

var waiting_on = ["", 0]


var win_scene = preload("res://Game/Win.tscn")

func _process(delta):
	$Pile.update_piles(val_to_num(current_card[0]), val_to_num(current_card[1]))
	if get_tree().is_network_server() and Network.game_start:
		rset_unreliable("current_turn", current_turn)
		rset_unreliable("current_card", current_card)
		rset_unreliable("current_effect", current_effect)
		rset_unreliable("current_direction", current_direction)
		rset_unreliable("restricted_piles", restricted_piles)
		rset_unreliable("can_play_", can_play_)
#		rpc_unreliable("update_cards", current_turn)
	if Input.is_action_just_pressed("Leave") and $Control.visible:
		$Control.visible = false
	elif Input.is_action_just_pressed("Leave") and not $Chat.visible:
		$Control.visible = true 

func _ready():
	randomize()
	for i in range(4):
		for j in range(13):
			value_array.append([i, j])
	for r in range(5):
		value_array.append([(r-1+5)%5, 13])
		value_array.append([(r-1+5)%5, 14])
	Network.game__start()
	players = Network.player_data.size()
	if get_tree().is_network_server():
		store_open_deck = randi()%54 + 1
		$Pile.rpc("update_open", store_open_deck)
#		current_card[0] = num_to_val(randi()%54 + 1)
#		current_card[1] = num_to_val(randi()%54 + 1)
		current_card[0] = num_to_val(randi()%12 + 1)
		current_card[1] = num_to_val(randi()%12 + 1)
		$Pile.rpc("update_effects", val_to_num(current_card[0]), val_to_num(current_card[1]))
		current_turn = randi()%players
		pile_eight = [current_card[0][1] == 8, current_card[1][1] == 8]
		rset("current_card", current_card)
		rset("current_effect", [current_card[0][1], current_card[1][1]])
		rset("current_turn", current_turn)
		for i in Network.player_data:
			if Network.player_data[i]["num"] == current_turn:
				rpc("update_cards", i)
		$Pile.rpc("update_piles", val_to_num(current_card[0]), val_to_num(current_card[1]))
	elif Network.game_start:
		yield(get_tree(), "idle_frame")
		Network.init_hand()
		$Pile.update_piles(val_to_num(current_card[0]), val_to_num(current_card[1]))
		for i in Network.player_data:
			if Network.player_data[i]["num"] == current_turn:
				update_cards(i)
		$Arrow/AnimationPlayer.playback_speed = -current_direction * 0.14
		for i in range(4):
			$Arrow.get_child(i).scale = Vector2(current_direction*0.1, 0.1)
		rpc_id(1, "on_player_connected", Network.own_name)
	

remote func on_player_connected(id):
	yield(get_tree(), "idle_frame")
	if waiting_on[0] == id:
		rpc_id(Network.player_data[id]["id"], "update_waiting", current_effect[waiting_on[1]])
	if get_tree().is_network_server():
		$Pile.rpc_id(Network.player_data[id]["id"], "update_open", store_open_deck)

func _on_player_disconnected(id):
	pass

func num_to_val(num):
	return(value_array[num])

func val_to_num(val):
	return(value_array.find(val))

func can_play(val, pile, turn):
	if complete_waiting:
		return
	if stacking[0] != 0 and stacking[1] == pile and current_effect[pile] == 14:
		if turn == current_turn:
			return(val[0] == current_card[pile][0] and val[1] == 4 or val[1] == current_effect[pile] or val[1] == current_card[pile][1])
		else:
			return(val == current_card[pile] or (val[1] == current_card[pile][1] and val[1] > 12))
	if stacking[0] != 0 and stacking[1] == pile and current_effect[pile] == 12:
		if turn == current_turn:
			return((val[0] == current_card[pile][0] and val[1] == 4) or (val[0] == current_card[pile][0] and val[1] == 12) or val[1] == current_card[pile][1])
		else:
			return(val == current_card[pile])
	if not can_play_ or restricted_piles[pile]:
		return false
	if turn == current_turn:
		return(val[0] == current_card[pile][0] or val[1] == current_card[pile][1] or val[1] > 12 or current_card[pile][0] == 4)
	else:
		return(val == current_card[pile] or (val[1] == current_card[pile][1] and val[1] > 12))

func play_card(val, pile, turn, index):
	rpc_id(1, "play_on_server", own_nam, val, pile, turn, index)
#	current_card = val
#	current_turn = turn
#	current_effect = val[1]
#	next_turn()

sync func play_on_server(idd, val, pile, turn, index):
	if can_play(val, pile, turn):
		current_card[pile] = val
		current_turn = turn
		if val[1] != 4:
			current_effect[pile] = val[1]
		rpc("play_other_card", idd, pile, val, index)
		
		update_effects(pile, idd)


sync func next_turn():
	for i in Network.player_data:
		var f = Network.player_data[i]["hand"]
		if f[0].size() + f[1].size() == 0:
			rpc("game_win", i, randi()%7)
			return
	current_turn += current_direction + players
	current_turn %= players
	Network.set_game_data(current_card, current_turn, current_direction, current_effect)
	rset("current_turn", current_turn)
	rset("current_effect", current_effect)
	rset("current_direction", current_direction)
	rset("current_card", current_card)
	printt(current_turn, current_direction)
	var id_store = 0
	for i in Network.player_data:
		if Network.player_data[i]["num"] == current_turn:
			id_store = i
#	Network.check_game_state()
	rset("last_draw", 0)
	rpc("update_cards", id_store)
	for i in $Players.get_children():
		print(i.hand_store)


func attempt_draw(pile):
	if current_turn == get_node("Players/Player_1").player_num and stacking[0] != 0 and stacking[1] == pile:
		for i in range(stacking[0]):
			rpc_id(1, "draw_on_server", own_nam, pile, get_node("Players/Player_1").player_num)
		stacking[0] = 0
		rset("stacking", stacking)
		rset("can_play_", true)
		rpc_id(1, "next_turn")
	if current_turn == get_node("Players/Player_1").player_num and last_draw == pile and can_play_:
		last_draw = pile + 1
		last_draw %=2
		rpc_id(1, "draw_on_server", own_nam, pile, get_node("Players/Player_1").player_num)
#		var new_card = get_node("Players/Player_1").draw_card()
#		if new_card != null:
#			rpc_unreliable("draw_a_card", get_tree().get_network_unique_id(), new_card)

sync func draw_on_server(idd, pile, num):
	for i in get_node("Players").get_children():
		if i.player_name == idd and stacking[0] == 0:
			for y in range(2):
				for j in i.get_node(piles_names[y]).get_children():
					j.get_node("Outline").visible = true
					if can_play(num_to_val(j.value), j.pile, i.player_num):
						return
	if current_turn == num:
		var new_card_val =randi()%54 + 1
		if pile == 1:
			new_card_val = store_open_deck
		rpc("draw_a_card", idd, pile, new_card_val)
		rpc("update_cards", idd)
		resync_network_cards()
		if pile == 1:
			store_open_deck = randi()%54 + 1
			$Pile.rpc("update_open", store_open_deck)

sync func draw_a_card(id, pile, card):
	for s in $Players.get_children():
#		if s.name != "Player_1":
			if s.player_name == id:
				s.draw_card(card, pile)
				s.redistribute_hand()

func create_someone_else(id, turn, hand, angle, nam):
	var new_som = someone_else.instance()
	get_node("Players").add_child(new_som)
	new_som.init(id, turn, hand, angle, nam)


sync func play_other_card(id, pile, val, index):
	for i in Network.player_data:
		for j in $Players.get_children():
			if j.player_name == i:
				id_node[i] = j
	printt(id, pile, val)
	for s in $Players.get_children():
		if s.player_name == id:
			if s.get_node(piles_names[pile]).get_children().size() > index:
				if s.get_node(piles_names[pile]).get_child(index).value == val_to_num(val):
					print("played")
					s.get_node(piles_names[pile]).get_child(index).get_played()
					return
			for c in s.get_node(piles_names[pile]).get_children():
				printt(c.value, val_to_num(val))
				if c.value == val_to_num(val):
					print("played")
					c.get_played()
					return

sync func update_cards(id):
	for i in get_node("Players").get_children():
		if i.player_name == id:
			i.get_node("Player_Stats/Label/HLight").visible = true
			for y in range(2):
				for j in i.get_node(piles_names[y]).get_children():
					if can_play(num_to_val(j.value), j.pile, i.player_num) and get_node("Players/Player_1").player_name == id: #get_tree().get_network_unique_id() == id:
						j.get_node("Sprite").modulate = Color(1, 1, 1, 1)
					else:
						j.get_node("Sprite").modulate = Color(0.6, 0.6, 0.6, 1)
		else:
			i.get_node("Player_Stats/Label/HLight").visible = false
			for y in range(2):
				for j in i.get_node(piles_names[y]).get_children():
					j.get_node("Sprite").modulate = Color(0.6, 0.6, 0.6, 1)

func update_effects(pile, id):
	reset_val_array()
	var ids_all = []
	for i in Network.player_data:
		ids_all.append(i)
	restricted_piles = [false, false]
	if current_effect[(pile+1)%2] != 8 and not pile_eight[pile]:
		if current_effect[pile] == 9:
			restricted_piles[pile] = true
		elif current_effect[pile] == 6:
			restricted_piles[(pile+1)%2] = true
		elif current_effect[pile] == 0:
			var rot_all = []
			for i in range(ids_all.size()):
				rot_all.append(ids_all[(ids_all.size() + i + current_direction)%ids_all.size()])
			rpc("switch_hands", ids_all, rot_all)
		elif current_effect[pile] == 1:
			current_turn -= 2*current_direction
			current_turn += players
			current_turn %= players
		elif current_effect[pile] == 2:
			var closed_store = [current_card[0], current_effect[0]]
			current_card[0] = current_card[1]
			current_effect[0] = current_effect[1]
			current_card[1] = closed_store[0]
			current_effect[1] = closed_store[1]
			$Pile.rpc("swap")
		elif current_effect[pile] == 5:
			rpc("swap_hands", ids_all)
		elif current_effect[pile] == 10:
			current_turn += current_direction
			current_turn += players
			current_turn %= players
		elif current_effect[pile] == 11:
			current_direction *= -1
			rpc("change_dir", current_direction)
		elif current_effect[pile] == 3:
			rset("can_play_", false)
			$RayCast2D.rset_id(Network.player_data[id]["id"], "upload_to_server", true)
			waiting_on = [id, pile]
			var target = yield($RayCast2D, "player_selected")
			rset("can_play_", true)
			rpc("swap_hands", [target])
		elif current_effect[pile] == 7:
			rset("can_play_", false)
			$RayCast2D.rset_id(Network.player_data[id]["id"], "upload_to_server", true)
			waiting_on = [id, pile]
			var target = yield($RayCast2D, "player_selected")
			rset("can_play_", true)
			rpc("switch_hands", [id, target], [target, id])
		elif current_effect[pile] == 12:
			rset("can_play_", false)
			stacking[0] += 2
			stacking[1] = pile
			rset("stacking", stacking)
		elif current_effect[pile] == 13:
			rset("can_play_", false)
			$RayCast2D.rset_id(Network.player_data[id]["id"], "wild", true)
			rpc_id(Network.player_data[id]["id"], "open_wild")
			waiting_on = [id, pile]
			complete_waiting = true
			var target = yield($RayCast2D, "wild_selected")
			rpc_id(Network.player_data[id]["id"], "close_wild")
			$Pile.rpc("change_wild_colour", pile, target, current_card[pile])
			rset("can_play_", true)
			current_card[pile][0] = wild_vals.find(target)
		elif current_effect[pile] == 14:
			rset("can_play_", false)
			$RayCast2D.rset_id(Network.player_data[id]["id"], "wild", true)
			rpc_id(Network.player_data[id]["id"], "open_wild")
			waiting_on = [id, pile]
			complete_waiting = true
			var target = yield($RayCast2D, "wild_selected")
			rpc_id(Network.player_data[id]["id"], "close_wild")
			$Pile.rpc("change_four_colour", pile, target, current_card[pile])
			current_card[pile][0] = wild_vals.find(target)
			stacking[0] += 4
			stacking[1] = pile
			rset("stacking", stacking)
	if current_effect[pile] == 8:
		pile_eight[pile] = true
	else:
		pile_eight[pile] = false
	rset("restricted_piles", restricted_piles)
	if stacking[0] == 0:
		rset("can_play_", true)
	complete_waiting = false
	resync_network_cards()
	next_turn()
#
#sync func check_params(c, t, d, e):
#	current_turn = t
#	current_direction = d
#	current_effect = e
#	if c != current_card:
#		$Pile/Closed.get_child($Pile/Closed.get_child_count() - 1).set_image(c)
#	for i in $Players.get_children():
#		if i.name != "Player_1":
#			i.check_hand_correct()

sync func swap_hands(ids):
	for pla in $Players.get_children():
		if ids.find(pla.player_name) != -1:
			pla.swap_hands()

sync func switch_hands(from, to):
	
	for p in from:
		id_node[p].store_open()
	for p in from:
		id_node[p].send_open(id_node[to[from.find(p)]])
	for p in from:
		id_node[p].reset_open()

sync func open_wild():
	$Wild/AnimationPlayer.play("enter")

sync func close_wild():
	$Wild/AnimationPlayer.play("Exit")

func resync_network_cards():
	for z in $Players.get_children():
		var closedd = []
		var openn = []
		for c in z.get_node("Closed").get_children():
			closedd.append(c.value)
		for c in z.get_node("Open").get_children():
			openn.append(c.value)
		Network.player_data[z.player_name]["hand"] = [closedd, openn]
	Network.rset("player_data", Network.player_data)


func reset_val_array():
	value_array = [[-1, -1]]
	for i in range(4):
		for j in range(13):
			value_array.append([i, j])
	for r in range(5):
		value_array.append([(r-1+5)%5, 13])
		value_array.append([(r-1+5)%5, 14])

remote func update_waiting(effect):
	if effect > 12:
		$RayCast2D.wild = true
		open_wild()
	elif effect == 7 or effect == 3:
		$RayCast2D.upload_to_server = true

sync func new_player(i):
	players += 1
	var player_data = Network.player_data
	var total_order = []
	for n in range(player_data.size()):
		for p in player_data:
			if player_data[p]["num"] == (n+$Players/Player_1.player_num)%player_data.size():
				total_order.append(p)
	var radius = 300
	var angles = []
	for z in total_order:
		angles.append([(360/player_data.size())*total_order.find(z), radius])
	create_someone_else(player_data[i]["hand"], player_data[i]["num"], player_data[i]["id"], angles[total_order.find(i)], i)
	for z in $Players.get_children():
		if z.name != "Player_1":
			z.reposition(angles[total_order.find(z.player_name)])
	for z in Network.player_data:
		if Network.player_data[z]["num"] == current_turn:
			update_cards(z)

sync func uno_called(nam):
	pass
		

func get_unoed(idd):
	for z in range(2):
		var new_card_val =randi()%54 + 1
		if z == 1:
			new_card_val = store_open_deck
		rpc("draw_a_card", idd, z, new_card_val)
		for r in Network.player_data:
			if Network.player_data[r]["num"] == current_turn:
				rpc("update_cards", r)
		resync_network_cards()
		if z == 1:
			store_open_deck = randi()%54 + 1
			$Pile.rpc("update_open", store_open_deck)

sync func show_uno(nam):
	for i in $Players.get_children():
		if i.player_name == nam:
			i.get_node("Speech").global_rotation = 0
			i.get_node("AnimationPlayer").play("Call_Uno")

sync func game_win(player, catch):
	Network.game_start = false
	var win_screen = win_scene.instance()
	add_child(win_screen)
	win_screen.set_nam(player, catch)
	$Pile/Closed/Current_Card.z_index = 0
	$Pile/Open/Current_Card.z_index = 0
	rset("can_play_", false)
	stacking = [0, 0]
	if get_tree().is_network_server():
		for f in Network.player_data:
			Network.player_data[f] = {"id": Network.player_data[f]["id"], "num": 0, "hand": [[], []], "active": true}
	Network.rset("player_data", Network.player_data)

sync func change_dir(num):
	seek_store = $Arrow/AnimationPlayer.current_animation_position
	$Arrow/AnimationPlayer.playback_speed = -num * 0.14
	$Arrow/AnimationPlayer.play("change_rot_dir")
	$Arrow/AnimationPlayer.seek(0.1*(num+1)/2)


func _on_AnimationPlayer_animation_finished(anim_name):
	$Arrow/AnimationPlayer.play("rotate_zooom")
	$Arrow/AnimationPlayer.playback_speed = -0.1 * current_direction
	$Arrow/AnimationPlayer.seek(seek_store)

func reconnect():
	reconnectt = true
	$Reconnect.visible = true


func _on_Reconnect_pressed():
	Network.connect_to_server(0, 0)

func reconnected():
	reconnectt = false
	$Reconnect.visible = false

sync func remove_player(nam):
	for j in $Players.get_children():
		if j.player_name == nam:
			j.queue_free()
		else:
			j.player_num = Network.player_data[j.player_name]["num"]
	players -= 1
	current_turn %= players
	var player_data = Network.player_data
	var total_order = []
	for n in range(player_data.size()):
		for p in player_data:
			if player_data[p]["num"] == (n+$Players/Player_1.player_num)%player_data.size():
				total_order.append(p)
	var radius = 300
	var angles = []
	for z in total_order:
		angles.append([(360/player_data.size())*total_order.find(z), radius])
	for z in $Players.get_children():
		if z.name != "Player_1":
			z.reposition(angles[total_order.find(z.player_name)])
	for z in Network.player_data:
		if Network.player_data[z]["num"] == current_turn:
			update_cards(z)

func chat_effect(tex):
	if tex == "/r":
		Network.player_data[Network.own_name]["active"] = false
		get_tree().change_scene("res://Menus/Reload.tscn")

