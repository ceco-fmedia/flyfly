extends Area2D

var current_level = 1
var timeLeft = 0

func _ready():
	pass

func change_level(level):
	if level == 2:
		lvl2Animation()
	elif level<current_level:
		$Anim.play("level_"+str(level))
	current_level = level

func canUse(player):
	return overlaps_body(player)

func lvl2Animation():
	print("wwwwww", self.name)
	if current_level == 2:
		timeLeft = rand_range(1, 10)
		if $Anim.animation == 'level_1':
			$Anim.play("level_2")
		elif $Anim.animation == 'level_2':
			$Anim.play("level_1")

func _process(delta):
	if timeLeft > 0:
		timeLeft -= delta
		if timeLeft <= 0:
			timeLeft = 0
			lvl2Animation();
			
