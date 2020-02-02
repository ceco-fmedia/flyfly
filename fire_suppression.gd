extends Area2D
var current_level = 1
var attached_utility = null
var DRAIN_SPEED = 300
var RESTORE_SPEED = 20


var health = 100
var draining = false

func _ready():
	pass
	
func attach_to_utility(utility):
	print('attached to ',utility)
	attached_utility = utility

func use():
	draining = true

func canUse(player):
	return health == 100 and overlaps_body(player)
func updatePosition():
	$Anim.position.y = (100 - health)
func _process(delta):
	if draining:
		health -= delta * DRAIN_SPEED
		if health <= 0:
			health = 0
			draining = false
		updatePosition()
	elif health < 100:
		health += delta * RESTORE_SPEED
		if health > 100:
			health = 100
		updatePosition()
