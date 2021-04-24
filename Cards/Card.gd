extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim = $Tween2
var pos_store = Vector2.ZERO
var highlighted = false
var played = false
var value = 1
var pos_in_par = -1
var started = false
var pile = 0
var piles_nodes = ["Pile/Closed", "Pile/Open"]
var c_id = 0
var before = true
var vall = 40

var target_pos = 0.0

# Called when the node enters the scene tree for the first time.
func init(val, p):
	value = val
	pile = p
	if pile == 0 and get_parent().get_parent().name != "Player_1":
		$Back.visible = true
	else:
		$Back.visible = false
	load_image(value)
	yield(get_tree(),"idle_frame")
	z_index = pos_in_par
	position.y = 0
#	position.x = 20*pos_in_par - get_parent().get_child_count()*10
#	target_pos = pos
	global_position = get_tree().current_scene.get_node("Pile").global_position
	global_position.x += 120*pile - 60
	global_position.y -= 60
	anim.interpolate_property(self, "position", position, Vector2(vall*target_pos, 0), 0.7, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	anim.start()

func _process(delta):
	if Input.is_action_just_pressed("ui_select") and highlighted and not played:
		if get_parent().get_parent().try_play(value, pile, get_index()):
			pass
#			get_played()

func load_image(index):
	$Sprite.texture = load("res://Card_Images/UNO_"+str(index)+".png")

func highlight():
	if not played:
		anim.interpolate_property(self, "scale", Vector2(1, 1), Vector2(1.1, 1.1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim.interpolate_property(self, "position", position, Vector2(target_pos*vall, -20), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim.start()
		$Second_Checker.disabled = false
		highlighted = true

func unhighlight():
	if not played:
		anim.interpolate_property(self, "scale", scale, Vector2(1, 1), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim.interpolate_property(self, "position", position, Vector2(target_pos*vall, 0), 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		anim.start()
		$Second_Checker.disabled = true
		highlighted = false

func recenter(val):
	vall = val
	position.x = val*target_pos
	pos_store.x = position.x
	z_index = pos_in_par

func get_played():
	anim.stop_all()
	anim.playback_speed = 9999
	
	played = true
	$KinematicBody2D.disabled = true
	var pile_node = get_tree().current_scene.get_node(piles_nodes[pile]).get_node("Current_Card")
	var old_par = get_parent().get_parent()
	pos_store += get_parent().position
	pos_store += get_parent().get_parent().position
	get_parent().remove_child(self)
	pile_node.add_child(self)
	get_parent().get_parent().get_parent().add_to_pile(self, pile)
	global_position = pos_store
	$Tween.interpolate_property(self, "position:x", position.x, 0, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "position:y", position.y, 0, 2, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, randi()%720 - 360, 0.6, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	get_node("Outline").visible = false
	old_par.redistribute_hand()
	$Back.visible = false
	$KinematicBody2D.disabled = true
	$Second_Checker.disabled = true



func _on_Tween_tween_all_completed():
	if not started:
		$KinematicBody2D.disabled = false
		started = true
		get_parent().get_parent().ready_to_draw -= 1
		unhighlight()

func set_image(c):
	load_image(c)

func throw():
	var dir = global_position.direction_to(Vector2(512, 300))
	var dist = global_position.distance_to(Vector2(512, 300))
	$Tween3.interpolate_property(self, "global_position", global_position, global_position + (dist * (randf()*0.8 + 0.7) + (randf()*250 + 50)) * dir.rotated(deg2rad(randf() * 45 - 22.5)), (randf() * 2 + 1)/3.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween3.start()
