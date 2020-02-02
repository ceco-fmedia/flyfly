extends Area2D
var current_level = 1
var attached_utility = null

func _ready():
	pass
	
func attach_to_utility(utility):
	print('attached to ',utility)
	attached_utility = utility

func change_level(level):
	current_level = level

func canUse(player):
	return overlaps_body(player)
