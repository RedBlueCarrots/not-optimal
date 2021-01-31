extends Control

var player_name = ""
var player_ip = "127.0.0.1"
var player_port = 1928

var number_entered = 0

var error_codes = ["ERROR 001:\nName too long\n11 character limit", 
	"ERROR 002:\nName too short\n1 character minimum", 
	"ERROR 003:\nInvalid Name", 
	"ERROR 004:\nInvalid Port",
	"ERROR 005:\nInvalid IP Address",
	"ERROR 006:\nName already taken"]

var default_ips = [
	"127.0.0.1",
	"210.185.66.243"
]

func _ready():
	$AcceptDialog.get_ok().enabled_focus_mode = Control.FOCUS_NONE
	$AcceptDialog.get_child(0).visible = false
	$AcceptDialog.get_label().align = Label.ALIGN_CENTER

func _physics_process(delta):
	if Input.is_action_just_released("Enter"):
		if $AcceptDialog.visible:
			$AcceptDialog.visible = false
			return
		else:
			set_val($VBoxContainer/LineEdit.text)
	if Input.is_action_just_pressed("Tab") and number_entered == 2:
		$VBoxContainer/LineEdit.text = default_ips[(default_ips.find($VBoxContainer/LineEdit.text)+1) % default_ips.size()]
		$VBoxContainer/LineEdit.caret_position = $VBoxContainer/LineEdit.text.length()

func set_val(tex):
	if number_entered == 0:
		player_name = tex
		if $VBoxContainer/LineEdit.text.length() > 11:
			alert_error(0)
			return
		if $VBoxContainer/LineEdit.text.length() == 0:
			return
		if not $VBoxContainer/LineEdit.text.dedent().is_valid_filename() or $VBoxContainer/LineEdit.text.is_valid_float() or $VBoxContainer/LineEdit.text.is_valid_ip_address():
			alert_error(2)
			return
		$VBoxContainer/Label.text = "Port:"
		$VBoxContainer/LineEdit.text = "1928"
		$VBoxContainer/LineEdit.caret_position = "1928".length()
	elif number_entered == 2:
		player_ip = tex
		if $VBoxContainer/LineEdit.text.length() == 0:
			$VBoxContainer/LineEdit.text = "127.0.0.1"
			return
		if not $VBoxContainer/LineEdit.text.is_valid_ip_address():
			alert_error(4)
			$VBoxContainer/LineEdit.text = "127.0.0.1"
			return
		join_game()
	elif number_entered == 1:
		if $VBoxContainer/LineEdit.text.length() == 0:
			$VBoxContainer/LineEdit.text = "1928"
			return
		if not $VBoxContainer/LineEdit.text.is_valid_integer():
			$VBoxContainer/LineEdit.text = "1928"
			alert_error(3)
			return
		player_port = int(tex)
		if Network.host:
			host_game()
			number_entered = 4
			return
		$VBoxContainer/Label.text = "IP:"
		$VBoxContainer/LineEdit.text = "127.0.0.1"
		$VBoxContainer/LineEdit.caret_position = "127.0.0.1".length()
	number_entered += 1

func join_game():
	Network.connect_to_server(player_ip, player_port)
	Network.own_name = player_name

func host_game():
	Network.create_server(player_port)
	Network.own_name = player_name
	get_tree().change_scene("res://Game/Game.tscn")


func _on_Button_pressed():
	set_val($VBoxContainer/LineEdit.text)

sync func start_game():
	Network.own_name = player_name
	get_tree().change_scene("res://Game/Game.tscn")


func alert_error(num):
	$AcceptDialog.dialog_text = error_codes[num]
	$AcceptDialog.popup_centered()
	reset_vals(number_entered)

func reset_vals(num):
	if num == 0:
		$VBoxContainer/Label.text = "Player Name:"
		$VBoxContainer/LineEdit.text = ""
	elif num == 1:
		$VBoxContainer/Label.text = "Port:"
		$VBoxContainer/LineEdit.text = "1928"
		$VBoxContainer/LineEdit.caret_position = "1928".length()
	elif num == 2:
		$VBoxContainer/Label.text = "IP:"
		$VBoxContainer/LineEdit.text = "127.0.0.1"
		$VBoxContainer/LineEdit.caret_position = "127.0.0.1".length()
