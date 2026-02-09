# res://ResourceDisplay.gd
extends CanvasLayer

@onready var label = $ResourceLabel
var player = null

func _ready():
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(_on_inventory_changed)
		_update_label()
	else:
		label.text = "Игрок не найден"
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	
	label.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)

func _on_inventory_changed():
	_update_label()

func _update_label():
	if not player:
		label.text = "Игрок не найден"
		return
	
	var text = ""
	var items = player.resources.keys()
	for item in items:
		var count = player.get_resource_count(item)
		if count > 0:
			var display_name = player.ITEM_NAMES.get(item, item)
			text += "%s: %d\n" % [display_name, count]
	
	label.text = text if text != "" else "Инвентарь пуст"
