extends Node2D
const UTILITY_LIST = {'oxygen_scrubber':{'level':null, 'health':null},
					 'engine':{'level':null, 'health':null}, 
					'lights':{'level':null, 'health':null}, 
					'gravity_generator':{'level':null, 'health':null}}
const DEAD_IN_THE_WATER = 50
const STILL_GOOD = 30
const MINIMUM_REST_SECONDS = 3
var can_use_scrubber = false
var can_use_engine = false
var can_use_gravity_generator = false
var can_use_lights = false
var fire_list = []
var o2_instance = null
var engine_instance = null
var lights_instance = null
var grav_instance = null
var player_instance = null
var seconds_since_last_break = 0


func _ready():
	self._subscribe_to_usage_signals()
	self._initilize_utilities()
	o2_instance = get_node("oxygen_scrubber")
	engine_instance = get_node("engine")
	lights_instance = get_node("lights")
	grav_instance = get_node("gravity_generator")
	player_instance = get_node("character")
	$DirectorTimer.start()
	


func _process(_delta):
	pass

func _infront_oxygen_scrubber():
	o2_instance.change_level(2)
	can_use_scrubber = true
	
func _out_of_oxygen_scrubber():
	o2_instance.change_level(1)
	can_use_scrubber = false

func _infront_gravity_generator():
	grav_instance.change_level(2)
	can_use_gravity_generator = true
	
func _out_of_gravity_generator():
	grav_instance.change_level(1)
	can_use_gravity_generator = false
	
func _infront_engine():
	can_use_scrubber = true
	engine_instance.change_level(2)
	
func _out_of_engine():
	can_use_scrubber = false
	engine_instance.change_level(1)
	
func _infront_lights():
	can_use_lights = true
	.change_level(2)
	
func _out_of_lights():
	can_use_lights = false
	lights_instance.change_level(1)
	
func _subscribe_to_usage_signals():
	for utility in UTILITY_LIST:
		get_node(utility).connect("can_use", self, "_infront_"+utility)
		get_node(utility).connect("cannot_use", self, "_out_of_"+utility)
		
func _initilize_utilities():
	for utility in UTILITY_LIST:
		UTILITY_LIST[utility] = {'level':1, 'health':100}	

func distance_from_player(utility):
	return get_node(utility).get_global_position().distance_to(player_instance.get_global_position())
	
func will_crack():
	if seconds_since_last_break<=MINIMUM_REST_SECONDS:
		return false
	var chance = DEAD_IN_THE_WATER if UTILITY_LIST['engine']['level']==2 else STILL_GOOD
	var dice = randi()%100
	return dice > chance
	
func find_most_likely_to_crack():
	var most_likely_to_crack = null
	var most_distant = 0
	for utility in UTILITY_LIST:
		if UTILITY_LIST[utility]['level'] == 1:
			var distance = distance_from_player(utility)
			if distance > most_distant:
				most_distant = distance
				most_likely_to_crack = utility
	return most_likely_to_crack

func handle_cracking():
	var most_likely_to_crack = find_most_likely_to_crack()
	if most_likely_to_crack and will_crack():
		print('cracked '+most_likely_to_crack)
		UTILITY_LIST[most_likely_to_crack]['level'] = 2
		seconds_since_last_break = 0
		return true
	else: 
		seconds_since_last_break += 1
		return false
	
func _on_DirectorTimer_timeout():
	var is_system_cracked = handle_cracking()
		
		

	

	
	
