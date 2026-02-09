# res://scene/stick_collectable.gd
extends Node2D

@export var item_type: String = "stick"

var tooltip_label: Label = null

const SPRITES = {
	"stick": preload("res://assets/items/stick.png"),
	"stone": preload("res://assets/items/stone.png")
}

const TOOLTIP_TEXT = {
	"stick": "Е чтобы взять",
	"stone": "Е чтобы взять"
}

func _ready():
	add_to_group("collectable")
	
	if has_node("Sprite2D"):
		var sprite = $Sprite2D
		sprite.scale = Vector2(1.0, 1.0)
		
		if SPRITES.has(item_type):
			sprite.texture = SPRITES[item_type]
			sprite.scale = Vector2(0.5, 0.5)  
			sprite.rotation = randf_range(0, 2 * PI)
		else:
			print("⚠️ Неизвестный тип предмета: ", item_type)

func _process(_delta):
	_update_hover_label()

func _update_hover_label():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	if dist <= 18.0:
		if not tooltip_label:
			tooltip_label = Label.new()
			tooltip_label.text = TOOLTIP_TEXT.get(item_type, "Е чтобы взять")
			
	
			tooltip_label.add_theme_color_override("font_color", Color.WHITE)
			tooltip_label.add_theme_color_override("font_outline_color", Color.BLACK)
			tooltip_label.add_theme_constant_override("outline_size", 2)
			
			tooltip_label.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
			tooltip_label.add_theme_font_size_override("font_size", 5)
			tooltip_label.add_theme_color_override("font_color", Color.WHITE)
			tooltip_label.add_theme_color_override("font_outline_color", Color.BLACK)
			tooltip_label.add_theme_constant_override("outline_size", 4)
			
			tooltip_label.add_theme_font_size_override("font_size", 5)
			tooltip_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			tooltip_label.visible = true
			player.add_child(tooltip_label)
		
		tooltip_label.position = player.to_local(global_position) + Vector2(-32, -20)
	else:
		if tooltip_label:
			tooltip_label.queue_free()
			tooltip_label = null

func _exit_tree():
	if tooltip_label:
		tooltip_label.queue_free()
		tooltip_label = null
