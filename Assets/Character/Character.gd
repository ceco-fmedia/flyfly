extends KinematicBody2D
const LEFT = 1;
const RIGHT = 2;
const UP = 3;
const DOWN = 4;

export(float) var GRAVITY = 800.0
export(float) var GRAB_VELOCITY = 800
export(float) var GRAB_SLIDE_VELOCITY = 6000
export(float) var JUMP_FORCE = 600.0
export(float) var LAND_SIDE_SPEED = 200.0
export(float) var AIR_SIDE_ACCELERATION = 400.0
export(float) var ZEROG_MAX_VELOCITY = 30
# export(float) var ZEROG_CRAWL_VELOCITY = 60
export(float) var ZEROG_ACCELERATION = 30
export(float) var ZEROG_JUMP_VELOCITY = 250
signal action_pressed
var velocity = Vector2()
var landed = false
var grabbed = 0
var upVector = Vector2(0, -1)
var hasGravity = true
var grabLeftTime = 0

func wobble(maxRotation):
	$camera.wobble(maxRotation)

func shake(amount, duration = 0):
	$camera.shake(amount, duration)

func _physics_process(delta):
	var actionPressed = Input.is_action_just_pressed("ui_focus_next")
	if actionPressed:
		emit_signal("action_pressed")
		#TODO CEC refactor this however makes sense
	var leftPressed = Input.is_action_pressed("ui_left")
	var rightPressed = Input.is_action_pressed("ui_right")
	var upPressed = Input.is_action_pressed("ui_up")
	var jumpPressed = Input.is_action_just_pressed("ui_up")
	var downPressed = Input.is_action_pressed("ui_down")
	var anim = "Idle"
	if Input.is_action_just_pressed("ui_accept"):
		setGravity(!hasGravity)
	
	if hasGravity:
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
		if landed:
			if abs(velocity.x) > 20:
				anim = "MoveSide"
		elif grabbed:
			$sprite.set_flip_h(grabbed < 0)
			if downPressed:
				anim = "GrabSlideFast"
			else:
				anim = "GrabSlide"
		else:
			if abs(velocity.y) < 50:
				anim = "HighPoint"
			elif velocity.y < 0:
				anim = "Jump"
			else:
				anim = "Fall"
	else:
		if grabbed:
			var isJump = false
			if leftPressed:
				if grabbed == RIGHT:
					isJump = true
					grabbed = 0
					grabLeftTime = 0
				velocity.x = -1
			elif rightPressed:
				if grabbed == LEFT:
					isJump = true
					grabbed = 0
					grabLeftTime = 0
				velocity.x = 1
			
			if upPressed:
				if grabbed == DOWN:
					isJump = true
					grabbed = 0
					grabLeftTime = 0
				velocity.y = -1
			elif downPressed:
				if grabbed == UP:
					isJump = true
					grabbed = 0
					grabLeftTime = 0
				velocity.y = 1
			if isJump:
				velocity = (velocity * ZEROG_JUMP_VELOCITY).clamped(ZEROG_JUMP_VELOCITY)
				print(velocity)
			else:
				velocity *= 0
		else:
			if upPressed:
				velocity.y -= ZEROG_ACCELERATION * delta
				if velocity.y < -ZEROG_MAX_VELOCITY:
					velocity.y = -ZEROG_MAX_VELOCITY
			elif downPressed:
				if velocity.y < ZEROG_MAX_VELOCITY:
					velocity.y += ZEROG_ACCELERATION * delta
					if velocity.y > ZEROG_MAX_VELOCITY:
						velocity.y = ZEROG_MAX_VELOCITY
			if leftPressed:
				if velocity.x > -ZEROG_MAX_VELOCITY:
					velocity.x -= ZEROG_ACCELERATION * delta
					if velocity.x < -ZEROG_MAX_VELOCITY:
						velocity.x = -ZEROG_MAX_VELOCITY
			elif rightPressed:
				if velocity.x < ZEROG_MAX_VELOCITY:
					velocity.x += ZEROG_ACCELERATION * delta
					if velocity.x > ZEROG_MAX_VELOCITY:
						velocity.x = ZEROG_MAX_VELOCITY
			
			if velocity.x > ZEROG_MAX_VELOCITY and not leftPressed:
				velocity.x -= ZEROG_ACCELERATION * delta
			elif velocity.x < -ZEROG_MAX_VELOCITY and not rightPressed:
				velocity.x += ZEROG_ACCELERATION * delta
			if velocity.y > ZEROG_MAX_VELOCITY and not upPressed:
				velocity.y -= ZEROG_ACCELERATION * delta
			elif velocity.y < -ZEROG_MAX_VELOCITY and not downPressed:
				velocity.y += ZEROG_ACCELERATION * delta

		
		velocity = move_and_slide(velocity, upVector)

		var collisions = get_slide_count()
		if collisions:
			var normal = get_slide_collision(collisions - 1).normal
			if abs(normal.x) > abs(normal.y):
				if normal.x > 0:
					grabbed = LEFT
				else:
					grabbed = RIGHT
			else:
				if normal.y > 0:
					grabbed = UP
				else:
					grabbed = DOWN
			velocity.x = 0
			velocity.y = 0
			grabLeftTime = 0.2
		elif grabLeftTime > delta:
			grabLeftTime -= delta
		else:
			grabbed = 0
		
		if grabbed:
			anim = "Grab0G"
			if grabbed == LEFT:
				$sprite.rotation_degrees = 90
			elif grabbed == UP:
				$sprite.rotation_degrees = 180
			if grabbed == RIGHT:
				$sprite.rotation_degrees = 270
			elif grabbed == DOWN:
				$sprite.rotation_degrees = 0
		elif leftPressed || rightPressed || upPressed || downPressed:
			anim = "Swim"

			if upPressed:
				if leftPressed:
					$sprite.rotation_degrees = 315
				elif rightPressed:
					$sprite.rotation_degrees = 45
				else:
					$sprite.rotation_degrees = 0
			elif downPressed:
				if leftPressed:
					$sprite.rotation_degrees = 225
				elif rightPressed:
					$sprite.rotation_degrees = 135
				else:
					$sprite.rotation_degrees = 180
			elif leftPressed:
				$sprite.rotation_degrees = 270
			elif rightPressed:
				$sprite.rotation_degrees = 90
		else:
			anim = "Idle0G"
		$CollisionShape2D.rotation_degrees = $sprite.rotation_degrees
	
	
	$sprite.play(anim)

func setGravity(isOn):
	hasGravity = isOn
	if isOn:
		rotation = 0
	else:
		$sprite.set_flip_h(false)
