extends Node2D

var current_level = 1

signal can_use_oxygen_scrubber(current_level, health)
signal cannot_use_oxygen_scrubber

func _ready():
	get_node("Area2D").connect("body_enter",self,"_on_Area2D_body_enter")
	get_node("Area2D").connect("body_exit",self,"_on_Area2D_body_exit")

func change_level(level):
	current_level = level
	$Anim.play("o2_level_"+str(level))
	
func _on_Area2D_body_enter( body ):
	emit_signal("can_use_oxygen_scrubber")

func _on_Area2D_body_exit( body ):
	emit_signal("cannot_use_oxygen_scrubber")
	
