extends Node2D

@onready var label = $Label

func _ready():
	label.visible = false
	add_to_group("collectable")

func _process(_delta):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		label.visible = (dist <= 64)
	else:
		label.visible = false

func collect_item():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("add_item"):
		# Определяем тип предмета по имени или через export
		var item_type = name.to_lower()  # Например, "Stick" → "stick"
		player.add_item(item_type, 1)
	queue_free()
