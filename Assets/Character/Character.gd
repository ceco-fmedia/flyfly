extends KinematicBody2D
const LEFT = 1;
const RIGHT = 2;
const UP = 3;
const DOWN = 4;

export(float) var GRAVITY = 1500.0
export(float) var GRAB_VELOCITY = 100
export(float) var GRAB_SLIDE_VELOCITY = 700
export(float) var JUMP_FORCE = 900.0
export(float) var LAND_SIDE_SPEED = 600.0
export(float) var AIR_SIDE_ACCELERATION = 1000.0
export(float) var ZEROG_MAX_VELOCITY = 30
export(float) var ZEROG_ACCELERATION = 30
export(float) var ZEROG_JUMP_VELOCITY = 250
var ZEROG_JUMP_DIAGONAL_VELOCITY = 0.0
var JUMP_DIAGONAL_VELOCITY = 0.0
signal action_pressed
var velocity = Vector2()
var upVector = Vector2(0, -1)
var hitAnimations = ["Hit0G", "Hit1", "Hit2", "Hit3"]
var landed = false
var grabbed = 0
var hasGravity = true
var grabLeftTime = 0
var hitting = false

func wobble(maxRotation):
	$camera.wobble(maxRotation)

func shake(amount, duration = 0):
	$camera.shake(amount, duration)

func rotateChildren(degrees):
	$sprite.rotation_degrees = degrees
	$CollisionShape2D.rotation_degrees = degrees

func _physics_process(delta):
	var actionPressed = Input.is_action_just_pressed("ui_select")
	var leftPressed = Input.is_action_pressed("ui_left")
	var rightPressed = Input.is_action_pressed("ui_right")
	var upPressed = Input.is_action_pressed("ui_up")
	var jumpPressed = Input.is_action_just_pressed("ui_up")
	var downPressed = Input.is_action_pressed("ui_down")
	var currentAnim = $sprite.animation
	var anim = "Idle"
	if hitting:
		anim = currentAnim
	if Input.is_action_just_pressed("ui_accept"):
		setGravity(!hasGravity)
	
	if hasGravity:
		if grabbed:
			if downPressed:
				velocity.y = GRAB_SLIDE_VELOCITY
			else:
				velocity.y = GRAB_VELOCITY
		else:
			velocity.y += GRAVITY * delta
		if landed:
			if actionPressed:
				velocity.x = 0
				velocity.y = 10
				if not hitting:
					hitting = true
					anim = hitAnimations[1 + randi() % 3]
			else:
				if jumpPressed:
					velocity.y = -JUMP_FORCE
					anim = "JumpStart"
					currentAnim = anim
				if leftPressed:
					velocity.x = -LAND_SIDE_SPEED
				elif rightPressed:
					velocity.x = LAND_SIDE_SPEED
				else:
					velocity.x = 0;
		elif grabbed and jumpPressed:
			velocity.y = -JUMP_DIAGONAL_VELOCITY
			velocity.x = JUMP_DIAGONAL_VELOCITY * grabbed / 2
			grabbed = 0
		elif grabbed and not (leftPressed or rightPressed):
			velocity.x -= grabbed
		else:
			var acceleration = AIR_SIDE_ACCELERATION * delta
			if leftPressed:
				if velocity.x - acceleration > -LAND_SIDE_SPEED:
					velocity.x -= acceleration
				else:
					velocity.x = -LAND_SIDE_SPEED
			elif rightPressed:
				if velocity.x + acceleration < LAND_SIDE_SPEED:
					velocity.x += acceleration
				else:
					velocity.x = LAND_SIDE_SPEED
			if velocity.x < -LAND_SIDE_SPEED:
				velocity.x += acceleration
				if velocity.x > -LAND_SIDE_SPEED:
					velocity.x = -LAND_SIDE_SPEED
			if velocity.x > LAND_SIDE_SPEED:
				velocity.x -= acceleration
				if velocity.x < LAND_SIDE_SPEED:
					velocity.x = LAND_SIDE_SPEED
		velocity = move_and_slide(velocity, upVector, true)
		landed = is_on_floor() or hitting
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
		if leftPressed:
			$sprite.set_flip_h(false)
		elif rightPressed:
			$sprite.set_flip_h(true)
		if not hitting:
			if landed:
				if jumpPressed:
					anim = "JumpStart"
				elif (leftPressed or rightPressed) and abs(velocity.x) > 20:
					anim = "MoveSide"
			elif grabbed:
				$sprite.set_flip_h(grabbed < 0)
				if downPressed:
					anim = "GrabSlideFast"
				else:
					anim = "GrabSlide"
			else:
				if currentAnim == "JumpStart":
					anim = currentAnim
				elif abs(velocity.y) < 50:
					anim = "HighPoint"
				elif velocity.y < 0:
					anim = "Jump"
				else:
					anim = "Fall"
	else:
		var isJump = false
		if hitting or actionPressed:
			hitting = true
		elif grabbed:
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
				if velocity.x and velocity.y:
					velocity *= ZEROG_JUMP_DIAGONAL_VELOCITY
				else:
					velocity *= ZEROG_JUMP_VELOCITY;
			else:
				velocity *= 0
				if grabbed == LEFT:
					velocity.x = -100
				elif grabbed == RIGHT:
					velocity.x = 100
				elif grabbed == UP:
					velocity.y = -100
				elif grabbed == DOWN:
					velocity.y = 100
		else:
			if upPressed:
				if velocity.y > -ZEROG_MAX_VELOCITY:
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
			
			if velocity.x > ZEROG_MAX_VELOCITY and not rightPressed:
				velocity.x -= ZEROG_ACCELERATION * delta
			elif velocity.x < -ZEROG_MAX_VELOCITY and not leftPressed:
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
					rotateChildren(90)
				else:
					grabbed = RIGHT
					rotateChildren(270)
			else:
				if normal.y > 0:
					grabbed = UP
					rotateChildren(180)
				else:
					grabbed = DOWN
					rotateChildren(0)
			velocity.x = 0
			velocity.y = 0
			grabLeftTime = 0.2
		elif grabLeftTime > delta:
			grabLeftTime -= delta
		else:
			grabbed = 0
		
		if hitting:
			anim = "Hit0G"
		elif grabbed:
			anim = "Grab0G"
		elif leftPressed || rightPressed || upPressed || downPressed:
			anim = "Swim"

			if upPressed:
				if leftPressed:
					rotateChildren(315)
				elif rightPressed:
					rotateChildren(45)
				else:
					rotateChildren(0)
			elif downPressed:
				if leftPressed:
					rotateChildren(225)
				elif rightPressed:
					rotateChildren(135)
				else:
					rotateChildren(180)
			elif leftPressed:
				rotateChildren(270)
			elif rightPressed:
				rotateChildren(90)
		else:
			anim = "Idle0G"
	
	$sprite.play(anim)

func setGravity(isOn):
	hasGravity = isOn
	if isOn:
		$CollisionShape2D.rotation = 0
		$sprite.rotation = 0
	else:
		$sprite.set_flip_h(false)
	hitting = false
	
func _ready() :
	ZEROG_JUMP_DIAGONAL_VELOCITY = sqrt(ZEROG_JUMP_VELOCITY * ZEROG_JUMP_VELOCITY / 2)
	JUMP_DIAGONAL_VELOCITY = sqrt(JUMP_FORCE * JUMP_FORCE / 2)


func _on_sprite_animation_finished():
	var anim = $sprite.animation
	if anim in hitAnimations:
		hitting = false
		emit_signal("action_pressed")
		if hasGravity:
			$sprite.play("Idle")
		else:
			$sprite.play("Idle0G")
	elif anim == "JumpStart":
		$sprite.play("Jump")
