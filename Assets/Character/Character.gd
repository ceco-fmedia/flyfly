extends KinematicBody2D

export(float) var GRAVITY = 800.0
export(float) var GRAB_VELOCITY = 800
export(float) var GRAB_SLIDE_VELOCITY = 6000
export(float) var JUMP_FORCE = 600.0
export(float) var LAND_SIDE_SPEED = 200.0
export(float) var AIR_SIDE_ACCELERATION = 400.0

var velocity = Vector2()
var landed = false
var grabbed = 0
var upVector = Vector2(0, -1)

func _physics_process(delta):
	var leftPressed = Input.is_action_pressed("ui_left")
	var rightPressed = Input.is_action_pressed("ui_right")
	var jumpPressed = Input.is_action_just_pressed("ui_up")
	var downPressed = Input.is_action_pressed("ui_down")
	
	if grabbed:
		if downPressed:
			velocity.y = GRAB_SLIDE_VELOCITY * delta
		else:
			velocity.y = GRAB_VELOCITY * delta
	else:
		velocity.y += GRAVITY * delta
	if landed:
		if jumpPressed:
			velocity.y = -JUMP_FORCE
		if leftPressed:
			velocity.x = -LAND_SIDE_SPEED
		elif rightPressed:
			velocity.x = LAND_SIDE_SPEED
		else:
			velocity.x = 0;
	elif grabbed and jumpPressed:
		velocity.y = -JUMP_FORCE / 2
		velocity.x = JUMP_FORCE * grabbed / 2
		grabbed = 0
	elif grabbed and not (leftPressed or rightPressed):
		print("fake wall grab")
		velocity.x -= grabbed
	else:
		if leftPressed:
			if velocity.x - AIR_SIDE_ACCELERATION > -LAND_SIDE_SPEED:
				velocity.x -= AIR_SIDE_ACCELERATION * delta
			else:
				velocity.x = -LAND_SIDE_SPEED
		elif rightPressed:
			if velocity.x + AIR_SIDE_ACCELERATION < LAND_SIDE_SPEED:
				velocity.x += AIR_SIDE_ACCELERATION * delta
			else:
				velocity.x = LAND_SIDE_SPEED
	
	velocity = move_and_slide(velocity, upVector, true)
	landed = is_on_floor()
	if not landed and is_on_wall():
		for i in range(get_slide_count()):
			var collision = get_slide_collision(i)
			if collision.normal.x > 0:
				grabbed = 1
				break
			elif collision.normal.x < 0:
				grabbed = -1
				break
	else:
		grabbed = 0
	$sprite.set_flip_h(velocity.x >= 0)
	var anim = "Idle"
	if landed:
		if velocity.y < 0:
			velocity.y = 0
		if abs(velocity.x) > 20:
			anim = "MoveSide"
	else:
		if abs(velocity.y) < 50:
			anim = "HighPoint"
		elif velocity.y < 0:
			anim = "Jump"
		else:
			anim = "Fall"
	$sprite.play(anim)

