extends StaticBody2D

const INTERACTION_RADIUS = 30
@onready var label = $Label  

func _ready():
	add_to_group("temple")

func _process(_delta):
	_update_hover_label()

func _update_hover_label():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		label.visible = false
		return
	
	var dist = global_position.distance_to(player.global_position)
	var has_icon = player.get_resource_count("icon") > 0
	label.visible = (dist <= INTERACTION_RADIUS) and has_icon

func on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	if player.current_era != "iron_age":
		print("Храм можно освятить только в Железном веке")
		return
	
	if player.get_resource_count("icon") > 0:
		player.remove_resource("icon", 1)
		player.current_era = "christian_rus"
		player.play_era_transition_sound()
		player.emit_signal("era_changed")
		print("Икона освящена! Началась эпоха Христианской Руси.")
	else:
		print("Нужна икона Спасителя!")
