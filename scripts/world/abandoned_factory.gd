extends Node3D
## 废弃工厂 (AbandonedFactory)
## 第一个迷宫关卡，包含:
## - 入口NPC (给予任务提示)
## - 工厂内部探索 (敌人随机遇敌)
## - BOSS战 (失控坦克 - 赏金首b02)
## - 战斗后奖励

const NPC_SCENE := preload("res://scene/characters/npc/npc.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败BOSS
var _boss_defeated: bool = false
## 入口NPC
var _entry_npc: CharacterBody3D
## BOSS触发器
var _boss_trigger: Area3D

func _ready() -> void:
	# 播放背景音乐
	if audio_stream_player and not audio_stream_player.playing:
		audio_stream_player.play()

	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY
	GameData.game_flags["current_area"] = "factory"

	# 将玩家加入player组
	if player:
		player.add_to_group("player")

	# 添加随机遇敌系统
	if player:
		_encounter_system = load("res://script/system/random_encounter.gd").new()
		_encounter_system.encounter_rate = 0.02
		_encounter_system.min_steps_between_encounters = 5
		_encounter_system.area_id = "factory"
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 创建入口NPC
	_create_entry_npc()

	# 创建BOSS触发区域
	_create_boss_trigger()

	# 检查BOSS是否已被击败
	if BountySystem.bounties.has("b02_mad_tank"):
		var bounty = BountySystem.bounties["b02_mad_tank"]
		if bounty.status == BountySystem.BountyStatus.CLAIMED:
			_boss_defeated = true
			print("[Factory] BOSS已被击败")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				GameFlow.change_scene("world_map")

## 创建入口NPC
func _create_entry_npc() -> void:
	_entry_npc = NPC_SCENE.instantiate()
	_entry_npc.npc_id = "factory_guard"
	_entry_npc.npc_area = "factory"
	_entry_npc.display_name = "工厂守卫"
	_entry_npc.position = Vector3(0, 0, 5)
	add_child(_entry_npc)

## 创建BOSS触发区域
func _create_boss_trigger() -> void:
	if _boss_defeated:
		return

	_boss_trigger = Area3D.new()
	_boss_trigger.position = Vector3(0, 0, -20)

	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3, 3, 3)
	collision.shape = box
	_boss_trigger.add_child(collision)

	# 可视化标记
	var mesh := BoxMesh.new()
	mesh.size = Vector3(3, 3, 3)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 0.2, 0.2, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = mat
	_boss_trigger.add_child(mi)

	_boss_trigger.body_entered.connect(_on_boss_trigger_entered)
	add_child(_boss_trigger)

## BOSS触发
func _on_boss_trigger_entered(body: Node) -> void:
	if body.is_in_group("player") and not _boss_defeated:
		print("[Factory] 触发BOSS战!")
		GameData.game_flags["boss_battle"] = "b02_mad_tank"
		GameData.game_flags["battle_area"] = "factory"
		GameFlow.enter_battle()

## 遇敌回调
func _on_encounter() -> void:
	print("[Factory] 随机遇敌!")
	if audio_stream_player:
		audio_stream_player.stop()
	GameData.game_flags["battle_area"] = "factory"
	GameFlow.enter_battle()
