extends Node2D
var Fire = preload("res://fire.tscn")
const UTILITY_LIST = ['oxygen_scrubber', 'engine', 'lights', 'gravity_generator']
var oxygen_scrubber_state = {'level':null, 'health':null}
var engine_state = {'level':null, 'health':null}
var lights_state = {'level':null, 'health':null}
var gravity_generator_state = {'level':null, 'health':null}
var can_use_scrubber = false
var fire_list = []


func _ready():
	self._subscribe_to_usage_signals()
	self._initilize_utilities()


func _process(delta):
	
	if can_use_scrubber:
		get_node("oxygen_scrubber").change_level(1)
	else:
		get_node("oxygen_scrubber").change_level(2)
	

func _infront_oxygen_scrubber():
	can_use_scrubber = true
	
func _infront_engine():
	can_use_scrubber = true
	
func _infront_lights():
	can_use_scrubber = true
	
func _infront_gravity_generator():
	can_use_scrubber = true
	
func free_roam():
	can_use_scrubber = false
	
func _subscribe_to_usage_signals():
	for utility in UTILITY_LIST:
		get_node(utility).connect("can_use_"+utility, self, "_infront_"+utility)
		get_node(utility).connect("cannot_use_"+utility, self, "_free_roam")
		
func _initilize_utilities():
	oxygen_scrubber_state = {'level':1, 'health':100}
	engine_state = {'level':1, 'health':100}
	lights_state = {'level':1, 'health':100}
	gravity_generator_state = {'level':1, 'health':100}
		
func _spawn_fire_at_position(pos):
	var fire = Fire.instance()
	fire.set_pos(pos)
	fire_list.append(fire)
