extends StaticBody2D

const INTERACTION_RADIUS = 55
@onready var label = $Label  

func _ready():
	add_to_group("dormition_cathedral")

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		var has_crown = player.get_resource_count("crown") > 0
		label.visible = (dist <= INTERACTION_RADIUS) and has_crown
	else:
		label.visible = false

func on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if player.current_era != "sergii_radonezhsky": 
		print( "Венчание доступно только после строительства Успенского собора")
		return
	
	if player.get_resource_count("crown") > 0:
		player.remove_resource("crown", 1)
		player.current_era = "autoccephaly"
		player.play_era_transition_sound()
		player.emit_signal("era_changed")
		print("Иван IV венчан на царство!")
	else:
		print("Нужна царская корона!")
