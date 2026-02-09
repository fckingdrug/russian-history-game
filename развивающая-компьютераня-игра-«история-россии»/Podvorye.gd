extends StaticBody2D

const INTERACTION_RADIUS = 60
@onready var label = $Label  

func _ready():
	add_to_group("podvorye")

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		var has_staff = player.get_resource_count("archbishop_staff") > 0
		label.visible = (dist <= INTERACTION_RADIUS) and has_staff
	else:
		label.visible = false

func on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if player.get_resource_count("archbishop_staff") > 0:
		player.remove_resource("archbishop_staff", 1)
		player.current_era = "sergii_radonezhsky"
		player.play_era_transition_sound()
		player.emit_signal("era_changed")
		print("Митрополит Иона назначен! Церковь стала независимой.")
	else:
		print("Нужен архиерейский посох!")
