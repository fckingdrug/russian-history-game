extends StaticBody2D

const INTERACTION_RADIUS = 30
@onready var label = $Label  

func _ready():
	add_to_group("furnace")

func _process(_delta):
	_update_hover_label()

func _update_hover_label():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		label.visible = false
		return
	
	var dist = global_position.distance_to(player.global_position)
	label.visible = (dist <= INTERACTION_RADIUS)

func on_interact():
	_show_smelt_menu()

func _show_smelt_menu():
	var text = "=== ПЛАВКА ===\n"
	text += "1. Переплавить железную руду → железный слиток\n"
	text += "\nНажмите 1 для плавки"
	
	var menu_ui = get_tree().get_first_node_in_group("craft_menu_ui")
	if menu_ui and menu_ui.has_method("display_menu"):
		menu_ui.display_menu(text, false)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_craft_menu_open = true

func smelt_all_iron_ore():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var ore_count = player.get_resource_count("iron_ore")
	var coal_count = player.get_resource_count("coal")
	
	if ore_count <= 0:
		print("Нет железной руды для плавки!")
		return
	
	if coal_count <= 0:
		print("Нет угля! Нужен уголь для плавки.")
		return
	
	var max_smeltable = min(ore_count, coal_count)
	player.remove_resource("iron_ore", max_smeltable)
	player.remove_resource("coal", max_smeltable)
	player.add_resource("iron_ingot", max_smeltable)
	
	print("Переплавлено %d руды и %d угля → %d слитков!" % [max_smeltable, max_smeltable, max_smeltable])
