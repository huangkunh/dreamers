extends Node3D
## 蚂蚁巢穴 (AntNest)
## 第二个迷宫关卡，包含:
## - 地下蚁穴环境
## - 蚁群随机遇敌 (高频率)
## - BOSS战 (蚁后 - 赏金首b03)
## - 环境危害 (酸池、粘性地板)
## - 生物发光效果
## - 战斗后奖励

const NPC_SCENE := preload("res://scenes/characters/npc/npc.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")
const TREASURE_CHEST_SCRIPT := preload("res://scripts/components/treasure_chest.gd")

# 危害类型
enum HazardType {
	ACID_POOL,      ## 酸池 - 持续伤害
	STICKY_FLOOR,   ## 粘性地板 - 减速
	HONEY_POOL      ## 蜂蜜池 - 恢复但减速
}

# 危害数据
var _hazard_damage: Dictionary = {
	HazardType.ACID_POOL: {"damage": 5, "interval": 1.0, "effect": "poison"},
	HazardType.STICKY_FLOOR: {"slow_factor": 0.5, "duration": 2.0},
	HazardType.HONEY_POOL: {"heal": 3, "interval": 1.5, "slow_factor": 0.3}
}

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player
@onready var boss_trigger: Area3D = $BossArea/BossTrigger

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败BOSS
var _boss_defeated: bool = false
## 入口NPC (探险者)
var _entry_npc: CharacterBody3D
## 游戏内HUD
var _game_hud: Control
## 活跃的危害计时器
var _active_hazards: Dictionary = {}
## 生物发光节点列表
var _biolum_nodes: Array[Node] = []
## 敌人生成点列表
var _enemy_spawn_points: Dictionary = {}
## 宝箱列表
var _treasure_chests: Array[Area3D] = []

func _ready() -> void:
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY
	GameData.game_flags["current_area"] = "ant_nest"

	# 播放区域BGM
	BgmManager.play_area_bgm("ant_nest")

	# 将玩家加入player组
	if player:
		player.add_to_group("player")

	# 添加随机遇敌系统 (蚁穴遇敌率更高)
	if player:
		_encounter_system = load("res://scripts/system/random_encounter.gd").new()
		_encounter_system.encounter_rate = 0.025  # 2.5% 每步
		_encounter_system.min_steps_between_encounters = 4
		_encounter_system.area_id = "ant_nest"
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 初始化系统
	_setup_hazards()
	_setup_bioluminescence()
	_setup_enemy_spawn_points()
	_setup_treasure_chests()
	_create_entry_npc()
	_create_boss_trigger()

	# 实例化游戏内HUD
	_game_hud = GAME_HUD_SCENE.instantiate()
	add_child(_game_hud)
	_game_hud.show_hud()
	_game_hud.set_area_name("蚂蚁巢穴")

	# 检查BOSS是否已被击败
	if BountySystem.bounties.has("b03_ant_queen"):
		var bounty = BountySystem.bounties["b03_ant_queen"]
		if bounty.status == BountySystem.BountyStatus.CLAIMED:
			_boss_defeated = true
			print("[AntNest] BOSS已被击败")

func _process(delta: float) -> void:
	# 更新生物发光闪烁效果
	_update_bioluminescence(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				GameFlow.change_scene("world_map")

## ========================================
## 环境危害系统
## ========================================

func _setup_hazards() -> void:
	# 设置酸池危害
	var acid_pools = get_tree().get_nodes_in_group("acid_pool")
	for pool in acid_pools:
		if pool is Area3D:
			pool.body_entered.connect(_on_acid_pool_entered.bind(pool))
			pool.body_exited.connect(_on_acid_pool_exited.bind(pool))

	# 手动设置酸池（场景中的具体节点）
	if has_node("LiquidPools/AcidPool1"):
		var pool1 = $LiquidPools/AcidPool1
		pool1.body_entered.connect(_on_acid_pool_entered.bind(pool1))
		pool1.body_exited.connect(_on_acid_pool_exited.bind(pool1))

	if has_node("LiquidPools/AcidPool2"):
		var pool2 = $LiquidPools/AcidPool2
		pool2.body_entered.connect(_on_acid_pool_entered.bind(pool2))
		pool2.body_exited.connect(_on_acid_pool_exited.bind(pool2))

	# 设置蜂蜜池
	if has_node("LiquidPools/HoneyPool1"):
		var honey = $LiquidPools/HoneyPool1
		honey.body_entered.connect(_on_honey_pool_entered.bind(honey))
		honey.body_exited.connect(_on_honey_pool_exited.bind(honey))

	# 设置粘性地板
	if has_node("StickyFloors"):
		for sticky in $StickyFloors.get_children():
			if sticky is Area3D:
				sticky.body_entered.connect(_on_sticky_floor_entered.bind(sticky))
				sticky.body_exited.connect(_on_sticky_floor_exited.bind(sticky))

func _on_acid_pool_entered(body: Node, pool: Area3D) -> void:
	if body.is_in_group("player"):
		print("[AntNest] 玩家进入酸池!")
		_active_hazards[pool.get_instance_id()] = {
			"type": HazardType.ACID_POOL,
			"timer": 0.0
		}
		_apply_acid_damage(body)

func _on_acid_pool_exited(body: Node, pool: Area3D) -> void:
	if body.is_in_group("player"):
		print("[AntNest] 玩家离开酸池")
		_active_hazards.erase(pool.get_instance_id())

func _on_honey_pool_entered(body: Node, pool: Area3D) -> void:
	if body.is_in_group("player"):
		print("[AntNest] 玩家进入蜂蜜池 - 恢复生命但减速")
		_active_hazards[pool.get_instance_id()] = {
			"type": HazardType.HONEY_POOL,
			"timer": 0.0
		}
		_apply_honey_effect(body)

func _on_honey_pool_exited(body: Node, pool: Area3D) -> void:
	if body.is_in_group("player"):
		_active_hazards.erase(pool.get_instance_id())

func _on_sticky_floor_entered(body: Node, floor_area: Area3D) -> void:
	if body.is_in_group("player"):
		print("[AntNest] 玩家踩到粘性地板 - 移动减速")
		_apply_slow_effect(body, 0.5, 2.0)

func _on_sticky_floor_exited(body: Node, floor_area: Area3D) -> void:
	pass  # 减速效果会自然消退

func _apply_acid_damage(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(_hazard_damage[HazardType.ACID_POOL]["damage"])
		print("[AntNest] 酸池造成 %d 点伤害" % _hazard_damage[HazardType.ACID_POOL]["damage"])

func _apply_honey_effect(target: Node) -> void:
	# 蜂蜜池同时恢复和减速
	if target.has_method("heal"):
		target.heal(_hazard_damage[HazardType.HONEY_POOL]["heal"])
	_apply_slow_effect(target, _hazard_damage[HazardType.HONEY_POOL]["slow_factor"], 2.0)

func _apply_slow_effect(target: Node, slow_factor: float, duration: float) -> void:
	if target.has_method("apply_slow"):
		target.apply_slow(slow_factor, duration)
	elif "speed" in target:
		# 备用减速方式
		pass

## ========================================
## 生物发光系统
## ========================================

func _setup_bioluminescence() -> void:
	# 收集所有生物发光光源
	if has_node("Bioluminescence"):
		for child in $Bioluminescence.get_children():
			if child is OmniLight3D:
				_biolum_nodes.append({
					"node": child,
					"base_energy": child.light_energy,
					"phase": randf() * TAU
				})
			elif child is MeshInstance3D:
				# 检查子节点中的光源
				for subchild in child.get_children():
					if subchild is OmniLight3D:
						_biolum_nodes.append({
							"node": subchild,
							"base_energy": subchild.light_energy,
							"phase": randf() * TAU
						})

	# BOSS区域的发光效果
	if has_node("BossArea"):
		for child in $BossArea.get_children():
			if child is OmniLight3D:
				_biolum_nodes.append({
					"node": child,
					"base_energy": child.light_energy,
					"phase": randf() * TAU
				})

func _update_bioluminescence(delta: float) -> void:
	var time = Time.get_ticks_msec() / 1000.0
	for biolum in _biolum_nodes:
		var light: OmniLight3D = biolum["node"]
		var base_energy: float = biolum["base_energy"]
		var phase: float = biolum["phase"]
		# 创建柔和的脉冲效果
		var pulse = sin(time * 2.0 + phase) * 0.3 + 1.0
		light.light_energy = base_energy * pulse

## ========================================
## 敌人生成系统
## ========================================

func _setup_enemy_spawn_points() -> void:
	if not has_node("EnemySpawnZones"):
		return

	var spawn_zones = $EnemySpawnZones.get_children()
	for zone in spawn_zones:
		var spawn_points: Array[Vector3] = []
		for child in zone.get_children():
			if child is Marker3D:
				spawn_points.append(child.global_position)
		_enemy_spawn_points[zone.name] = spawn_points

	print("[AntNest] 初始化了 %d 个敌人生成区域" % _enemy_spawn_points.size())

func get_random_spawn_point(zone_name: String = "") -> Vector3:
	if zone_name.is_empty() or not _enemy_spawn_points.has(zone_name):
		# 随机选择一个区域
		var zones = _enemy_spawn_points.keys()
		if zones.is_empty():
			return Vector3.ZERO
		zone_name = zones[randi() % zones.size()]

	var points = _enemy_spawn_points[zone_name]
	if points.is_empty():
		return Vector3.ZERO
	return points[randi() % points.size()]

func get_spawn_points_in_zone(zone_name: String) -> Array[Vector3]:
	if _enemy_spawn_points.has(zone_name):
		return _enemy_spawn_points[zone_name]
	return []

## ========================================
## 宝箱系统
## ========================================

func _setup_treasure_chests() -> void:
	if not has_node("TreasureChests"):
		return

	var chests = $TreasureChests.get_children()
	var chest_index = 1

	for chest in chests:
		if chest is Area3D:
			# 根据位置设置不同的奖励
			var reward_config = _get_chest_reward(chest.name, chest_index)
			chest.set_script(TREASURE_CHEST_SCRIPT)
			chest.chest_id = "antnest_" + chest.name.to_lower()
			chest.reward_type = reward_config["type"]
			chest.reward_value = reward_config["value"]
			chest.display_name = reward_config["display_name"]
			_treasure_chests.append(chest)
			chest_index += 1

	print("[AntNest] 初始化了 %d 个宝箱" % _treasure_chests.size())

func _get_chest_reward(chest_name: String, index: int) -> Dictionary:
	match index:
		1:  # 入口附近 - 金币
			return {"type": 0, "value": "150", "display_name": "蚁穴宝箱"}
		2:  # 左隧道 - 药品
			return {"type": 2, "value": "antidote", "display_name": "解毒剂宝箱"}
		3:  # 右隧道 - 装备
			return {"type": 3, "value": "ant_armor", "display_name": "蚁甲宝箱"}
		4:  # BOSS房间稀有 - 全恢复
			return {"type": 4, "value": "full_heal", "display_name": "蚁后宝库"}
		5:  # BOSS房间 - 金币
			return {"type": 0, "value": "500", "display_name": "战利品宝箱"}
		_:
			return {"type": 0, "value": "100", "display_name": "蚁穴宝箱"}

## ========================================
## 入口NPC
## ========================================

func _create_entry_npc() -> void:
	_entry_npc = NPC_SCENE.instantiate()
	_entry_npc.npc_id = "injured_explorer"
	_entry_npc.npc_area = "ant_nest"
	_entry_npc.display_name = "受伤的探险者"
	_entry_npc.position = Vector3(0, 0, 8)
	add_child(_entry_npc)

## ========================================
## BOSS触发系统
## ========================================

func _create_boss_trigger() -> void:
	if _boss_defeated:
		# 如果BOSS已被击败，隐藏触发区域
		if has_node("BossArea/BossTrigger"):
			$BossArea/BossTrigger.queue_free()
		return

	# 使用场景中的BOSS触发区域
	if boss_trigger:
		boss_trigger.body_entered.connect(_on_boss_trigger_entered)
	else:
		# 备用：创建新的触发区域
		boss_trigger = Area3D.new()
		boss_trigger.position = Vector3(0, 1.5, -32)

		var collision := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(8, 4, 8)
		collision.shape = box
		boss_trigger.add_child(collision)

		# BOSS区域可视化 - 紫红色威胁感
		var mesh := BoxMesh.new()
		mesh.size = Vector3(8, 4, 8)
		var mi := MeshInstance3D.new()
		mi.mesh = mesh
		var mat := StandardMaterial3D.new()
		mat.albedo_color = Color(0.5, 0.1, 0.3, 0.2)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(0.6, 0.2, 0.4, 1)
		mat.emission_energy = 0.5
		mi.material_override = mat
		boss_trigger.add_child(mi)

		boss_trigger.body_entered.connect(_on_boss_trigger_entered)
		$BossArea.add_child(boss_trigger)

func _on_boss_trigger_entered(body: Node) -> void:
	if body.is_in_group("player") and not _boss_defeated:
		print("[AntNest] 触发蚁后BOSS战!")
		GameData.game_flags["boss_battle"] = "b03_ant_queen"
		GameData.game_flags["battle_area"] = "ant_nest"

		# 播放BOSS战音乐
		BgmManager.stop_bgm()

		# 进入战斗
		GameFlow.enter_battle()

## ========================================
## 随机遇敌
## ========================================

func _on_encounter() -> void:
	print("[AntNest] 蚂蚁袭击!")
	BgmManager.stop_bgm()
	GameData.game_flags["battle_area"] = "ant_nest"
	GameFlow.enter_battle()

## ========================================
## 公共接口
## ========================================

## 获取BOSS是否已被击败
func is_boss_defeated() -> bool:
	return _boss_defeated

## 设置BOSS已被击败
func set_boss_defeated(defeated: bool) -> void:
	_boss_defeated = defeated
	if defeated and boss_trigger:
		boss_trigger.queue_free()

## 获取所有敌人生成点
func get_all_spawn_points() -> Dictionary:
	return _enemy_spawn_points

## 获取特定区域的宝箱
func get_treasure_chests() -> Array[Area3D]:
	return _treasure_chests

## 获取危害数据
func get_hazard_damage(hazard_type: HazardType) -> Dictionary:
	return _hazard_damage.get(hazard_type, {})