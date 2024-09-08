extends Path2D

@export var fight_speed_scene : PackedScene

@onready var fight_speed_timer : Timer = $FightSpeedTimer

var fight_speed_list : Array = []
 
var fight_speed_pre_list : Array = []

var last_progress_ratio :float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	fight_speed_list_null()
	
	fight_speed_list_timer(delta)		
	pass

## 本回合计算战斗顺序
func fight_speed_list_timer(delta):
	# 剩余距离
	var fight_distance = 1.0 - last_progress_ratio
	# 平均速度 
	var fight_velocity = fight_distance / fight_speed_timer.wait_time
	if fight_speed_list != null:
		var fight_in = true
		var size = fight_speed_list.size()
		for i in range(size):
			var progress_ratio = fight_speed_list[i].progress_ratio
			# 当前位置 = 原来的位置 + 时间 * 速度
			progress_ratio += delta * fight_velocity			
			fight_speed_list[i].progress_ratio = progress_ratio
	
			if progress_ratio >= 0.99:
				fight_speed_list[i].progress_ratio = 1.0
				fight_in = false
				print(fight_speed_list[i])
				
		#set_process(fight_in)

## 本回合已经轮空
func fight_speed_list_null():
	if ((
			fight_speed_list == null || fight_speed_list.size() == 0) 
			&& fight_speed_pre_list != null
	):
		var fight_speed_size = fight_speed_pre_list.size()
		for i in range(fight_speed_pre_list.size()):
			fight_speed_list.append(fight_speed_pre_list[fight_speed_size - i - 1])
			var fight_speed :PathFollow2D = fight_speed_list[i]
			var progress_ratio = fight_speed.progress_ratio + 1.0 / 3.0
			#fight_speed.progress_ratio = progress_ratio
			var tween = fight_speed.create_tween()
			tween.tween_property(fight_speed, "progress_ratio", progress_ratio, 0.5)
			
			if i == fight_speed_size - 1 :
				last_progress_ratio = fight_speed_pre_list[i].progress_ratio
					
		var fight_speed_pre_list_temp = fight_speed_pre_list
		fight_speed_pre_list = []
		#init_fight_speed_Path(fight_speed_pre_list_temp)
	pass


## 初始化战斗速度
## 参数 fight_speed_data_list 参与战斗的玩家和怪物的数据
func init_fight_speed_Path(fight_speed_data_list):
	if fight_speed_data_list == null:
		return
	for i in range(fight_speed_data_list.size()):
		var fight_speed_instance = fight_speed_scene.instantiate()
		var fight_speed_data = fight_speed_data_list[i]
		fight_speed_data.player_name += str(i)
		fight_speed_instance._ready()
		fight_speed_instance.init_fight_speed(fight_speed_data)
		fight_speed_pre_list.append(fight_speed_instance)
		add_child(fight_speed_instance)
		
	fight_speed_pre_sort()
	print(fight_speed_pre_list)
	
	
## 对准备战斗的玩家和怪物进行排序
func fight_speed_pre_sort():
	if fight_speed_pre_list != null:
		# 速度从小到大排序
		fight_speed_pre_list.sort_custom(func(a, b) : 
			if a.fight_speed < b.fight_speed:
				return true
			elif( 
					a.fight_speed == b.fight_speed 
					&& a.player_name.naturalnocasecmp_to(b.player_name) < 0
			):
				return true
			else:
				return false)
			
		var fight_speed_size = fight_speed_pre_list.size()
		for i in range(fight_speed_size):
			# 取路径前 1/3 做下回合
			var progress_ratio = (1.0 / 3.0) * (1.0 / fight_speed_size) * i
			fight_speed_pre_list[i].progress_ratio = progress_ratio
			
		
