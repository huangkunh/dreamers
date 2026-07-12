extends Node3D
## 古代遗迹 (AncientRuins)
## 第三个迷宫关卡，高级区域，包含:
## - 旧文明地下研究所环境
## - 强力敌人随机遇敌
## - BOSS战 (不定形 - 赏金首b04)
## - 宝箱奖励 (高级装备)
## - 隐藏房间

const NPC_SCENE := preload("res://scenes/characters/npc/npc.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")
const TREASURE_CHEST_SCRIPT := preload("res://scripts/components/treasure_chest.gd")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败BOSS
var _boss_defeated: bool = false
## 入口NPC (古代AI全息影像)
var _entry_npc: CharacterBody3D
## BOSS触发器
var _boss_trigger: Area3D
## 游戏内HUD
var _game_hud: Control
## 宝箱列表
var _chests: Array = []

func _ready() -> void:
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY
	GameData.game_flags["current_area"] = "ancient_ruins"

	# 播放区域BGM
	BgmManager.play_area_bgm("ancient_ruins")

	# 将玩家加入player组
	if player:
		player.add_to_group("player")

	# 添加随机遇敌系统 (遗迹遇敌率最高，敌人最强)
	if player:
		_encounter_system = load("res://scripts/system/random_encounter.gd").new()
		_encounter_system.encounter_rate = 0.03  # 3% 每步
		_encounter_system.min_steps_between_encounters = 4
		_encounter_system.area_id = "ancient_ruins"
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 创建入口NPC
	_create_entry_npc()

	# 创建BOSS触发区域
	_create_boss_trigger()

	# 创建宝箱
	_create_chests()

	# 实例化游戏内HUD
	_game_hud = GAME_HUD_SCENE.instantiate()
	add_child(_game_hud)
	_game_hud.show_hud()
	_game_hud.set_area_name("古代遗迹")

	# 检查BOSS是否已被击败
	if BountySystem.bounties.has("b04_amorphous"):
		var bounty = BountySystem.bounties["b04_amorphous"]
		if bounty.status == BountySystem.BountyStatus.CLAIMED:
			_boss_defeated = true
			print("[AncientRuins] BOSS已被击败")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				GameFlow.change_scene("world_map")

## 创建入口NPC (古代AI全息影像)
func _create_entry_npc() -> void:
	_entry_npc = NPC_SCENE.instantiate()
	_entry_npc.npc_id = "ancient_ai"
	_entry_npc.npc_area = "ancient_ruins"
	_entry_npc.display_name = "古代AI"
	_entry_npc.position = Vector3(0, 0, 5)
	add_child(_entry_npc)

## 创建BOSS触发区域
func _create_boss_trigger() -> void:
	if _boss_defeated:
		return

	_boss_trigger = Area3D.new()
	_boss_trigger.position = Vector3(0, 0, -30)

	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3, 3, 3)
	collision.shape = box
	_boss_trigger.add_child(collision)

	# 可视化标记 (青色 - 古代科技)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(3, 3, 3)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.8, 0.9, 0.3)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.5, 0.8)
	mat.emission_energy_multiplier = 0.5
	mi.material_override = mat
	_boss_trigger.add_child(mi)

	_boss_trigger.body_entered.connect(_on_boss_trigger_entered)
	add_child(_boss_trigger)

## 创建宝箱
func _create_chests() -> void:
	# 宝箱1: 金币奖励 (入口附近)
	_create_chest("ruins_chest_1", Vector3(-8, 0, -8), 0, "500", 1, "金币宝箱")

	# 宝箱2: 全恢复 (中段)
	_create_chest("ruins_chest_2", Vector3(8, 0, -15), 4, "", 1, "恢复宝箱")

	# 宝箱3: 关键道具 (隐藏房间)
	_create_chest("ruins_chest_3", Vector3(-12, 0, -22), 3, "ancient_key", 1, "神秘宝箱")

## 创建单个宝箱
func _create_chest(chest_id: String, pos: Vector3, type: int, value: String, amount: int, name: String) -> void:
	var chest := Area3D.new()
	chest.set_script(TREASURE_CHEST_SCRIPT)
	chest.chest_id = chest_id
	chest.reward_type = type
	chest.reward_value = value
	chest.reward_amount = amount
	chest.display_name = name
	chest.position = pos
	add_child(chest)
	_chests.append(chest)

## BOSS触发
func _on_boss_trigger_entered(body: Node) -> void:
	if body.is_in_group("player") and not _boss_defeated:
		print("[AncientRuins] 触发不定形BOSS战!")
		GameData.game_flags["boss_battle"] = "b04_amorphous"
		GameData.game_flags["battle_area"] = "ancient_ruins"
		GameFlow.enter_battle()

## 遇敌回调
func _on_encounter() -> void:
	print("[AncientRuins] 遭遇古代守卫!")
	BgmManager.stop_bgm()
	GameData.game_flags["battle_area"] = "ancient_ruins"
	GameFlow.enter_battle()
