extends Node2D

var state = "OFF"
var status = false


func _ready():
	$Anim.play("OFF")
	
func start():
	$Anim.play("ON")
	
func stop():
	$Anim.play("OFF")
