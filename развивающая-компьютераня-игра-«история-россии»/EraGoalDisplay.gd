# res://EraGoalDisplay.gd
extends Control

signal menu_requested

@onready var label = $Label

const GOALS = {
	"stone_age": {
		"title": "Цель: Выплавить железный слиток в печи",
		"details": "Железный век на Руси начался около VIII века. Железо выплавляли из болотной руды в примитивных горнах. Оно было прочнее бронзы и позволяло создавать лучшие орудия труда и оружие, что способствовало развитию земледелия и ремёсел."
	},
	"iron_age": {
		"title": "Цель: Построить храм и освятить \n в нём икону Спасителя",
		"details": "988 год - крещение Руси князем Владимиром Святославичем. После принятия христианства как государственной религии началось массовое строительство храмов. Первый каменный храм - Десятинная церковь в Киеве - был заложен в 989 году. Иконы стали важнейшей частью богослужения и духовной жизни."
	},
	"christian_rus": {
		"title": "Цель: Создать архиерейский посох и назначить \n митрополита Иону в Архиерейском подворье",
		"details": "1448 год - поворотный момент в истории Русской церкви. Московский великий князь Василий II Тёмный и собор русских епископов избрали митрополитом Иону без согласия Константинопольского патриарха. Это событие означало обретение автокефалии (независимости) Русской церкви и укрепление власти Москвы как центра православного мира."
	},
	"sergii_radonezhsky": {
		"title": "Цель: Добыть золото, выковать царскую корону, \n построить Успенский собор и совершить венчание",
		"details": "1475–1479 гг. - строительство Успенского собора в Московском Кремле по приказу великого князя Ивана III. Великий князь пригласил итальянского зодчего Аристотеля Фиораванти, чтобы создать главный храм Руси, превосходящий по величию соборы других православных стран. Собор стал местом венчания на царство и погребения митрополитов и патриархов.\n\n16 января 1547 года в этом соборе митрополит Макарий возложил на Ивана IV Грозного царскую корону, провозгласив его первым царём всея Руси - акт, утвердивший преемственность от Византии («Третий Рим») и самодержавную власть."
	},
	"post_coronation": {
		"title": "Следующая цель готовится...",
		"details": "Игра завершена. Спасибо за прохождение!"
	}
}

func _ready():
	label.add_theme_font_override("font", preload("res://assets/fonts/pixel_font.ttf"))
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	
	label.anchor_left = 0.0
	label.anchor_bottom = 1.0
	label.offset_left = 10
	label.offset_bottom = -10
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("era_changed", Callable(self, "_on_era_changed"))
		_on_era_changed()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_viewport().get_mouse_position()
		var label_rect = Rect2(label.global_position, label.size)
		if label_rect.has_point(mouse_pos):
			var ui = get_tree().get_first_node_in_group("craft_menu_ui")
			if ui and ui.has_method("display_menu"):
				var player = get_tree().get_first_node_in_group("player")
				if player and GOALS.has(player.current_era):
					var note = GOALS[player.current_era].detail
					var full_text = "=== ИСТОРИЧЕСКАЯ ПАМЯТКА ===\n\n" + note
					ui.display_menu(full_text, true)

func _on_era_changed():
	var player = get_tree().get_first_node_in_group("player")
	if player and GOALS.has(player.current_era):
		label.text = GOALS[player.current_era].title
	else:
		label.text = "Цель: Неизвестно"

func show_historical_note():
	var player = get_tree().get_first_node_in_group("player")
	if not player or not GOALS.has(player.current_era):
		return
	var note = GOALS[player.current_era].details
	if note.strip() == "":
		return
	var ui = get_tree().get_first_node_in_group("craft_menu_ui")
	if ui and ui.has_method("display_menu"):
		ui.display_menu(note, true)
