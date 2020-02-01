extends KinematicBody2D

export(float) var GRAVITY = 800.0
export(float) var JUMP_FORCE = 600.0
export(float) var LAND_SIDE_SPEED = 200.0
export(float) var AIR_SIDE_ACCELERATION = 800.0
export(float) var shake_amount = 2;

var velocity = Vector2()
var landed = false
var upVector = Vector2(0, -1)

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if landed:
		if Input.is_action_just_pressed("ui_up"):
			velocity.y = -JUMP_FORCE
			print("Jump")
		if Input.is_action_pressed("ui_left"):
			velocity.x = -LAND_SIDE_SPEED
		elif Input.is_action_pressed("ui_right"):
			velocity.x = LAND_SIDE_SPEED
		else:
			velocity.x = 0;
	else:
		if Input.is_action_just_pressed("ui_up"):
			print("Not on ground")
		if Input.is_action_pressed("ui_left"):
			if velocity.x - AIR_SIDE_ACCELERATION > -LAND_SIDE_SPEED:
				velocity.x -= AIR_SIDE_ACCELERATION * delta
			else:
				velocity.x = -LAND_SIDE_SPEED

		elif Input.is_action_pressed("ui_right"):
			if velocity.x + AIR_SIDE_ACCELERATION < LAND_SIDE_SPEED:
				velocity.x += AIR_SIDE_ACCELERATION * delta
			else:
				velocity.x = LAND_SIDE_SPEED
	
	velocity = move_and_slide(velocity, upVector, true)
	landed = is_on_floor()
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

