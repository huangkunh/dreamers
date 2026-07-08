extends Area3D
## NPC组件 (NPCInteractable)
## 附加到NPC节点上，处理玩家交互
## 玩家靠近按交互键时触发对话

## NPC显示名字
@export var npc_name: String = "NPC"
## 对话ID (对应DialogueManager中的对话数据)
@export var dialogue_id: String = ""
## 对话数据文件路径 (JSON格式)
@export var dialogue_file: String = ""
## 是否只能交互一次
@export var one_shot: bool = false
## 交互范围
@export var interact_radius: float = 2.0

## 已交互过
var _interacted: bool = false
## 对话数据
var _dialogue_data: Dictionary = {}

signal interacted

func _ready() -> void:
	# 设置碰撞区域
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = interact_radius
	collision.shape = sphere
	add_child(collision)

	# 连接Area3D信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# 加载对话数据
	if dialogue_file != "":
		_load_dialogue_file()

## 加载对话文件
func _load_dialogue_file() -> void:
	if not FileAccess.file_exists(dialogue_file):
		push_warning("NPC: 对话文件不存在: " + dialogue_file)
		return
	var file := FileAccess.open(dialogue_file, FileAccess.READ)
	if not file:
		return
	var json_string := file.get_as_text()
	file.close()
	var json := JSON.new()
	if json.parse(json_string) == OK:
		_dialogue_data = DialogueManager.load_dialogue_from_dict(json.data)
	else:
		push_error("NPC: 对话文件解析失败: " + dialogue_file)

## 玩家进入交互范围
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		# 显示交互提示
		print("[NPC] ", npc_name, " 进入交互范围")
		# TODO: 显示"按E交互"提示UI

## 玩家离开交互范围
func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		print("[NPC] ", npc_name, " 离开交互范围")

## 触发交互
func interact() -> void:
	if one_shot and _interacted:
		return
	_interacted = true
	interacted.emit()

	if _dialogue_data.size() > 0:
		DialogueManager.start_dialogue(_dialogue_data, dialogue_id)
	else:
		print("[NPC] ", npc_name, " 没有对话数据")
