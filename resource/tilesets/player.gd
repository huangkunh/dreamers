extends CharacterBody3D

## 移动速度
@export var movement_speed := 200
## 重力
@export var gravity := 10

@onready var animated_sprite3D := $Animation

var target_velocity: Vector3 = Vector3.ZERO

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
		
	target_velocity = vector * movement_speed * delta
	
	if not is_on_floor():
		target_velocity.y -= gravity * delta
	
	if vector.length() >0:
		animated_sprite3D.play()		
	else:
		animated_sprite3D.stop()
	
	velocity = target_velocity
	move_and_slide()	
	
