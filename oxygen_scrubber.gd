extends Area2D

var current_level = 1

signal can_use(current_level, health)
signal cannot_use

func _ready():
	pass

func change_level(level):
	current_level = level
	$Anim.play("level_"+str(level))

func _on_Area2D_body_exited(_body):
	emit_signal("cannot_use")
	
func _on_Area2D_body_entered(_body):
	emit_signal("can_use")
