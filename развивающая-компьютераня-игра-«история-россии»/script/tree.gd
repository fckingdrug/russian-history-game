extends StaticBody2D

const MAX_HEALTH = 3
const LOGS_DROP = 6
const INTERACTION_RADIUS = 24

var health = MAX_HEALTH
var original_position: Vector2
var shake_timer: float = 0.0
var shake_intensity: float = 2.0

@onready var hit_sound = preload("res://sfx/wood_axe.wav")
@onready var label = $Label  

func _ready():
	add_to_group("choppable")
	original_position = global_position

func _process(delta):
	_update_hover_label()
	
	if shake_timer > 0:
		shake_timer -= delta
		var offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shake_intensity * (shake_timer / 0.2)
		global_position = original_position + offset
	else:
		global_position = original_position

func _update_hover_label():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		label.visible = false
		return
	
	var dist = global_position.distance_to(player.global_position)
	var has_axe = player.get_resource_count("axe") > 0
	label.visible = (dist <= INTERACTION_RADIUS) and has_axe

func on_hit():
	if health <= 0:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player or player.get_resource_count("axe") <= 0:
		return
	
	health -= 1
	shake_timer = 0.2
	
	if hit_sound:
		var audio = AudioStreamPlayer2D.new()
		audio.stream = hit_sound
		add_child(audio)
		audio.play()
		audio.finished.connect(audio.queue_free)
	
	if health <= 0:
		chop()

func chop():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_resource("log", LOGS_DROP)
		var sticks = randi_range(2, 5)
		player.add_resource("stick", sticks)
		print(" Дерево срублено! Получено %d бревна(ов) и %d палок" % [LOGS_DROP, sticks])
	queue_free()
