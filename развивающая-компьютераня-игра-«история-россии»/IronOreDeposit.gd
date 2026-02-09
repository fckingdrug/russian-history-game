extends StaticBody2D

const STONE_DROP = 5
const IRON_ORE_DROP = 6
const MAX_HEALTH = 3
const INTERACTION_RADIUS = 40

var health = MAX_HEALTH
var original_position: Vector2
var shake_timer: float = 0.0
var shake_intensity: float = 2.0

@onready var hit_sound = preload("res://sfx/stone_mine.wav")
@onready var label = $Label

func _ready():
	add_to_group("mineable")
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
	var has_pick = player.get_resource_count("pickaxe") > 0
	label.visible = (dist <= INTERACTION_RADIUS) and has_pick

func on_hit():
	if health <= 0:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player or player.get_resource_count("pickaxe") <= 0:
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
		mine()

func mine():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.add_resource("stone", STONE_DROP)
		player.add_resource("iron_ore", IRON_ORE_DROP)  
		print("Добыто: %d камней, %d железной руды" % [STONE_DROP, IRON_ORE_DROP])
	queue_free()
