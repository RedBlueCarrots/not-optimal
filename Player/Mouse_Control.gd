extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
sync var wild = false
var current_highlight = null

#var find_in = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
# Called when the node enters the scene tree for the first time.
signal player_selected
signal wild_selected
sync var upload_to_server = false
	
func _process(delta):
	global_position = get_global_mouse_position()
	if get_overlapping_areas().size() > 0 and not wild:
		if get_overlapping_areas()[0].name == "DrawC":
			if Input.is_action_just_pressed("ui_select"):
				owner.attempt_draw(0)
				print("drawing")
			return
		if get_overlapping_areas()[0].name == "DrawO":
			if Input.is_action_just_pressed("ui_select"):
				owner.attempt_draw(1)
				print("drawing")
			return
		if get_overlapping_areas()[0].get_parent().get_parent().name != "Player_1":
			return
		var z_test = -4096
		var body_store = null
		for i in get_overlapping_areas():
			if i.z_index > z_test:
				z_test = i.z_index
				body_store = i 
		if current_highlight != body_store:
			body_store.highlight()
			if current_highlight != null:
				current_highlight.unhighlight()
			current_highlight = body_store

	else:
		if current_highlight != null and is_instance_valid(current_highlight):
			current_highlight.unhighlight()
			current_highlight = null
	if $Wild.get_overlapping_areas().size() > 0:
			if Input.is_action_just_pressed("ui_select"):
#				emit_signal("player_selected", $Players.get_overlapping_areas()[0].name)
				if wild:
					rpc_id(1, "send_to_server", "wild_selected", $Wild.get_overlapping_areas()[0].name)
					wild = false
	if $Views.get_overlapping_areas().size() > 0:
		var pill = $Views.get_overlapping_areas()[0].get_parent()
		if pill.name == "Closed":
			if get_tree().current_scene.current_card[0][1] == 4:
				pill.get_node("Current_Card").visible = false
				pill.get_node("Current_Effect").visible = true
		else:
			if get_tree().current_scene.current_card[1][1] == 4:
				pill.get_node("Current_Card").visible = false
				pill.get_node("Current_Effect").visible = true

sync func send_to_server(comm, idd):
	emit_signal(comm, str(idd))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

func rehighlight():
	if get_overlapping_areas().size() > 0 and get_overlapping_areas()[0].get_parent().name != "Pile":
		var z_test = -4096
		var body_store
		for i in get_overlapping_areas():
			if i.z_index > z_test:
				z_test = i.z_index
				body_store = i 
			body_store.highlight()
		current_highlight = body_store

func check_players(nod):
	if nod.name != "Player_1":
		if upload_to_server:
			rpc_id(1, "send_to_server", "player_selected", nod.player_name)
			upload_to_server = false
