extends CharacterBody3D
## NPC 节点 (NPC)
## 放置在城市场景中，玩家靠近后按 E 键交互
## 通过 metadata 指定 npc_id, area_id, shop_id

@export var npc_id: String = ""
@export var npc_area: String = "aoduo"
@export var shop_id: String = ""  # 如果不为空，则交互时打开商店
@export var display_name: String = "NPC"
@export var interaction_range: float = 2.0

@onready var interaction_area: Area3D = $InteractionArea
@onready var name_label: Label3D = $NameLabel
@onready var prompt_label: Label3D = $PromptLabel

var _player_nearby: bool = false
var _city_explorer: Node

func _ready() -> void:
	# 设置元数据
	set_meta("npc_id", npc_id)
	set_meta("area_id", npc_area)
	set_meta("shop_id", shop_id)

	# 显示名称
	if name_label:
		name_label.text = display_name
	if prompt_label:
		prompt_label.visible = false

	# 连接交互区域信号
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

	# 查找 CityExplorer
	_city_explorer = get_parent()
	while _city_explorer and not _city_explorer.has_method("set_nearby_npc"):
		_city_explorer = _city_explorer.get_parent()

func _on_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_nearby = true
		if prompt_label:
			prompt_label.visible = true
			prompt_label.text = "按 E 交互"
		if _city_explorer and _city_explorer.has_method("set_nearby_npc"):
			_city_explorer.set_nearby_npc(self)

func _on_body_exited(body: Node3D) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_nearby = false
		if prompt_label:
			prompt_label.visible = false
		if _city_explorer and _city_explorer.has_method("clear_nearby_npc"):
			_city_explorer.clear_nearby_npc()

func _process(_delta: float) -> void:
	# 让名称标签朝向相机
	var camera = get_viewport().get_camera_3d()
	if camera:
		if name_label:
			name_label.look_at(camera.global_position, Vector3.UP)
		if prompt_label:
			prompt_label.look_at(camera.global_position, Vector3.UP)
