extends CanvasLayer

@onready var label = $Label
var player_node: Node  # Используем Node вместо конкретного типа
var is_visible: bool = false

func _ready():
	# Ищем игрока разными способами
	player_node = get_tree().get_first_node_in_group("player")
	
	if not player_node:
		# Пробуем найти по имени
		player_node = get_tree().get_root().find_child("player", true, false)
	
	if not player_node:
		# Пробуем найти по типу скрипта
		var all_nodes = get_tree().get_nodes_in_group("")
		for node in all_nodes:
			if node.get_script() and "inventory" in node:
				player_node = node
				break
	
	label.visible = false
	
	if player_node:
		print("✅ Игрок найден для CraftingUI")
		# Подключаемся к сигналу, если он есть
		if player_node.has_signal("inventory_changed"):
			player_node.inventory_changed.connect(_on_inventory_changed)
	else:
		print("⚠️ Игрок не найден")

func _input(event):
	if event.is_action_pressed("craft_menu"):
		toggle_ui()
	
	# Обработка цифр для крафта при открытом меню
	if is_visible:
		if event.is_action_pressed("slot_1"):
			craft_recipe_by_index(0)
		if event.is_action_pressed("slot_2"):
			craft_recipe_by_index(1)
		if event.is_action_pressed("slot_3"):
			craft_recipe_by_index(2)
		if event.is_action_pressed("slot_4"):
			craft_recipe_by_index(3)
		if event.is_action_pressed("slot_5"):
			craft_recipe_by_index(4)

func toggle_ui():
	is_visible = !is_visible
	label.visible = is_visible
	
	if is_visible:
		update_display()
	else:
		label.text = ""

func craft_recipe_by_index(index: int):
	if not player_node:
		return
	
	# Получаем доступные рецепты
	if player_node.has_method("get_available_recipes"):
		var available_recipes = player_node.get_available_recipes()
		
		if index < available_recipes.size():
			var recipe_name = available_recipes[index]
			
			if player_node.has_method("craft_item"):
				player_node.craft_item(recipe_name)
				update_display()  # Обновляем UI после крафта

func update_display():
	if not player_node:
		label.text = "Игрок не найден"
		return
	
	var text = ""
	
	# Инвентарь
	if player_node.has_method("get_item_count"):
		text += "=== ИНВЕНТАРЬ ===\n\n"
		var items = ["stick", "stone", "axe", "pickaxe", "sword"]
		for item in items:
			var count = player_node.get_item_count(item)
			if count > 0:
				text += "  %s: %d\n" % [item, count]
	
	text += "\n=== РЕЦЕПТЫ ===\n\n"
	
	# Получаем рецепты
	if player_node.has_method("get_available_recipes"):
		var available_recipes = player_node.get_available_recipes()
		
		if available_recipes.size() > 0:
			for i in range(available_recipes.size()):
				var recipe_name = available_recipes[i]
				
				# Получаем систему крафта
				if player_node.has_method("get_crafting_system"):
					var crafting_system = player_node.get_crafting_system()
					
					if crafting_system and crafting_system.has_method("get_recipe"):
						var recipe = crafting_system.get_recipe(recipe_name)
						
						if recipe:
							text += "%d. %s " % [i + 1, recipe.name]
							
							# Проверяем можно ли скрафтить
							if player_node.has_method("can_craft"):
								var can_craft = player_node.can_craft(recipe_name)
								if can_craft:
									text += "✅\n"
								else:
									text += "❌\n"
							
							# Материалы
							if recipe.has("materials"):
								for material in recipe.materials:
									var needed = recipe.materials[material]
									
									if player_node.has_method("get_item_count"):
										var has = player_node.get_item_count(material)
										text += "    %s: %d/%d\n" % [material, has, needed]
						
						text += "\n"
		else:
			text += "Нет доступных рецептов\n"
	else:
		text += "Не удалось получить рецепты\n"
	
	text += "\n=== УПРАВЛЕНИЕ ===\n"
	text += "C - закрыть меню\n"
	text += "1-5 - крафт по номеру\n"
	
	label.text = text

func _on_inventory_changed(item_type: String, new_amount: int):
	if is_visible:
		update_display()

# Простая версия без зависимостей от Player класса
func refresh():
	if is_visible:
		update_display()
