extends Camera2D

var wobbleOffset = Vector2()
var shakeOffset = Vector2()
var maxWobble = 0
var wobbleSpeed = 8
var shake_amount = 0
var shakeDuration = 0;

func wobble(maxRotation):
	maxWobble = maxRotation
	if maxWobble == 0:
		rotation = 0
		wobbleOffset.x = 0
		shake(2, 1)

func shake(amount, duration = 0):
	shake_amount = amount
	if duration:
		shakeDuration = duration

func _process(delta):
	if maxWobble:
		rotation_degrees += wobbleSpeed * delta

		if (rotation_degrees < -maxWobble and wobbleSpeed < 0) or (rotation_degrees > maxWobble and wobbleSpeed > 0):
			wobbleSpeed = -wobbleSpeed
		wobbleOffset.x += 2 * rotation_degrees * delta
		set_offset(wobbleOffset)
	if shake_amount:
		shakeOffset.x = wobbleOffset.x + rand_range(-1.0, 1.0) * shake_amount;
		shakeOffset.y = rand_range(-1.0, 1.0) * shake_amount;
		set_offset(shakeOffset)
	if shakeDuration:
		shakeDuration -= delta
		if shakeDuration <= 0:
			shakeDuration = 0
			shake_amount = 0

