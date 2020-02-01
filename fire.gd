extends Node2D

var current_level = 1

signal fire_spreads_at_position(pos)
signal in_fire
signal out_of_fire

func _ready():
	get_node("Area2D").connect("body_enter",self,"_on_Area2D_body_enter")
	get_node("Area2D").connect("body_exit",self,"_on_Area2D_body_exit")

func spawn():
	$Timer.start(5)
	
func _on_Area2D_body_enter( body ):
	emit_signal("in_fire")

func _on_Area2D_body_exit( body ):
	emit_signal("out_of_fire")
	
