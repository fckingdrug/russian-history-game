extends CanvasLayer

# Ссылки на узлы
var recipes_container: Control = null
var materials_label: Label = null
var craft_button: Button = null
var close_button: Button = null

var player = null
var selected_recipe = ""

func _ready():
	# Ищем узлы рекурсивно
	recipes_container = find_child("RecipesContainer", true, false)
	materials_label = find_child("MaterialsLabel", true, false)
	craft_button = find_child("CraftButton", true, false)
	close_button = find_child("CloseButton", true, false)
	
	# Если не нашли, пробуем найти по типам
	if not recipes_container:
		recipes_container = find_node_by_class(self, "GridContainer")
		if not recipes_container:
			recipes_container = find_node_by_class(self, "VBoxContainer")
		
	if not materials_label:
		materials_label = find_node_by_class(self, "Label")
		if not materials_label:
			materials_label = find_node_by_class(self, "RichTextLabel")

	if not craft_button:
		craft_button = find_node_by_class(self, "Button")
		# Пробуем найти кнопку с текстом "Скрафтить"
		if craft_button and craft_button.text != "Скрафтить":
			# Ищем другие кнопки
			var all_buttons = get_tree().get_nodes_in_group("craft_button")
			if all_buttons.size() > 0:
				craft_button = all_buttons[0]

	# Ищем игрока
	await get_tree().create_timer(0.1).timeout
	player = get_tree().get_first_node_in_group("player")
	
	# Скрываем окно при старте
	visible = false
	
	# Подключаем кнопки
	if close_button: 
		close_button.pressed.connect(toggle_window)
	else:
		print("⚠️ Кнопка закрытия не найдена")
		
	if craft_button: 
		craft_button.pressed.connect(_on_craft_pressed)
	else:
		print("⚠️ Кнопка крафта не найдена")

# Вспомогательная функция поиска по типу
func find_node_by_class(node: Node, class_str: String) -> Node:
	if node.is_class(class_str):
		return node
	for child in node.get_children():
		var found = find_node_by_class(child, class_str)
		if found: return found
	return null

func toggle_window():
	visible = !visible
	if visible:
		update_recipes()

func update_recipes():
	if not player: 
		print("❌ Игрок не найден для меню крафта")
		return
	if not recipes_container: 
		print("❌ Контейнер рецептов не найден")
		return
	
	# Очищаем старые кнопки
	for child in recipes_container.get_children():
		child.queue_free()
	
	# Проверяем, что у игрока есть система крафта
	if not player.crafting_system:
		print("❌ У игрока нет системы крафта")
		return
	
	# Получаем рецепты
	var system = player.crafting_system
	var recipes = system.get_available_recipes(player.inventory)
	
	for recipe_name in recipes:
		var btn = Button.new()
		var data = system.recipes[recipe_name]
		
		btn.text = data.name
		btn.custom_minimum_size = Vector2(0, 40)
		
		# Загрузка иконки
		if data.has("icon") and ResourceLoader.exists(data.icon):
			btn.icon = load(data.icon)
			btn.expand_icon = true
		
		btn.pressed.connect(func(): select_recipe(recipe_name))
		recipes_container.add_child(btn)
	
	if materials_label:
		materials_label.text = "Выберите предмет"
	
	if craft_button:
		craft_button.disabled = true

func select_recipe(recipe_name):
	selected_recipe = recipe_name
	
	if not player or not player.crafting_system:
		return
	
	var system = player.crafting_system
	var data = system.recipes[recipe_name]
	
	# Текст требований
	var text = data.name + "\n\nТребуется:\n"
	var can_afford = true
	
	for mat in data.materials:
		var count = data.materials[mat]
		var have = player.get_item_count(mat)
		text += "- " + mat + ": " + str(have) + "/" + str(count) + "\n"
		if have < count: 
			can_afford = false
	
	if materials_label:
		materials_label.text = text
	
	if craft_button:
		craft_button.disabled = !can_afford

func _on_craft_pressed():
	if selected_recipe and player:
		if player.craft_item(selected_recipe):
			update_recipes()
			select_recipe(selected_recipe)
