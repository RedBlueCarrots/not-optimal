extends Spatial

var host = false

func _ready():
	pass

func _process(delta):
	if not $Control/Label.visible and not $Control/Options.visible:
		$Control/HBoxContainer.visible = true
		$Control/Label.visible = true


func _on_Host_pressed():
	Network.host = true
	$AnimationPlayer.play("To_Image")


func _on_Join_pressed():
	Network.host = false
	$AnimationPlayer.play("To_Image")


func _on_Exit_pressed():
	get_tree().quit()

func lobby_settings():
	get_tree().change_scene("res://Menus/Waiting_Room.tscn")


func _on_Options_pressed():
	$Control/HBoxContainer.visible = false
	$Control/Label.visible = false
	$Control/Options.visible = true
