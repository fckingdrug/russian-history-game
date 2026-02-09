# res://WorldGenerator.gd
extends Node

@export var tree_scene: PackedScene
@export var iron_ore_scene: PackedScene
@export var coal_ore_scene: PackedScene
@export var collectable_scene: PackedScene 

@export var map_size: Vector2 = Vector2(512, 512)  
@export var player_start_pos: Vector2 = Vector2(256, 256)

@export var num_trees: int = 30
@export var num_iron_deposits: int = 8
@export var num_coal_deposits: int = 6
@export var num_sticks: int = 20
@export var num_stones: int = 15

func generate():

	for child in get_children():
		if child != get_parent(): 
			child.queue_free()

	# Генерация деревьев
	for i in range(num_trees):
		var pos = _get_random_position_near_player(100, 400)
		var tree = tree_scene.instantiate()
		tree.global_position = pos
		add_child(tree)

	# Железо
	for i in range(num_iron_deposits):
		var pos = _get_random_position_near_player(150, 450)
		var ore = iron_ore_scene.instantiate()
		ore.global_position = pos
		add_child(ore)

	# Уголь
	for i in range(num_coal_deposits):
		var pos = _get_random_position_near_player(150, 450)
		var ore = coal_ore_scene.instantiate()
		ore.global_position = pos
		add_child(ore)

	# Палки
	for i in range(num_sticks):
		var pos = _get_random_position_near_player(50, 200)
		var stick = collectable_scene.instantiate()
		stick.item_type = "stick"
		stick.global_position = pos
		add_child(stick)

	# Камни
	for i in range(num_stones):
		var pos = _get_random_position_near_player(50, 200)
		var stone = collectable_scene.instantiate()
		stone.item_type = "stone"
		stone.global_position = pos
		add_child(stone)

	print("Мир сгенерирован!")


func _get_random_position_near_player(min_dist: float, max_dist: float) -> Vector2:
	var angle = randf() * 2 * PI
	var dist = randf_range(min_dist, max_dist)
	var offset = Vector2(cos(angle), sin(angle)) * dist
	return player_start_pos + offset
