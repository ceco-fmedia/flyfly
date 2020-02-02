extends Node2D

func _ready():
	$AnimatedSprite.play("OFF")

func _on_AnimatedSprite_animation_finished():
	$AnimatedSprite.play("OFF")
