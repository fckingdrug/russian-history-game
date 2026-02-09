# sort.gd
extends Node2D

func _ready():
	set_process(true)

func _process(_delta):
	var children = get_children()
	children.sort_custom(Callable(self, "_sort_by_y"))
	
	for i in range(children.size()):
		children[i].z_index = i

func _sort_by_y(a, b):
	return a.position.y < b.position.y
