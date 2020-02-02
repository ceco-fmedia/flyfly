extends Node2D

var state = "OFF"
var status = false


func _ready():
	$Anim.play("OFF")

func _on_Timer_timeout():
	state = "OFF" if state == "ON" else "ON"
	if status:
		$Anim.play(state)
	
func start_alarm():
	$Timer.set_wait_time(0.5)
	status = true 
	
func stop_alarm():
	$Anim.play("OFF")
	status = false
