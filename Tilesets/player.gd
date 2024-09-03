extends CharacterBody3D

@export var speed := 10
@onready var animated_sprite3D := $Animation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	player_move(delta)
	
func player_move(delta:float):
	var vector := Vector3.ZERO
	if Input.is_action_pressed("ui_up"):
		animated_sprite3D.play("Up")
		vector.z -= 1
	elif Input.is_action_pressed("ui_down"):
		animated_sprite3D.play("Down")
		vector.z += 1
	elif Input.is_action_pressed("ui_right"):
		animated_sprite3D.play("Right")
		vector.x += 1
	elif Input.is_action_pressed("ui_left"):
		animated_sprite3D.play("Left")
		vector.x -=1
	
	if vector.length() >0:
		animated_sprite3D.play()
		self.move_and_collide(vector * delta * speed,false,0.0,true,1)
	else:
		animated_sprite3D.stop()	
	
