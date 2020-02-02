extends Area2D

var current_level = 1

func _ready():
	pass

func change_level(level):
	if level != 2 or level<current_level:
		$Anim.play("level_"+str(level))
	current_level = level

func canUse(player):
	return overlaps_body(player)
func _on_Timer_timeout():
	print("wwwwww", self.name)
	if current_level == 2:
		
		$Timer.set_wait_time(randi()%10+1)
		if $Anim.animation == 'level_1':
			$Anim.play("level_2")
		elif $Anim.animation == 'level_2':
			$Anim.play("level_1")
