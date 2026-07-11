extends Camera3D

var current_position: Vector3
var fight_end_position: Vector3 = Vector3(1.5, 1.5, 3.0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 水平移动
## move_distance 移动距离 负数网左移动, 整数往右移动
## time 时间
func move_horizontally(move_distance: float, time: float):
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	var move_position = Vector3(current_position)
	move_position.x += move_distance
	tween.tween_property(self, "position", move_position, time)
	

## 看向目标
## target_position 目标位置
func look_at_target(target_position, move_distance):
	#self.look_at(target_position, Vector3.UP)
	var rotation_degrees_y = 0
	if global_position.x > target_position.x:
		rotation_degrees_y += 2
	else:
		rotation_degrees_y -= 2
	var current_rotation_degrees = Vector3(rotation_degrees)
	current_rotation_degrees.y += rotation_degrees_y
	var move_position = Vector3(current_position)
	move_position.z -= move_distance
	#tween.stop()
	#position = move_position
	#rotation_degrees = current_rotation_degrees
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", move_position, 0.1)
	tween.parallel().tween_property(self, "rotation_degrees", current_rotation_degrees, 0.1)
	

## 重置相机状态
func reset_camera_status():
	#tween.stop()
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", current_position, 0.1)
	var reset_rotation = Vector3(self.rotation)
	reset_rotation.y = 0
	reset_rotation.z = 0
	tween.parallel().tween_property(self, "rotation", reset_rotation, 0.1)


## 战斗结束
func fight_end():
	var tween: Tween = self.create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", fight_end_position, 0.2)
	
