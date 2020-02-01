extends Node2D
const UTILITY_LIST = {'oxygen_scrubber':{'level':null, 'health':null},
					 'engine':{'level':null, 'health':null}, 
					'lights':{'level':null, 'health':null}, 
					'hull':{'level':null, 'health':null}, 
					'gravity_generator':{'level':null, 'health':null}}
const DEAD_IN_THE_WATER = 30
const STILL_GOOD = 50
const MINIMUM_REST_SECONDS = 3
const MINIMUM_HULL_BREACH_SECONDS = 2
const LASER_DMG = 20
const DEBRIS_DMG = 5
const DEBRIS_CHANCE = 50
const CRACKED_O2_TICKER = 25
var can_use_scrubber = false
var can_use_engine = false
var can_use_gravity_generator = false
var can_use_lights = false
var can_use_hull = false
var fire_list = []
var o2_instance = null
var hull_instance = null
var engine_instance = null
var lights_instance = null
var grav_instance = null
var player_instance = null
var seconds_since_last_break = 0
var seconds_since_hull_breach = 0


func _ready():
	self._subscribe_to_usage_signals()
	self._initilize_utilities()
	o2_instance = get_node("oxygen_scrubber")
	engine_instance = get_node("engine")
	lights_instance = get_node("lights")
	grav_instance = get_node("gravity_generator")
	player_instance = get_node("character")
	hull_instance = get_node("hull")
	$DirectorTimer.start()
	

func _process(_delta):
	pass

func _infront_oxygen_scrubber():
	can_use_scrubber = true
	
func _out_of_oxygen_scrubber():
	can_use_scrubber = false

func _infront_gravity_generator():
	can_use_gravity_generator = true
	
func _out_of_gravity_generator():
	can_use_gravity_generator = false
	
func _infront_engine():
	can_use_scrubber = true
	
func _out_of_engine():
	can_use_scrubber = false
	
func _infront_lights():
	can_use_lights = true
	
func _out_of_lights():
	can_use_lights = false
	
func _infront_hull():
	can_use_hull = true
	
func _out_of_hull():
	can_use_hull = false
	
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
	var chance = DEAD_IN_THE_WATER if UTILITY_LIST['engine']['level']==3 else STILL_GOOD
	var dice = randi()%100
	return dice > chance
	
func find_most_likely_to_crack():
	var most_likely_to_crack = null
	var most_distant = 0
	for utility in UTILITY_LIST:
		if utility == 'hull': continue # hull cracks on different logic
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
		get_node(most_likely_to_crack).change_level(2)
		seconds_since_last_break = 0
		return true
	else: 
		seconds_since_last_break += 1
		return false

func damage_to_hull():
	if seconds_since_hull_breach< MINIMUM_HULL_BREACH_SECONDS:
		seconds_since_hull_breach+=1
		return false
	var hull_hp = UTILITY_LIST['hull']['health']
	var laser_chance = DEAD_IN_THE_WATER if UTILITY_LIST['engine']['level']==2 else STILL_GOOD
	var dice = randi()%100
	var dmg = 0
	if dice > laser_chance:
		dmg = LASER_DMG
		print("hit_by_laser")
	elif randi()%100 > DEBRIS_CHANCE:
		dmg = DEBRIS_DMG
		print("hit_by_debris")
	if dmg:
		hull_hp -= dmg
		if hull_hp<=0:
			if UTILITY_LIST['hull']['level'] == 3:
				print("DEAD to HULL BREACH")
			else: 
				print("HULL BREACH level "+ str(UTILITY_LIST['hull']['level']))
				UTILITY_LIST['hull']['level'] += 1 
				hull_instance.change_level(UTILITY_LIST['hull']['level'])
				UTILITY_LIST['hull']['health'] = 100
		else:
			UTILITY_LIST['hull']['health'] = hull_hp
		seconds_since_hull_breach = 0 
		return true
	seconds_since_hull_breach += 1
	return false	
	
func o2_falling():
	print(UTILITY_LIST['oxygen_scrubber']['health'])
	if UTILITY_LIST['oxygen_scrubber']['level'] == 2:
		UTILITY_LIST['oxygen_scrubber']['health'] -= CRACKED_O2_TICKER
		if UTILITY_LIST['oxygen_scrubber']['health'] <= 0:
			UTILITY_LIST['oxygen_scrubber']['level'] = 3
			hull_instance.change_level(UTILITY_LIST['oxygen_scrubber']['level'])
			print("O2 needs parts")
			return true
	return false
		
			
		
		
	
	
	
func _on_DirectorTimer_timeout():
	var is_system_cracked = handle_cracking()
	var is_hull_hit = damage_to_hull()
	var cracked_o2 = o2_falling()
	
		

	

	
	
