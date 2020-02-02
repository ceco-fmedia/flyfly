extends Area2D

var current_level = 1

func _ready():
	pass

func change_level(level):
	current_level = level
	$Anim.play("level_"+str(level))

func canUse(player):
	return overlaps_body(player)
func _on_Timer_timeout():
#	if current_level == 2:
#
#		if not $Anim.is_playing():
#			print("stop anim")
#			$Anim.play()
#		else:
#			$Anim.stop()
	pass
