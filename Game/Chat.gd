extends Control

onready var main_chat = $VBoxContainer/RichTextLabel
onready var player_name = $VBoxContainer/HBoxContainer/Label
onready var player_input = $VBoxContainer/HBoxContainer/LineEdit

func _ready():
	player_input.release_focus()
	visible = false
	player_name.text = Network.own_name

func _process(delta):
	if Input.is_action_just_pressed("Enter"):
		visible = true
		player_input.grab_focus()
		player_input.caret_position = player_input.text.length()
	if Input.is_action_just_pressed("Leave"):
		visible = false
		player_input.release_focus()


sync func add_message(pname, pmessage):
	if pmessage == "":
		return
	if main_chat.text != "":
		main_chat.append_bbcode("\n")
	if pname == Network.own_name:
		main_chat.append_bbcode("[color=yellow][" + str(pname) + "]: " + str(pmessage) + "[/color]")
	else:
		main_chat.append_bbcode( "[" + str(pname) + "]: " + str(pmessage))


func _on_LineEdit_text_entered(new_text):
	if new_text.begins_with("/"):
		get_tree().current_scene.chat_effect(new_text)
		player_input.text = ""
		return
	rpc("add_message", Network.own_name, new_text)
	player_input.text = ""
