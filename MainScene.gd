extends Node2D
var FireScene = preload("fire.tscn")
const UTILITY_LIST = {'oxygen_scrubber':{'level':null, 'health':null},
					 'engine':{'level':null, 'health':null}, 
					'lights':{'level':null, 'health':null}, 
					'hull':{'level':null, 'health':null}, 
					'hull2':{'level':null, 'health':null}, 
					'gravity_generator':{'level':null, 'health':null}}
const DEAD_IN_THE_WATER = 30
const STILL_GOOD = 50
const MINIMUM_REST_SECONDS = 3
const MINIMUM_HULL_BREACH_SECONDS = 2
const LASER_DMG = 20
const DEBRIS_DMG = 5
const DEBRIS_CHANCE = 50
const CRACKED_O2_TICKER = 5
const CRACKED_LIGHT_TICKER = 5
const CRACKED_GRAV_TICKER = 5
const CRACKED_ENGINE_TICKER = 5
const MAX_WOBBLE = 10
const FIX_PER_ACTION = 25
const ALARM_TRESHOLD = 80
var can_use_scrubber = false
var can_use_engine = false
var can_use_gravity_generator = false
var can_use_lights = false
var can_use_hull = false
var can_use_hull2 = false
var fire_list = []
var o2_instance = null
var hull_instance = null
var hull2_instance = null
var engine_instance = null
var lights_instance = null
var grav_instance = null
var player_instance = null
var seconds_since_last_break = 0
var seconds_since_hull_breach = 0
var fire_sup1 = null
var fire_sup2 = null
var fire_sup3 = null
var fire_sup4 = null
var can_use_fire_sup1 = false
var can_use_fire_sup2 = false
var can_use_fire_sup3 = false
var can_use_fire_sup4 = false

func reset_usage():
	can_use_scrubber = false
	can_use_engine = false
	can_use_gravity_generator = false
	can_use_lights = false
	can_use_hull = false
	can_use_hull2 = false
	can_use_fire_sup1 = false
	can_use_fire_sup2 = false
	can_use_fire_sup3 = false
	can_use_fire_sup4 = false

	
func _ready():
	self._initilize_utilities()
	o2_instance = get_node("oxygen_scrubber")
	engine_instance = get_node("engine")
	lights_instance = get_node("lights")
	grav_instance = get_node("gravity_generator")
	player_instance = get_node("character")
	hull_instance = get_node("hull")
	hull2_instance = get_node("hull2")
	fire_sup1 = get_node("fire_suppression1")
	fire_sup1.attach_to_utility("oxygen_scrubber")
	fire_sup2 = get_node("fire_suppression2")
	fire_sup2.attach_to_utility("engine")
	fire_sup3 = get_node("fire_suppression3")
	fire_sup3.attach_to_utility("lights")
	fire_sup4 = get_node("fire_suppression4")
	fire_sup4.attach_to_utility("gravity_generator")
	get_node("character").connect("action_pressed", self, "player_action")
	$DirectorTimer.start()

func player_action():
	if action_suppression():
		return true
	elif action_fix():
		return true
	return false
	
func action_fix():
	if engine_instance.canUse(player_instance):
		fix_utility("engine")
		return true
	elif grav_instance.canUse(player_instance):
		fix_utility("gravity_generator")
		return true
	elif hull_instance.canUse(player_instance):
		fix_utility("hull")
		return true
	elif hull2_instance.canUse(player_instance):
		fix_utility("hull2")
		return true
	elif lights_instance.canUse(player_instance):
		fix_utility("lights")
		return true
	elif o2_instance.canUse(player_instance):
		fix_utility("oxygen_scrubber")
		return true
	return false
	
func fix_utility(utility):
	print("fix "+utility)
	if UTILITY_LIST[utility]['level']>1 and UTILITY_LIST[utility]['health']<100:
		UTILITY_LIST[utility]['health']+=FIX_PER_ACTION
		if UTILITY_LIST[utility]['health']>=100:
			seconds_since_last_break = 0
			seconds_since_hull_breach = 0
			UTILITY_LIST[utility]['health'] = 100
			UTILITY_LIST[utility]['level']-=1
			var node = get_node(utility)
			node.change_level(UTILITY_LIST[utility]['level'])
			node.get_node("HP").visible = true
			restore_env(utility)
			
			
func action_suppression():
	var utility = null
	if fire_sup1.canUse(player_instance):
		utility = fire_sup1.attached_utility
		fire_sup1.use()
		print(utility)
	elif fire_sup2.canUse(player_instance):
		print(utility)
		utility = fire_sup2.attached_utility
		fire_sup2.use()
	elif fire_sup3.canUse(player_instance):
		print(utility)
		utility = fire_sup3.attached_utility
		fire_sup3.use()
	elif fire_sup4.canUse(player_instance):
		print(utility)
		utility = fire_sup4.attached_utility
		fire_sup4.use()
	if utility:
		for fire in fire_list:
			if fire.attached_utility == utility:
				var pos = fire_list.find_last(fire)
				fire_list.remove(pos)
				fire.queue_free()
				print(fire_list)
	return false

func _process(_delta):
	for utility in ['oxygen_scrubber','gravity_generator','lights', 'engine']:
		var node = get_node(utility)
		if node.has_node("HP"):
			if UTILITY_LIST[utility]['level'] == 2:
				if node.has_node("HP"):
					node.get_node("HP").scale.x = UTILITY_LIST[utility]['health']/100.0
			elif UTILITY_LIST[utility]['level'] == 3:
				node.get_node("HP").visible = false
			
	for utility in ['hull', 'hull2']:
		var node = get_node(utility)
		if node.has_node("HP"):
			var actual_hp = 100*(3-UTILITY_LIST[utility]['level'])/3
			actual_hp += UTILITY_LIST[utility]["health"]/3
			node.get_node("HP").scale.x = actual_hp/100.0
	run_alarms()
			
func restore_env(utility):
	if utility == 'gravity_generrator':
		restore_gravity()
	elif utility == 'oxygen_scrubber':
		restore_o2()

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
		if utility in ['hull', 'hull2']: continue # hull cracks on different logic
		if UTILITY_LIST[utility]['level'] == 1:
			var distance = distance_from_player(utility)
			if distance > most_distant:
				most_distant = distance
				most_likely_to_crack = utility
	return most_likely_to_crack

func handle_cracking():
	var most_likely_to_crack = find_most_likely_to_crack()
	if most_likely_to_crack and will_crack():

		utility_cracked_fx()
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
	var pick_hull = randi()%10<5
	var which_hull = 'hull' if pick_hull else 'hull2'
	var which_inst = hull_instance if pick_hull else hull2_instance
	var hull_hp = UTILITY_LIST[which_hull]['health']
	var laser_chance = DEAD_IN_THE_WATER if UTILITY_LIST['engine']['level']==2 else STILL_GOOD
	var dice = randi()%100
	var dmg = 0
	if dice > laser_chance:
		dmg = LASER_DMG
		hit_by_laser_fx()
		print("hit_by_laser")
	elif randi()%100 > DEBRIS_CHANCE:
		dmg = DEBRIS_DMG
#		print("hit_by_debris")
		hit_by_debris_fx()
		
	if dmg:
		hull_hp -= dmg
		if hull_hp<=0:
			if UTILITY_LIST[which_hull]['level'] == 3:
				print("DEAD to "+which_hull+" BREACH")
			else: 
				print(which_hull + " BREACH level "+ str(UTILITY_LIST[which_hull]['level']))
				UTILITY_LIST[which_hull]['level'] += 1 
				which_inst.change_level(UTILITY_LIST[which_hull]['level'])
				UTILITY_LIST[which_hull]['health'] = 100
		else:
			UTILITY_LIST[which_hull]['health'] = hull_hp
		seconds_since_hull_breach = 0 
		return true
	seconds_since_hull_breach += 1
	return false	
	
func o2_falling():
	if UTILITY_LIST['oxygen_scrubber']['level'] > 1:
		var wobble = int((100 - UTILITY_LIST['oxygen_scrubber']['health'])/3)
		player_instance.wobble(wobble if wobble < MAX_WOBBLE else MAX_WOBBLE)
		UTILITY_LIST['oxygen_scrubber']['health'] -= CRACKED_O2_TICKER
		
		if UTILITY_LIST['oxygen_scrubber']['health'] <= 0:
			if UTILITY_LIST['oxygen_scrubber']['level'] == 2:
				UTILITY_LIST['oxygen_scrubber']['level'] = 3
				UTILITY_LIST['oxygen_scrubber']['health'] = 100
				o2_instance.change_level(UTILITY_LIST['oxygen_scrubber']['level'])
				spawn_fire_on_utility("oxygen_scrubber")
				print("O2 needs parts")
				return true
			else: 
				print("death by oxygen deprevation")
	return false
	
func engine_damage():
	if UTILITY_LIST['engine']['level'] == 2:
		UTILITY_LIST['engine']['health'] -= CRACKED_O2_TICKER
		if UTILITY_LIST['engine']['health'] <= 0:
			UTILITY_LIST['engine']['level'] = 3
			engine_instance.change_level(UTILITY_LIST['engine']['level'])
			spawn_fire_on_utility("engine")
			print("engine needs parts")
			return true
	return false
	
func blow_circuit():
	if UTILITY_LIST['lights']['level'] == 2:
		UTILITY_LIST['lights']['health'] -= CRACKED_O2_TICKER
		if UTILITY_LIST['lights']['health'] <= 0:
			UTILITY_LIST['lights']['level'] = 3
			lights_instance.change_level(UTILITY_LIST['lights']['level'])
			spawn_fire_on_utility("lights")
			print("lights needs parts")
			return true
	return false
	
func gravity_malfunction():
	if UTILITY_LIST['gravity_generator']['level'] == 2:
		UTILITY_LIST['gravity_generator']['health'] -= CRACKED_GRAV_TICKER
		if UTILITY_LIST['gravity_generator']['health'] <= 0:
			UTILITY_LIST['gravity_generator']['level'] = 3
			
			grav_instance.change_level(UTILITY_LIST['gravity_generator']['level'])
			spawn_fire_on_utility("gravity_generator")
			print("gravity_generator needs parts")
			
			lose_gravity()
			return true
	return false
		
func hit_by_debris_fx():
	player_instance.shake(1,1)

func hit_by_laser_fx():
	player_instance.shake(2,1)
	
func utility_cracked_fx():
	player_instance.shake(5,1)
	
func lose_gravity():
	player_instance.hasGravity = false
	
func restore_gravity():
	player_instance.hasGravity = true

func restore_o2():
	player_instance.wobble(0)
		
func spawn_fire_on_utility(utility):
	var fire_pos = get_node(utility).position
	var fire = FireScene.instance()
	add_child(fire)
	fire_list.append(fire)
	fire.position = fire_pos
	fire.attach_to_utility(utility)

func _on_DirectorTimer_timeout():
	var _is_system_cracked = handle_cracking()
	var _is_hull_hit = damage_to_hull()
	var _cracked_o2 = o2_falling()
	var _cracked_engine = engine_damage()
	var _cracked_grav = gravity_malfunction()
	var _cracked_lights = blow_circuit()
	
func should_run_alarm(utility):
	return (UTILITY_LIST[utility]['level']==2 and UTILITY_LIST[utility]['health']< ALARM_TRESHOLD) or UTILITY_LIST[utility]['level']>2	
func run_alarms():
	if should_run_alarm('engine'):
		get_node("Alarm_E").start_alarm()
	else:
		get_node("Alarm_E").stop_alarm()
	if should_run_alarm('lights'):
		get_node("Alarm_L").start_alarm()
	else:
		get_node("Alarm_L").stop_alarm()
	if should_run_alarm('hull'):
		get_node("Alarm_H1").start_alarm()
	else:
		get_node("Alarm_H1").stop_alarm()
	if should_run_alarm('hull2'):
		get_node("Alarm_H2").start_alarm()
	else:
		get_node("Alarm_H2").stop_alarm()
	if should_run_alarm('oxygen_scrubber'):
		get_node("Alarm_O2").start_alarm()
	else:
		get_node("Alarm_O2").stop_alarm()
	if should_run_alarm('gravity_generator'):
		get_node("Alarm_G").start_alarm()
	else:
		get_node("Alarm_G").stop_alarm()
		
		
