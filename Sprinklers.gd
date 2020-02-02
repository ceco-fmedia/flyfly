extends Node2D

func _ready():
	$AnimatedSprite.visible = false

func start():
	$AnimatedSprite.visible = true
	$AnimatedSprite.play("OFF")
	$AnimatedSprite.play("ON")


func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.visible = false
	$AnimatedSprite.stop()

