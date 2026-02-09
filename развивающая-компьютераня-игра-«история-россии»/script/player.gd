extends CharacterBody2D

@export var speed: float = 100.0
var idle_dir: Vector2 = Vector2.DOWN

@export var map_width: int = 3110
@export var map_height: int = 3110

@export var num_trees: int = 135
@export var num_iron_ores: int = 40
@export var num_coal_ores: int = 40
@export var num_sticks: int = 135
@export var num_stones: int = 135
@export var num_gold_veins: int = 20

const REGEN_TIME = 120.0
var regen_queue = []

var resources: Dictionary = {
	"stick": 0,
	"stone": 0,
	"axe": 0,
	"pickaxe": 0,
	"sword": 0,
	"log": 0,
	"iron_ore": 0,
	"coal": 0,
	"iron_ingot": 0,
	"icon": 0,
	"archbishop_staff": 0,
	"podvorye": 0,
	"gold": 0,              
	"crown": 0,             
	"dormition_cathedral": 0,
	"workbench": 0,
	"builder_workbench": 0
}

var ITEM_NAMES = {
	"stick": "Палка",
	"stone": "Камень",
	"axe": "Топор",
	"pickaxe": "Кирка",
	"sword": "Меч",
	"log": "Бревно",
	"iron_ore": "Железная руда",
	"coal": "Уголь",
	"iron_ingot": "Железный слиток",
	"icon": "Икона Спасителя",
	"archbishop_staff": "Архиерейский посох",
	"podvorye": "Архиерейское подворье",
	"gold": "Золото",       
	"crown": "Царская корона", 
	"dormition_cathedral": "Успенский собор",
	"workbench": "Верстак",
	"builder_workbench": "Строительный верстак"
}

signal inventory_changed
signal era_changed

@onready var anim = $AnimatedSprite2D

var is_craft_menu_open = false
var current_era = "stone_age"

var placing_building: PackedScene = null
var preview_building: Node2D = null

const PICKUP_RADIUS = 18
const CHOP_RADIUS = 40
const VIEWPORT_MARGIN = 200

var tree_scene = preload("res://scene/tree.tscn")
var iron_ore_scene = preload("res://iron_ore_deposit.tscn")
var coal_ore_scene = preload("res://coal_deposit.tscn")
var gold_ore_scene = preload("res://gold_ore_deposit.tscn") 
var collectable_scene = preload("res://scene/stick_collectable.tscn")

func _ready():
	add_to_group("player")
	global_position = Vector2(map_width / 2, map_height / 2)
	_generate_world()

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("up"): input_vector.y -= 1
	if Input.is_action_pressed("down"): input_vector.y += 1
	if Input.is_action_pressed("left"): input_vector.x -= 1
	if Input.is_action_pressed("right"): input_vector.x += 1

	if input_vector.length() > 0:
		input_vector = input_vector.normalized()
		idle_dir = input_vector
		play_move_animation(input_vector)
	else:
		play_idle_animation(idle_dir)

	velocity = input_vector * speed
	move_and_slide()

	var half_width = 16
	var half_height = 16
	global_position.x = clamp(global_position.x, half_width, map_width - half_width)
	global_position.y = clamp(global_position.y, half_height, map_height - half_height)

	self.z_index = min(int(global_position.y) + 1000, 4095)
	_update_regeneration()

func _process(_delta):
	if preview_building:
		preview_building.global_position = get_global_mouse_position()

func play_move_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		anim.play("Front")
		anim.flip_h = (dir.x < 0)
	elif dir.y < 0:
		anim.play("Up")
	else:
		anim.play("Down")

func play_idle_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		anim.play("Idle_front")
		anim.flip_h = (dir.x < 0)
	elif dir.y < 0:
		anim.play("Idle_up")
	else:
		anim.play("Idle_down")

func _generate_world():
	var world = get_tree().current_scene

	for i in range(num_trees):
		var obj = tree_scene.instantiate()
		obj.global_position = _get_random_point_on_map(50)
		obj.z_index = min(int(obj.global_position.y) + 1000, 4095)
		world.add_child.call_deferred(obj)

	for i in range(num_iron_ores):
		var obj = iron_ore_scene.instantiate()
		obj.global_position = _get_random_point_on_map(50)
		obj.z_index = min(int(obj.global_position.y) + 1000, 4095)
		world.add_child.call_deferred(obj)

	for i in range(num_coal_ores):
		var obj = coal_ore_scene.instantiate()
		obj.global_position = _get_random_point_on_map(50)
		obj.z_index = min(int(obj.global_position.y) + 1000, 4095)
		world.add_child.call_deferred(obj)

	for i in range(num_gold_veins):
		var obj = gold_ore_scene.instantiate()
		obj.global_position = _get_random_point_on_map(50)
		obj.z_index = min(int(obj.global_position.y) + 1000, 4095)
		world.add_child.call_deferred(obj)

	for i in range(num_sticks):
		var obj = collectable_scene.instantiate()
		obj.item_type = "stick"
		obj.global_position = _get_random_point_on_map(20)
		obj.z_index = min(int(obj.global_position.y) + 900, 4095)
		world.add_child.call_deferred(obj)

	for i in range(num_stones):
		var obj = collectable_scene.instantiate()
		obj.item_type = "stone"
		obj.global_position = _get_random_point_on_map(20)
		obj.z_index = min(int(obj.global_position.y) + 900, 4095)
		world.add_child.call_deferred(obj)

	print("Мир сгенерирован")

func _get_random_point_on_map(margin: int = 32) -> Vector2:
	return Vector2(
		randf_range(margin, map_width - margin),
		randf_range(margin, map_height - margin)
	)

func schedule_regen(item_type: String, pos: Vector2):
	regen_queue.append({
		"type": item_type,
		"pos": pos,
		"timer": REGEN_TIME
	})

func _update_regeneration():
	var i = regen_queue.size() - 1
	while i >= 0:
		var entry = regen_queue[i]
		entry.timer -= get_physics_process_delta_time()
		var is_visible = global_position.distance_to(entry.pos) < VIEWPORT_MARGIN
		if entry.timer <= 0 and not is_visible:
			_spawn_regen_object(entry.type, entry.pos)
			regen_queue.remove_at(i)
		i -= 1

func _spawn_regen_object(item_type: String, pos: Vector2):
	var world = get_tree().current_scene
	var obj = null
	
	match item_type:
		"tree":
			obj = tree_scene.instantiate()
			obj.z_index = min(int(pos.y) + 1000, 4095)
		"iron_ore":
			obj = iron_ore_scene.instantiate()
			obj.z_index = min(int(pos.y) + 1000, 4095)
		"coal_ore":
			obj = coal_ore_scene.instantiate()
			obj.z_index = min(int(pos.y) + 1000, 4095)
		"gold_ore":
			obj = gold_ore_scene.instantiate()
			obj.z_index = min(int(pos.y) + 1000, 4095)
		"stick", "stone":
			obj = collectable_scene.instantiate()
			obj.item_type = item_type
			obj.z_index = min(int(pos.y) + 900, 4095)
	
	if obj:
		obj.global_position = pos
		world.add_child.call_deferred(obj)

func _unhandled_input(event):
	if placing_building and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		if _is_position_free_strict(mouse_pos, get_tree().current_scene):
			_place_building_at(mouse_pos)
		else:
			print("Нельзя построить здесь!")
		return
	
	if event.is_action_pressed("interact"):
		collect_nearby_item()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
	
		var near_builder = _find_nearby("builder_workbench", 30)
		if near_builder:
			_try_interact_with_builder_workbench()
			return
	
		_try_chop_tree_at_mouse()
		_try_mine_ore_at_mouse()
		_try_interact_with_furnace()
		_try_interact_with_temple()
		_try_interact_with_podvorye()
		_try_interact_with_dormition_cathedral()
		_try_interact_with_workbench()
	
	if event.is_action_pressed("craft_menu"):
		show_craft_menu()

	if is_craft_menu_open:
		var near_furnace = _find_nearby("furnace", 50)
		if near_furnace and near_furnace.has_method("smelt_all_iron_ore"):
			if event.is_action_pressed("slot_1"):
				near_furnace.smelt_all_iron_ore()
				close_craft_menu()
				return
		
		if event.is_action_pressed("slot_1"): craft_by_index(0)
		if event.is_action_pressed("slot_2"): craft_by_index(1)
		if event.is_action_pressed("slot_3"): craft_by_index(2)
		if event.is_action_pressed("slot_4"): craft_by_index(3)

func _find_nearby(group_name: String, radius: float):
	var nodes = get_tree().get_nodes_in_group(group_name)
	for node in nodes:
		if global_position.distance_to(node.global_position) < radius:
			return node
	return null

func collect_nearby_item():
	for node in get_tree().get_nodes_in_group("collectable"):
		if node is Node2D and global_position.distance_to(node.global_position) <= PICKUP_RADIUS:
			add_resource(node.item_type, 1)
			schedule_regen(node.item_type, node.global_position)
			node.queue_free()
			return

func _try_chop_tree_at_mouse():
	if get_resource_count("axe") <= 0: return
	var mouse_pos = get_global_mouse_position()
	for tree in get_tree().get_nodes_in_group("choppable"):
		if tree.is_inside_tree() and global_position.distance_to(tree.global_position) <= CHOP_RADIUS and tree.global_position.distance_to(mouse_pos) < 30:
			if tree.has_method("on_hit"):
				tree.on_hit()
			return

func _try_mine_ore_at_mouse():
	if get_resource_count("pickaxe") <= 0: return
	var mouse_pos = get_global_mouse_position()
	for ore in get_tree().get_nodes_in_group("mineable"):
		if ore.is_inside_tree() and global_position.distance_to(ore.global_position) <= CHOP_RADIUS and ore.global_position.distance_to(mouse_pos) < 30:
			if ore.has_method("on_hit"):
				ore.on_hit()
			return

func _try_interact_with_furnace():
	var mouse_pos = get_global_mouse_position()
	for furnace in get_tree().get_nodes_in_group("furnace"):
		if furnace.is_inside_tree() and furnace.global_position.distance_to(mouse_pos) < 30:
			if furnace.has_method("on_interact"): furnace.on_interact()
			return

func _try_interact_with_temple():
	if current_era != "iron_age": 
		print(" Храм можно освятить только в Железном веке")
		return
	if get_resource_count("icon") <= 0: 
		print(" Нужна икона Спасителя!")
		return
	
	var mouse_pos = get_global_mouse_position()
	for temple in get_tree().get_nodes_in_group("temple"):
		if temple.is_inside_tree() and temple.global_position.distance_to(mouse_pos) < 30:
			remove_resource("icon", 1)
			current_era = "christian_rus"
			play_era_transition_sound()
			emit_signal("era_changed")
			print(" Икона освящена! Началась эпоха Христианской Руси.")
			return

func _try_interact_with_podvorye():
	if current_era != "christian_rus": 
		return
	if get_resource_count("archbishop_staff") <= 0: 
		print(" Нужен архиерейский посох!")
		return
	
	var mouse_pos = get_global_mouse_position()
	for podvorye in get_tree().get_nodes_in_group("podvorye"):
		if podvorye.is_inside_tree() and podvorye.global_position.distance_to(mouse_pos) < 30:
			remove_resource("archbishop_staff", 1)
			current_era = "sergii_radonezhsky"
			play_era_transition_sound()
			emit_signal("era_changed")
			print(" Митрополит Иона назначен! Церковь стала независимой.")
			return

func _try_interact_with_dormition_cathedral():
	if current_era != "sergii_radonezhsky":
		return
	if get_resource_count("crown") <= 0:
		print(" Нужна царская корона!")
		return
	
	var mouse_pos = get_global_mouse_position()
	for cathedral in get_tree().get_nodes_in_group("dormition_cathedral"):
		if cathedral.is_inside_tree() and cathedral.global_position.distance_to(mouse_pos) < 30:
			remove_resource("crown", 1)
			current_era = "post_coronation"
			play_era_transition_sound()
			emit_signal("era_changed")
			print(" Иван IV венчан на царство!")
			return

func _try_interact_with_workbench():
	var mouse_pos = get_global_mouse_position()
	for wb in get_tree().get_nodes_in_group("workbench"):
		if wb.is_inside_tree() and wb.global_position.distance_to(mouse_pos) < 30:
			if wb.has_method("on_interact"):
				wb.on_interact()
			return

func _try_interact_with_builder_workbench():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.show_craft_menu()

func add_resource(item: String, amount: int = 1):
	if not resources.has(item): return
	resources[item] += amount
	emit_signal("inventory_changed")
	_check_stone_age_completion()

func remove_resource(item: String, amount: int = 1) -> bool:
	if not resources.has(item) or resources[item] < amount: return false
	resources[item] -= amount
	emit_signal("inventory_changed")
	return true

func get_resource_count(item: String) -> int:
	return resources.get(item, 0)

func _place_building_at(pos: Vector2):
	var building = placing_building.instantiate()
	building.global_position = pos
	building.z_index = min(int(pos.y) + 1000, 4095)
	get_tree().current_scene.add_child.call_deferred(building)
	_finish_placing()

func _finish_placing():
	if preview_building:
		preview_building.queue_free()
		preview_building = null
	placing_building = null

func _is_position_free_strict(pos: Vector2, world_node: Node) -> bool:
	if pos.x < 40 or pos.x > map_width - 40 or pos.y < 40 or pos.y > map_height - 40:
		return false
	
	for child in world_node.get_children():
		if child is StaticBody2D and child != self:
			if pos.distance_to(child.global_position) < 45:
				return false
	
	return true

func show_craft_menu():
	var text = "=== КРАФТ ===\n"
	
	var near_workbench = _find_nearby("workbench", 50)
	var near_builder = _find_nearby("builder_workbench", 50)
	
	if near_builder:
		var recipes = [
			["Печь", "furnace", {"log": 5, "stone": 8}],
			["Храм", "temple", {"log": 10, "iron_ingot": 5}],
			["Архиерейское подворье", "podvorye", {"log": 15, "stone": 10}],
			["Успенский собор", "dormition_cathedral", {"log": 20, "stone": 20}]
		]
		text += "Строительный верстак\n"
		for i in range(min(recipes.size(), 4)):
			var r = recipes[i]
			var can = true
			for mat in r[2]:
				if get_resource_count(mat) < r[2][mat]: can = false
			text += "%d. %s — " % [i+1, r[0]]
			for mat in r[2]:
				text += "%s×%d " % [ITEM_NAMES.get(mat, mat), r[2][mat]]
			text += "(%s)\n" % ("✅" if can else "❌")
	
	elif near_workbench:
		var recipes = [
			["Икона Спасителя", "icon", {"log": 3}],
			["Архиерейский посох", "archbishop_staff", {"stick": 2, "iron_ingot": 1}],
			["Царская корона", "crown", {"gold": 5}],
			["Строительный верстак", "builder_workbench", {"log": 5, "stone": 6}]
		]
		text += "Верстак\n"
		for i in range(min(recipes.size(), 4)):
			var r = recipes[i]
			var can = true
			for mat in r[2]:
				if get_resource_count(mat) < r[2][mat]: can = false
			text += "%d. %s — " % [i+1, r[0]]
			for mat in r[2]:
				text += "%s×%d " % [ITEM_NAMES.get(mat, mat), r[2][mat]]
			text += "(%s)\n" % ("✅" if can else "❌")
	
	else:
		var recipes = [
			["Топор", "axe", {"stick": 2, "stone": 1}],
			["Кирка", "pickaxe", {"stick": 2, "stone": 2}],
			["Меч", "sword", {"stick": 1, "stone": 3}],
			["Верстак", "workbench", {"log": 4, "stone": 2}]
		]
		for i in range(recipes.size()):
			var r = recipes[i]
			var can = true
			for mat in r[2]:
				if get_resource_count(mat) < r[2][mat]: can = false
			text += "%d. %s — " % [i+1, r[0]]
			for mat in r[2]:
				text += "%s×%d " % [ITEM_NAMES.get(mat, mat), r[2][mat]]
			text += "(%s)\n" % ("✅" if can else "❌")
	
	text += "\nНажмите 1–4 для крафта"
	
	var ui = get_tree().get_first_node_in_group("craft_menu_ui")
	if ui and ui.has_method("display_menu"):
		ui.display_menu(text, false)
		is_craft_menu_open = true

func craft_by_index(i: int):
	var near_workbench = _find_nearby("workbench", 50)
	var near_builder = _find_nearby("builder_workbench", 50)
	
	var all_recipes = []
	
	if near_builder:
		all_recipes = [
			["furnace",{"log":5,"stone":8}],
			["temple",{"log":10,"iron_ingot":5}],
			["podvorye",{"log":15,"stone":10}],
			["dormition_cathedral",{"log":20,"stone":20}]
		]
	elif near_workbench:
		all_recipes = [
			["icon", {"log": 3}],
			["archbishop_staff", {"stick": 2, "iron_ingot": 1}],
			["crown", {"gold": 5}],
			["builder_workbench", {"log": 5, "stone": 6}]
		]
	else:
		all_recipes = [
			["axe", {"stick":2,"stone":1}],
			["pickaxe",{"stick":2,"stone":2}],
			["sword",{"stick":1,"stone":3}],
			["workbench",{"log":4,"stone":2}]
		]
	
	if i >= all_recipes.size(): return
	
	var item = all_recipes[i][0]
	var mats = all_recipes[i][1]
	
	for mat in mats:
		if get_resource_count(mat) < mats[mat]:
			print(" Недостаточно ", ITEM_NAMES.get(mat, mat))
			return
	
	for mat in mats:
		remove_resource(mat, mats[mat])
	
	var is_building = item in ["furnace", "temple", "podvorye", "dormition_cathedral", "workbench", "builder_workbench"]
	
	if is_building:
		if item == "furnace":
			placing_building = preload("res://furnace_object.tscn")
		elif item == "temple":
			placing_building = preload("res://temple_object.tscn")
		elif item == "podvorye":
			placing_building = preload("res://podvorye.tscn")
		elif item == "dormition_cathedral":
			placing_building = preload("res://dormition_cathedral.tscn")
		elif item == "workbench":
			placing_building = preload("res://workbench.tscn")
		elif item == "builder_workbench":
			placing_building = preload("res://builder_workbench.tscn")
		
		_start_placing_building()
	else:
		add_resource(item, 1)
	
	close_craft_menu()

func _start_placing_building():
	if not placing_building:
		return
	
	var original = placing_building.instantiate()
	
	var sprite = null
	if original.has_node("Sprite2D"):
		sprite = original.get_node("Sprite2D")
	elif original is Sprite2D:
		sprite = original
	else:
		for child in original.get_children(true):
			if child is Sprite2D:
				sprite = child
				break
	
	if not sprite or not sprite.texture:
		placing_building = null
		return
	
	preview_building = Sprite2D.new()
	preview_building.texture = sprite.texture
	preview_building.scale = sprite.scale
	preview_building.modulate = Color(1, 1, 1, 0.5)
	preview_building.z_index = 4095
	add_child(preview_building)
	
	original.queue_free()

func close_craft_menu():
	is_craft_menu_open = false
	var ui = get_tree().get_first_node_in_group("craft_menu_ui")
	if ui and ui.has_method("clear_menu"):
		ui.clear_menu()

func _check_stone_age_completion():
	if current_era == "stone_age" and get_resource_count("iron_ingot") > 0:
		current_era = "iron_age"
		play_era_transition_sound()
		emit_signal("era_changed")

func play_era_transition_sound():
	var sound = preload("res://sfx/era_sound.wav")
	var audio = AudioStreamPlayer2D.new()
	add_child(audio)
	audio.stream = sound
	audio.play()
	audio.finished.connect(audio.queue_free)
