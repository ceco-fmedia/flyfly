extends Node2D

var oxygen_scrubber_state = {'level':null, 'health':null}
var can_use_scrubber = false


func _ready():
	get_node("oxygen_scrubber").connect("can_use_oxygen_scrubber", self, "_infront_oxygen_scrubber")
	get_node("oxygen_scrubber").connect("cannot_use_oxygen_scrubber", self, "_free_roam")
	oxygen_scrubber_state['level'] = 1
	oxygen_scrubber_state['health'] = 100


func _process(delta):
	
	if can_use_scrubber:
		get_node("oxygen_scrubber").change_level(1)
	else:
		get_node("oxygen_scrubber").change_level(2)
	

func _infront_oxygen_scrubber():
	can_use_scrubber = true
	
func free_roam():
	can_use_scrubber = false
