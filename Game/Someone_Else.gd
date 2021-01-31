extends Node2D

var player_num = -1
var hand = []
var player_id = -1

var ready_to_draw = 0

var node_store
var hand_store = []

onready var hand_nodes = [$Closed, $Open]

var player_name = ""

var new_card = preload("res://Cards/Card.tscn")

# warning-ignore:unused_argument
func _process(delta):
	$Player_Stats/VBoxContainer/Label.text = str($Open.get_child_count())
	$Player_Stats/VBoxContainer/Label2.text = str($Closed.get_child_count())


func reposition(angle):
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, angle[0], 0.7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "global_position", global_position, angle[1] * Vector2(cos(deg2rad(angle[0] + 90)), sin(deg2rad(angle[0] + 90))) + Vector2(512, 300), 1, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	$Player_Stats.rect_rotation = -1* angle[0]
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_position += 1.4* Vector2(-sin(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.y, cos(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.x/2).rotated(-deg2rad(angle[0] + 90))


func init(cards, turn, id, angle, nam):
	player_name = nam
	$Player_Stats/Label.text = " " + player_name + " "
	rotation_degrees = angle[0]
	global_position = angle[1] * Vector2(cos(deg2rad(angle[0] + 90)), sin(deg2rad(angle[0] + 90))) + Vector2(512, 300)
	$Player_Stats.rect_rotation = -1* angle[0]
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_pivot_offset = $Player_Stats.rect_size/2
	$Player_Stats.rect_position = Vector2($Player_Stats.rect_pivot_offset.x * -1, 0)
	$Player_Stats.rect_position += 1.4* Vector2(-sin(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.y, cos(deg2rad(angle[0] + 90)) * $Player_Stats.rect_size.x/2).rotated(-deg2rad(angle[0] + 90))
	player_id = id
	player_num = turn
	hand = cards
	hand[0].sort()
	hand[1].sort()
	for card in hand[0]:
		var newer_card = new_card.instance()
		$Closed.add_child(newer_card)
		newer_card.value = card
	for card in hand[1]:
		var newer_card = new_card.instance()
		$Open.add_child(newer_card)
		newer_card.value = card
	redistribute_hand()
	for fchdsou in range(2):
		for regbui in get_child(fchdsou).get_children():
			regbui.init(regbui.value, fchdsou)

func redistribute_hand():
	player_num = Network.player_data[player_name]["num"]
	hand = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			hand[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		hand[y].sort()
		var carded_sorted = 0
		for i in hand[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
		for i in hand_nodes[y].get_children():
			i.target_pos = i.pos_in_par - float(hand_nodes[y].get_child_count()-1)/2
			if hand_nodes[y].get_children().size() > 10:
				i.recenter(400/hand_nodes[y].get_children().size())
			else:
				i.recenter(40)
			i.unhighlight()
#	printt(Network.player_data, player_id)
#	player_num = Network.player_data[player_id]["num"]
#	var card_vals = []
#	for i in get_children():
#		card_vals.append(i.value)
#		if i.highlighted:
#			i.unhighlight()
#		i.pos_in_par = -1
#	card_vals.sort()
#	var carded_sorted = 0
#	for i in card_vals:
#		for j in get_children():
#			if j.value == i and j.pos_in_par == -1:
#				j.pos_in_par = carded_sorted
#				carded_sorted += 1
#	for i in get_children():
#		i.position.x = 30*i.pos_in_par - get_child_count()*10
#		i.target_pos = i.pos_in_par - get_child_count()/2
#		i.recenter()
#		i.unhighlight()

func draw_card(value, pile):
		printt(value)
		var newer_card = new_card.instance()
		hand_nodes[pile].add_child(newer_card)
		hand.append(value)
		hand.sort()
		newer_card.value = value
		redistribute_hand()
		newer_card.init(value, pile)


func check_cards(handd):
	pass

func create_card(val):
		var newer_card = new_card.instance()
		add_child(newer_card)
		newer_card.init(val)
		ready_to_draw += 1


func check_hand_correct():
	pass
#	var ideal_vals = Network.player_data[player_id]["hand"]
#	ideal_vals.sort()
#	hand.sort()
#	print(hand == ideal_vals)
func swap_hands():
	hand = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			hand[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		hand[y].sort()
		var carded_sorted = 0
		for i in hand[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
	
	
	var closed_store = hand[0]
	hand[0] = hand[1]
	hand[1] = closed_store
	$Closed.name = "fdgiofjdp"
	$Open.name = "Closed"
	$fdgiofjdp.name = "Open"
	hand_nodes = [$Closed, $Open]
	$Tween.interpolate_property($Closed, "position:y", $Closed.position.y, 60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property($Open, "position:y", $Open.position.y, -60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()
	for card in $Closed.get_children():
		card.pile = 0
		card.get_node("AnimationPlayer").play("to_closed")
	for card in $Open.get_children():
		card.pile = 1
		card.get_node("AnimationPlayer").play("to_open")

func store_open():
	hand = [[], []]
	for y in range(2):
		for i in hand_nodes[y].get_children():
			hand[y].append(i.value)
			if i.highlighted:
				i.unhighlight()
			i.pos_in_par = -1
		hand[y].sort()
		var carded_sorted = 0
		for i in hand[y]:
			for j in hand_nodes[y].get_children():
				if j.value == i and j.pos_in_par == -1:
					j.pos_in_par = carded_sorted
					carded_sorted += 1
	
	
	hand_store = hand[1]
	
	printt(hand_store, hand[1], "koi")
	$Open.name = "Open" + str(player_num)
	node_store = get_node("Open" + str(player_num))

func send_open(target):
	var pos_store = node_store.global_position
	var rot_store = node_store.global_rotation
	remove_child(node_store)
	target.add_child(node_store)
	if target.name == "Player_1":
		target.card_vals[1] = hand_store
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


func _on_Label_pressed():
	get_tree().current_scene.get_node("RayCast2D").check_players(self)
