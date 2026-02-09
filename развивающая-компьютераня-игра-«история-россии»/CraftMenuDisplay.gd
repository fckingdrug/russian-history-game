# res://CraftMenuDisplay.gd
extends CanvasLayer

@onready var label = $MenuLabel

var is_showing_info = false

func _ready():
	add_to_group("craft_menu_ui")
	visible = false
	if label:
		label.size.x = 400
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 2)
		
		label.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
		label.add_theme_font_size_override("font_size", 14)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
		label.add_theme_constant_override("outline_size", 4)
		set_process_input(false)
		

func display_menu(text: String, is_info: bool = false):
	if not label:
		return
	
	label.text = text
	visible = true
	is_showing_info = is_info
	set_process_input(true)  

func clear_menu():
	if not visible:
		return
	visible = false
	if label:
		label.text = ""
	is_showing_info = false
	set_process_input(false)  

func _input(event):
	if visible and event is InputEvent and event.is_pressed():
		clear_menu()
