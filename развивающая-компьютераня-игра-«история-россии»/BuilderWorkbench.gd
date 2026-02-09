extends StaticBody2D

const INTERACTION_RADIUS = 30
@onready var label = $Label  

func _ready():
	add_to_group("builder_workbench")

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		label.visible = (dist <= 30) and not player.is_craft_menu_open
	else:
		label.visible = false

func on_interact():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.show_craft_menu()
