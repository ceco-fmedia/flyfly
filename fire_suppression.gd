extends Node2D
var current_level = 1
var attached_utility = null
signal can_use(current_level, health)
signal cannot_use

func _ready():
	pass
	
func attach_to_utility(utility):
	print('attached to ',utility)
	attached_utility = utility

func change_level(level):
	current_level = level
	$Anim.play("level_"+str(level))

func _on_Area2D_body_exited(_body):
	emit_signal("cannot_use")
	
func _on_Area2D_body_entered(_body):
	emit_signal("can_use")
