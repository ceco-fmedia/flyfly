extends Area2D

var current_level = 1

signal can_use(current_level, health)
signal cannot_use

func _ready():
	connect("body_enter",self,"_on_Area2D_body_enter")
	connect("body_exit",self,"_on_Area2D_body_exit")

func change_level(level):
	print("change level "+str(level))
	current_level = level
	$Anim.play("level_"+str(level))

func _on_Area2D_body_exited(body):
	print('exited_o2')
	emit_signal("cannot_use")
	
func _on_Area2D_body_entered(body):
	print('entered_o2')
	emit_signal("can_use")
