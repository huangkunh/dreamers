extends Path2D

signal uint_fighting

@export var fight_speed_scene: PackedScene

@onready var fight_speed_timer: Timer = $FightSpeedTimer

var fight_speed_list: Array = []
 
var fight_speed_pre_list: Array = []

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
## 参数 delta 帧间隔时间
func fight_speed_list_timer(delta):
	# 剩余距离
	var fight_distance = 1.0 - last_progress_ratio
	# 平均速度 
	var fight_velocity = fight_distance / fight_speed_timer.wait_time
	if fight_speed_list != null:
		#var fighting = false
		#var fight_unit = 0
		var size = fight_speed_list.size()
		for i in range(size):
			var progress_ratio = fight_speed_list[i].progress_ratio
			# 当前位置 = 原来的位置 + 时间 * 速度
			progress_ratio += delta * fight_velocity			
			fight_speed_list[i].progress_ratio = progress_ratio
	
			# 单位开始战斗
			if progress_ratio >= 0.99:
				fight_speed_list[i].progress_ratio = 1.0
				set_process(false)
				uint_fighting.emit(fight_speed_list[i].fight_id)


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
		init_fight_speed_Path(fight_speed_pre_list_temp)
	pass


## 初始化战斗速度
## 参数 fight_speed_data_list 参与战斗的玩家和怪物的数据
func init_fight_speed_Path(fight_speed_data_list):
	if fight_speed_data_list == null:
		return
	var fight_speed_map: Dictionary = {}
	for i in range(fight_speed_data_list.size()):
		var fight_speed_instance = fight_speed_scene.instantiate()
		var fight_speed_data = fight_speed_data_list[i]
		var fight_id = fight_speed_data.fight_id
		
		if fight_id == null:
			fight_speed_data.fight_id = fight_speed_data.player_name
		fight_speed_instance._ready()
		fight_speed_instance.init_fight_speed(fight_speed_data)
		fight_speed_pre_list.append(fight_speed_instance)
		add_child(fight_speed_instance)
		
		fight_speed_map.fight_id = fight_speed_data
		
	fight_speed_pre_sort()
	
	return fight_speed_map
	
	
## 对准备战斗的玩家和怪物进行排序
func fight_speed_pre_sort():
	if fight_speed_pre_list != null:
		# 速度从小到大排序
		fight_speed_pre_list.sort_custom(func(a, b): 
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


## 单位战斗结束
## current_fight_id 战斗id
func unit_fight_end(current_fight_id):
	clear_fight_speed(fight_speed_list, current_fight_id)
	set_process(true)
	pass


## 单位战斗死亡
## current_fight_id 战斗id
func unit_fight_death(fight_id):
	clear_fight_speed(fight_speed_list, fight_id)
	clear_fight_speed(fight_speed_pre_list, fight_id)
	set_process(true)
	

## 清除战斗进度取样器
## path_arr 取样器列表
## current_fight_id 战斗id
func clear_fight_speed(path_arr, current_fight_id):
	if path_arr.size() == 1:
		if path_arr[0].fight_id == current_fight_id:
			path_arr[0].queue_free()
			path_arr.resize(0)
			return
		
	for i in range(path_arr.size()):
		var fight_speed = path_arr[i]
		if fight_speed.fight_id == current_fight_id:
			path_arr.remove_at(i)
			fight_speed.queue_free()
			break


## 战斗进度暂停
func fight_stop():
	set_process(false)


## 战斗进度恢复
func fight_restore():
	set_process(true)
