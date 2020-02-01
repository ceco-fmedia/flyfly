extends Node2D
const UTILITY_LIST = ['oxygen_scrubber', 'engine', 'lights', 'gravity_generator']
var oxygen_scrubber_state = {'level':null, 'health':null}
var can_use_scrubber = false


func _ready():
	self._subscribe_to_usage_signals()
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
	
func _subscribe_to_usage_signals():
	for utility in UTILITY_LIST:
		get_node(utility).connect("can_use_"+utility, self, "_infront_"+utility)
		get_node(utility).connect("cannot_use_"+utility, self, "_free_roam")
