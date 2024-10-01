extends Camera3D

var current_position: Vector3
var tween: Tween = self.create_tween()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_position = position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 水平移动
## move_distance 移动距离
## time 时间
func move_horizontally(move_distance: float, time: float):
	var target_position = Vector3(current_position)
	target_position.x += move_distance
	tween.tween_property(self, "position", target_position, time)
