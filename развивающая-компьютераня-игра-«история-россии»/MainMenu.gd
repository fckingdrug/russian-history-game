# res://MainMenu.gd
extends Control

var buttons = []
var hovered_button = null
var settings_panel = null

func _ready():

	var bg = TextureRect.new()
	bg.texture = preload("res://main_menu_bg.png")
	bg.stretch_mode = TextureRect.STRETCH_SCALE
	bg.custom_minimum_size = get_viewport_rect().size  
	bg.position = Vector2.ZERO
	add_child(bg)
	


	var title = Label.new()
	title.text = "ИСТОРИЯ РОССИИ"
	title.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 8)
	title.anchor_left = 0.5
	title.anchor_top = 0
	title.position = Vector2(0, 80)
	add_child(title)


	var button_texts = ["Начать игру", "Настройки", "Выйти"]
	var y_start = 250
	for i in range(button_texts.size()):
		var btn = Label.new()
		btn.text = button_texts[i]
		btn.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
		btn.add_theme_font_size_override("font_size", 28)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_outline_color", Color.BLACK)
		btn.add_theme_constant_override("outline_size", 8)
		btn.anchor_left = 0.5
		btn.position = Vector2(0, y_start + i * 60)
		btn.mouse_filter = Control.MOUSE_FILTER_STOP
		btn.connect("mouse_entered", Callable(self, "_on_button_mouse_enter").bind(btn))
		btn.connect("mouse_exited", Callable(self, "_on_button_mouse_exit").bind(btn))
		add_child(btn)
		buttons.append(btn)
		btn.gui_input.connect(_on_button_gui_input.bind(btn))

func _on_button_mouse_enter(button):
	hovered_button = button

func _on_button_mouse_exit(button):
	if hovered_button == button:
		hovered_button = null

func _process(_delta):
	for btn in buttons:
		var target_scale = Vector2(1.0, 1.0)
		var target_color = Color.WHITE
		
		if btn == hovered_button:
			target_scale = Vector2(1.15, 1.15)
			target_color = Color.YELLOW
		
		btn.scale = btn.scale.lerp(target_scale, min(8 * _delta, 1.0))
		btn.modulate = btn.modulate.lerp(target_color, min(8 * _delta, 1.0))

func _on_button_gui_input(event, button):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match button.text:
			"Начать игру":
				get_tree().change_scene_to_file("res://scene/world.tscn")
			"Настройки":
				if settings_panel:
					_hide_settings()
				else:
					_show_settings()
			"Выйти":
				get_tree().quit()

func _show_settings():
	settings_panel = Control.new()
	
	var size = Vector2(520, 300)
	var viewport_size = get_viewport_rect().size
	settings_panel.position = (viewport_size - size) / 2
	settings_panel.custom_minimum_size = size
	
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.85)
	bg.anchor_left = 0
	bg.anchor_top = 0
	bg.anchor_right = 1
	bg.anchor_bottom = 1
	settings_panel.add_child(bg)
	
	var label = Label.new()
	label.text = "Настройки пока не реализованы"
	label.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	label.anchor_left = 0
	label.anchor_top = 0
	label.anchor_right = 1
	label.anchor_bottom = 1
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	settings_panel.add_child(label)
	
	add_child(settings_panel)
	settings_panel.gui_input.connect(_on_settings_close)

func _hide_settings():
	if settings_panel:
		settings_panel.queue_free()
		settings_panel = null

func _on_settings_close(_event):
	_hide_settings()
