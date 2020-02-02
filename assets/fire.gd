extends StaticBody2D
var attached_utility = null;
func start():
	$sprite.play("On")
	$shape.disabled = false

func stop():
	$sprite.play("Off")
	$shape.disabled = true

func attach_to_utility(name):
	attached_utility = name

func _ready():
	stop()
