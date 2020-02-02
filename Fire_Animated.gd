extends Node2D

var state = "OFF"
var status = false


func _ready():
	$Anim.play("OFF")
	
func start_alarm():
	$Anim.play("ON")
	
func stop_alarm():
	$Anim.play("OFF")
