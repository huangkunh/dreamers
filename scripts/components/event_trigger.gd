extends Area3D
## 事件触发器 (EventTrigger)
## 玩家进入区域时触发事件
## 可用于: 场景切换、剧情触发、物品获取、敌人伏击等

## 事件类型
enum EventType {
	SCENE_CHANGE,     ## 切换场景
	DIALOGUE,         ## 触发对话
	BATTLE,           ## 触发战斗
	FLAG_SET,         ## 设置游戏标志
	ITEM_GIVE,        ## 给予物品
	MESSAGE,          ## 显示消息
}

## 事件类型
@export var event_type: EventType = EventType.MESSAGE
## 目标场景路径 (SCENE_CHANGE用)
@export var target_scene: String = ""
## 对话文件路径 (DIALOGUE用)
@export var dialogue_file: String = ""
## 对话起始ID
@export var dialogue_start_id: String = "start"
## 游戏标志名 (FLAG_SET用)
@export var flag_name: String = ""
## 物品ID (ITEM_GIVE用)
@export var item_id: String = ""
## 消息文本 (MESSAGE用)
@export var message_text: String = ""
## 是否只触发一次
@export var one_shot: bool = true
## 触发器名称 (用于调试)
@export var trigger_name: String = "EventTrigger"
## 触发区域大小
@export var trigger_size: Vector3 = Vector3(2, 2, 2)

## 是否已触发
var _triggered: bool = false

func _ready() -> void:
	# 创建碰撞形状
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = trigger_size
	collision.shape = box
	add_child(collision)

	# 连接信号
	body_entered.connect(_on_body_entered)

	# 调试: 添加可视化
	if OS.is_debug_build():
		_add_debug_visual()

## 添加调试可视化
func _add_debug_visual() -> void:
	var mesh := BoxMesh.new()
	mesh.size = trigger_size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.3, 0.3, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = mat
	add_child(mi)

## 玩家进入触发区域
func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if one_shot and _triggered:
		return

	_triggered = true
	print("[EventTrigger] 触发: ", trigger_name, " 类型: ", event_type)
	_execute_event()

## 执行事件
func _execute_event() -> void:
	match event_type:
		EventType.SCENE_CHANGE:
			_do_scene_change()
		EventType.DIALOGUE:
			_do_dialogue()
		EventType.BATTLE:
			_do_battle()
		EventType.FLAG_SET:
			_do_flag_set()
		EventType.ITEM_GIVE:
			_do_item_give()
		EventType.MESSAGE:
			_do_message()

## 场景切换
func _do_scene_change() -> void:
	if target_scene.is_empty():
		return
	print("[EventTrigger] 切换到场景: ", target_scene)
	# 通过GameFlow切换场景
	if target_scene in GameFlow.SCENE_PATHS:
		GameFlow.change_scene(target_scene)
	else:
		GameFlow.change_scene("city")

## 触发对话
func _do_dialogue() -> void:
	if dialogue_file.is_empty():
		return
	var file := FileAccess.open(dialogue_file, FileAccess.READ)
	if not file:
		push_error("EventTrigger: 无法加载对话文件: " + dialogue_file)
		return
	var json_string := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(json_string) == OK:
		var dialogue_data := DialogueManager.load_dialogue_from_dict(json.data)
		DialogueManager.start_dialogue(dialogue_data, dialogue_start_id)

## 触发战斗
func _do_battle() -> void:
	GameFlow.enter_battle()

## 设置游戏标志
func _do_flag_set() -> void:
	if flag_name.is_empty():
		return
	GameData.game_flags[flag_name] = true
	print("[EventTrigger] 设置标志: ", flag_name)

## 给予物品
func _do_item_give() -> void:
	if item_id.is_empty():
		return
	# TODO: 从物品数据库创建物品并添加到背包
	print("[EventTrigger] 获得物品: ", item_id)

## 显示消息
func _do_message() -> void:
	if message_text.is_empty():
		return
	print("[EventTrigger] 消息: ", message_text)
	# TODO: 显示消息UI

## 重置触发器 (可重复触发)
func reset() -> void:
	_triggered = false
