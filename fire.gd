extends Node2D

var current_level = 1

signal in_fire
signal out_of_fire

func _ready():
	pass

func spawn():
	print('spawn')
	self.visible = true


func set_pos(pos):
	self.position = pos

func _on_Area2D_body_entered(body):
	emit_signal("in_fire")


func _on_Area2D_body_exited(body):
	emit_signal("out_of_fire")
