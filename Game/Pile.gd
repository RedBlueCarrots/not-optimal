extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var height_of_pile = [0, 0]
onready var p_nodes = [$Closed, $Open]


var wild_vals = ["r", "y", "g", "b"]

func _process(delta):
	$Closed/Current_Card.visible = true
	$Open/Current_Card.visible = true
	$Closed/Current_Effect.visible = false
	$Open/Current_Effect.visible = false

sync func update_open(val):
	$DrawO/Sprite.texture = load("res://Card_Images/UNO_"+str(val)+".png")

sync func update_effects(cl, op):
	$Closed/Current_Effect/Sprite.texture = load("res://Card_Images/UNO_"+str(cl)+".png")
	$Open/Current_Effect/Sprite.texture = load("res://Card_Images/UNO_"+str(op)+".png")

sync func update_piles(cl, op):
	if cl != -1:
		$Closed/Current_Card.get_child(0).get_node("Sprite").texture = load("res://Card_Images/UNO_"+str(cl)+".png")
	if op != -1:
		$Open/Current_Card.get_child(0).get_node("Sprite").texture = load("res://Card_Images/UNO_"+str(op)+".png")

func add_to_pile(card, pile):
		var old_card = p_nodes[pile].get_node("Current_Card").get_child(0)
		p_nodes[pile].get_node("Current_Card").remove_child(old_card)
		p_nodes[pile].get_node("Old_Cards").add_child(old_card)
		if old_card.position != Vector2(0, 0):
			old_card.get_node("Tween").resume_all()
		card.z_index = 0
		card.get_node("Sprite").modulate = Color(1, 1, 1, 1)
		print(card.value)
		if get_parent().num_to_val(card.value)[1] != 4:
			p_nodes[pile].get_node("Current_Effect/Sprite").texture = load("res://Card_Images/UNO_"+str(card.value)+".png")
#		height_of_pile[pile] += 1
		if p_nodes[pile].get_node("Old_Cards").get_child_count() > 10:
				p_nodes[pile].get_node("Old_Cards").get_child(0).queue_free()

sync func swap():
	$Closed.name = "fdgiofjdp"
	$Open.name = "Closed"
	$fdgiofjdp.name = "Open"
	p_nodes = [$Closed, $Open]
	var h_store = height_of_pile[0]
	height_of_pile[0] = height_of_pile[1]
	height_of_pile[1] = h_store
	$Closed/Tween.interpolate_property($Closed, "position:x", $Closed.position.x, -60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Open/Tween.interpolate_property($Open, "position:x", $Open.position.x, 60, 0.8, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Closed/Tween.start()
	$Open/Tween.start()
	$Closed/Current_Effect.position.x = 0
	$Open/Current_Effect.position.x = 0
#	$Open.get_child($Open.get_child_count() - 1).z_index 
#	var closed_cards = []
#	for c in $Closed.get_children():
#		closed_cards.append(c)
##		$Closed.remove_child(c)
##		$Open.add_child(c)
#	for d in $Open.get_children():
#		var pos_store = d.global_position
#		$Open.remove_child(d)
#		$Closed.add_child(d)
#		d.z_index = d.pos_in_par
#		d.global_position = pos_store
#		d.get_node("Tween").interpolate_property(d, "position", d.position, Vector2(0, 0), float(randi()%8 + 5)/10, Tween.TRANS_CUBIC, Tween.EASE_OUT)
#		d.get_node("Tween").start()
#	for e in closed_cards:
#		var pos_store = e.global_position
#		$Closed.remove_child(e)
#		$Open.add_child(e)
#		e.z_index = e.pos_in_par
#		e.global_position = pos_store
#		e.get_node("Tween").interpolate_property(e, "position", e.position, Vector2(0, 0), float(randi()%8 + 5)/10, Tween.TRANS_CUBIC, Tween.EASE_OUT)
#		e.get_node("Tween").start()

sync func change_wild_colour(pile, color, card):
	pass
#	if card[1] != 4:
#		p_nodes[pile].get_node("Current_Card").get_child(0).get_node("Sprite").texture = load("res://Card_Images/wild" + color + ".png")
#	else:
#		p_nodes[pile].get_node("Current_Card").get_child(0).get_node("Sprite").texture = load("res://Card_Images/UNO_" + str(get_parent().val_to_num([wild_vals.find(color), card[1]])) + ".png")

sync func change_four_colour(pile, color, card):
	pass
#	if card[1] != 4:
#		p_nodes[pile].get_node("Current_Card").get_child(0).get_node("Sprite").texture = load("res://Card_Images/your" + color + ".png")
#	else:
#		p_nodes[pile].get_node("Current_Card").get_child(0).get_node("Sprite").texture = load("res://Card_Images/UNO_" + str(get_parent().val_to_num([wild_vals.find(color), card[1]])) + ".png")
