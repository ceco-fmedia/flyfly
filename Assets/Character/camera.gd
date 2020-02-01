extends Camera2D

var wobbleOffset = Vector2()
var maxWobble = 0
var wobbleSpeed = 8
var shake_amount = 0
var duration = 0;

func wobble(maxRotation):
	maxWobble = maxRotation
	shake_amount = 0
	wobbleOffset.y = 0
	if maxWobble == 0:
		shake(2, 1)

func shake(amount, shakeDuration = 0):
	maxWobble = 0
	shake_amount = amount
	if shakeDuration:
		duration = shakeDuration

func _process(delta):
	if maxWobble:
		rotation_degrees += wobbleSpeed * delta

		if (rotation_degrees < -maxWobble and wobbleSpeed < 0) or (rotation_degrees > maxWobble and wobbleSpeed > 0):
			wobbleSpeed = -wobbleSpeed
		wobbleOffset.x += 2 * rotation_degrees * delta
		set_offset(wobbleOffset)
	if shake_amount:
		wobbleOffset.x = rand_range(-1.0, 1.0) * shake_amount;
		wobbleOffset.y = rand_range(-1.0, 1.0) * shake_amount;
		set_offset(wobbleOffset)
	if duration:
		duration -= delta
		print(duration, delta)
		if duration <= 0:
			duration = 0
			maxWobble = 0
			shake_amount = 0
			wobbleOffset.x = 0
			wobbleOffset.y = 0
