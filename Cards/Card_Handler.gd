extends Node2D


# Declare member variables here. Examples:
# var a = 2
var new_card = preload("res://Cards/Card.tscn")
var player_num = 0
var clicked = false
var player_id = 2
var card_vals = [[], []]

var closed_store = []

var player_name = ""

onready var hand_nodes = [$Closed, $Open]

var node_store
var hand_store = []
var ang = 0
var ready_to_draw = 0
# var b = "text"
func _process(delta):
	clicked = false
	for y in range(2):
		for j in hand_nodes[y].get_children():
			if get_tree().current_scene.can_play(get_tree().current_scene.num_to_val(j.value), y, player_num):
				j.get_node("Sprite").modulate = Color(1, 1, 1, 1)
			else:
				j.get_node("Sprite").modulate = Color(0.6, 0.6, 0.6, 1)
	$Player_Stats/VBoxContainer/Label.text = str($Open.get_child_count())
	$Player_Stats/VBoxContainer/Label2.text = str($Closed.get_child_count())




func init(hand, turn, angle, nam):
	ang = angle [0]
	player_name = nam
	$Player_Stats/Label.text = " " + player_name + " "
	get_parent().get_parent().own_nam = nam
	rotation_degrees = 360 - (-1 * angle[0])
	global_position = angle[1] * Vector2(sin(deg2rad(-angle[0])), cos(deg2rad(-angle[0]))) + Vector2(512, 300)
	$Player_Stats.rect_rotation = -1* angle[0]
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_position += 1.4* Vector2(-sin(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.y, cos(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.x/2).rotated(-deg2rad(angle[0] + 90))
	card_vals = hand
	card_vals[0].sort()
	card_vals[1].sort()
	player_id = get_tree().get_network_unique_id()
	Network.player_data[player_name]["id"] = player_id
	Network.rset("player_data", Network.player_data)
	for i in range(card_vals[0].size()):
		var newer_card = new_card.instance()
		$Closed.add_child(newer_card)
		newer_card.value = card_vals[0][i]
		ready_to_draw += 1
	for i in range(card_vals[1].size()):
		var newer_card = new_card.instance()
		$Open.add_child(newer_card)
		newer_card.value = card_vals[1][i]
		ready_to_draw += 1
	redistribute_hand()
	for fchdsou in range(2):
		for regbui in get_child(fchdsou).get_children():
			regbui.init(regbui.value, fchdsou)
#	Network.player_data[id]["hand"] = card_vals
#	Network.reset_player_data()
func create_card(val):
		var newer_card = new_card.instance()
		add_child(newer_card)
		newer_card.init(val)
		ready_to_draw += 1

func can_click():
	if not clicked:
		clicked = true
		return true
	else:
		return false

func redistribute_hand():
	player_num = Network.player_data[player_name]["num"]
	var card_vals = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			card_vals[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		card_vals[y].sort()
		var carded_sorted = 0
		for i in card_vals[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
		for i in hand_nodes[y].get_children():
			i.position.x = 40*i.pos_in_par - hand_nodes[y].get_child_count()*40
			i.target_pos = i.pos_in_par - float(hand_nodes[y].get_child_count() - 1)/2
			i.recenter(40)
			i.unhighlight()
		get_tree().current_scene.get_node("RayCast2D").rehighlight()
#	Network.player_data[player_id]["hand"] = card_vals
#	Network.server_update_data(player_id, Network.player_data)
func try_play(num, pile, index):
	var val = owner.num_to_val(num)
	if owner.can_play(val, pile, player_num):
		owner.play_card(val, pile, player_num, index)
		return true
	return false

#SERVERFY
#func draw_card():
#	print(ready_to_draw)
#	if ready_to_draw == 0:
#		var newer_card = new_card.instance()
#		add_child(newer_card)
#		var new_card_val =randi()%52 + 1
#		card_vals.append(new_card_val)
#		card_vals.sort()
#		newer_card.value = new_card_val
#		redistribute_hand()
#		newer_card.init(new_card_val)
#		ready_to_draw += 1
#		print("hi")
#		return newer_card.value
#	return null

func draw_card(value, pile):
		printt(value)
		var newer_card = new_card.instance()
		hand_nodes[pile].add_child(newer_card)
		card_vals[pile].append(value)
		card_vals[pile].sort()
		newer_card.value = value
		redistribute_hand()
		newer_card.init(value, pile)


func check_cards(hand):
	pass

func swap_hands():
	var card_vals = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			card_vals[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		card_vals[y].sort()
		var carded_sorted = 0
		for i in card_vals[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
	
	closed_store = card_vals[0]
	card_vals[0] = card_vals[1]
	card_vals[1] = closed_store
	printt(closed_store, "loi")
	$Closed.name = "fdgiofjdp"
	$Open.name = "Closed"
	$fdgiofjdp.name = "Open"
	hand_nodes = [$Closed, $Open]
	$Tween.interpolate_property($Closed, "position:y", $Closed.position.y, 60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Open, "position:y", $Open.position.y, -60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	for card in $Closed.get_children():
		card.pile = 0
	for card in $Open.get_children():
		card.pile = 1

func store_open():
	var card_vals = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			card_vals[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		card_vals[y].sort()
		var carded_sorted = 0
		for i in card_vals[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
	
	hand_store = card_vals[1]
	printt(hand_store, card_vals[1], "koi")
	$Open.name = "Open" + str(player_num)
	node_store = get_node("Open" + str(player_num))

func send_open(target):
	var pos_store = node_store.global_position
	var rot_store = node_store.global_rotation
	remove_child(node_store)
	target.add_child(node_store)
	if target.name == "Player_1":
		target.card_vals[1] = hand_store
		printt(target.card_vals[1], hand_store)
	else:
		target.hand[1] = hand_store
	node_store.global_position = pos_store
	node_store.global_rotation  = rot_store
	$Tween.interpolate_property(node_store, "position", node_store.position, Vector2(0, -60), 1.2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(node_store, "rotation", node_store.rotation, 0, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func reset_open():
	for i in get_children():
		if i.name.left(4) == "Open":
			i.name = "Open"
			hand_nodes[1] = $Open
			return
	redistribute_hand()

func reset_id():
	player_id = get_tree().get_network_unique_id()
	Network.player_data[player_name]["id"] = player_id
	Network.rset("player_data", Network.player_data)


func _on_Label_pressed():
	get_tree().current_scene.get_node("RayCast2D").check_players(self)
