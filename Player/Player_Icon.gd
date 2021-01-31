extends Area2D


func _process(delta):
	if get_overlapping_areas().size() > 0 and get_parent().name != "Player_1":
		$Outline.visible = true
	else:
		$Outline.visible = false
