extends Node3D
## 废弃工厂 (AbandonedFactory)
## 第一个迷宫关卡，包含:
## - 入口NPC (给予任务提示)
## - 工厂内部探索 (敌人随机遇敌)
## - BOSS战 (失控坦克 - 赏金首b02)
## - 战斗后奖励
## - 环境危险区域 (蒸汽、毒液、电气)
## - 交互元素 (开关、拉杆)
## - HD-2D后处理效果 (闪烁灯光、暗角)

const NPC_SCENE := preload("res://scenes/characters/npc/npc.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")
const TREASURE_CHEST_SCRIPT := preload("res://scripts/components/treasure_chest.gd")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player
@onready var vignette_overlay: ColorRect = $VignetteOverlay

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败BOSS
var _boss_defeated: bool = false
## 入口NPC
var _entry_npc: CharacterBody3D
## BOSS触发器
var _boss_trigger: Area3D
## 游戏内HUD
var _game_hud: Control

## 闪烁灯光列表
var _flickering_lights: Array[OmniLight3D] = []
## 应急灯光列表
var _emergency_lights: Array[Light3D] = []
## 环境危险区域列表
var _hazard_areas: Array[Area3D] = []
## 交互元素列表
var _interactive_elements: Array[Area3D] = []

## 灯光闪烁计时器
var _flicker_timer: float = 0.0
## 应急灯脉冲计时器
var _emergency_timer: float = 0.0
## 当前开关状态
var _power_enabled: bool = true
## 拉杆激活状态
var _lever_activated: bool = false

## 危险伤害配置
const STEAM_DAMAGE: int = 5
const TOXIC_DAMAGE: int = 10
const ELECTRIC_DAMAGE: int = 15
const HAZARD_DAMAGE_INTERVAL: float = 1.0

## 玩家在危险区域的计时
var _player_in_hazard: Dictionary = {}

func _ready() -> void:
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY
	GameData.game_flags["current_area"] = "factory"

	# 播放区域BGM
	BgmManager.play_area_bgm("factory")

	# 将玩家加入player组
	if player:
		player.add_to_group("player")

	# 添加随机遇敌系统
	if player:
		_encounter_system = load("res://scripts/system/random_encounter.gd").new()
		_encounter_system.encounter_rate = 0.02
		_encounter_system.min_steps_between_encounters = 5
		_encounter_system.area_id = "factory"
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 创建入口NPC
	_create_entry_npc()

	# 创建BOSS触发区域
	_create_boss_trigger()

	# 创建宝箱
	_create_chests()

	# 初始化灯光系统
	_setup_lighting()

	# 初始化环境危险
	_setup_hazards()

	# 初始化交互元素
	_setup_interactive_elements()

	# 实例化游戏内HUD
	_game_hud = GAME_HUD_SCENE.instantiate()
	add_child(_game_hud)
	_game_hud.show_hud()
	_game_hud.set_area_name("废弃工厂")

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

func _process(delta: float) -> void:
	# 更新灯光闪烁效果
	_update_flickering_lights(delta)

	# 更新应急灯脉冲效果
	_update_emergency_lights(delta)

	# 处理环境危险伤害
	_process_hazard_damage(delta)

	# 更新暗角效果（基于玩家位置）
	_update_vignette_effect()

func _physics_process(delta: float) -> void:
	# 检测交互元素
	_check_interactive_elements()

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

## 创建宝箱
func _create_chests() -> void:
	# 宝箱1: 金币 (角落)
	var chest1 := Area3D.new()
	chest1.set_script(TREASURE_CHEST_SCRIPT)
	chest1.chest_id = "factory_chest_1"
	chest1.reward_type = 0  # COINS
	chest1.reward_value = "300"
	chest1.display_name = "工厂宝箱"
	chest1.position = Vector3(-15, 0, -10)
	add_child(chest1)

	# 宝箱2: 全恢复 (BOSS房附近)
	var chest2 := Area3D.new()
	chest2.set_script(TREASURE_CHEST_SCRIPT)
	chest2.chest_id = "factory_chest_2"
	chest2.reward_type = 4  # HEAL
	chest2.display_name = "补给箱"
	chest2.position = Vector3(12, 0, -18)
	add_child(chest2)

	# 宝箱3: 武器配件 (传送带附近)
	var chest3 := Area3D.new()
	chest3.set_script(TREASURE_CHEST_SCRIPT)
	chest3.chest_id = "factory_chest_3"
	chest3.reward_type = 2  # ITEM
	chest3.reward_value = "weapon_part_01"
	chest3.display_name = "配件箱"
	chest3.position = Vector3(-5, 0, 0)
	add_child(chest3)

	# 宝箱4: 经验加成道具 (化学桶附近)
	var chest4 := Area3D.new()
	chest4.set_script(TREASURE_CHEST_SCRIPT)
	chest4.chest_id = "factory_chest_4"
	chest4.reward_type = 1  # EXP_BOOST
	chest4.reward_value = "50"
	chest4.display_name = "研究资料"
	chest4.position = Vector3(5, 0, -15)
	add_child(chest4)

	# 宝箱5: 稀有材料 (发电机附近)
	var chest5 := Area3D.new()
	chest5.set_script(TREASURE_CHEST_SCRIPT)
	chest5.chest_id = "factory_chest_5"
	chest5.reward_type = 3  # MATERIAL
	chest5.reward_value = "rare_metal_01"
	chest5.display_name = "材料箱"
	chest5.position = Vector3(18, 0, 12)
	add_child(chest5)

## 初始化灯光系统
func _setup_lighting() -> void:
	# 获取闪烁灯光节点
	var lights_node = $Lights
	if lights_node:
		for child in lights_node.get_children():
			if child.name.begins_with("FlickeringLight") and child is OmniLight3D:
				_flickering_lights.append(child)
			elif child.name.begins_with("EmergencyLight") and child is Light3D:
				_emergency_lights.append(child)

## 更新闪烁灯光效果
func _update_flickering_lights(delta: float) -> void:
	_flicker_timer += delta

	for light in _flickering_lights:
		# 随机闪烁模式
		if randf() < 0.02:
			# 临时关闭
			light.light_energy = 0.0
		elif randf() < 0.05:
			# 强光
			light.light_energy = randf_range(1.5, 2.0)
		else:
			# 正常亮度（带小波动）
			var base_energy: float = 1.0
			if light.name == "FlickeringLight1":
				base_energy = 1.2
			elif light.name == "FlickeringLight4":
				base_energy = 0.8
			elif light.name in ["FlickeringLight5", "FlickeringLight6"]:
				base_energy = 0.6
			light.light_energy = base_energy + randf_range(-0.1, 0.1)

## 更新应急灯脉冲效果
func _update_emergency_lights(delta: float) -> void:
	_emergency_timer += delta

	# 应急灯脉冲周期约2秒
	var pulse: float = sin(_emergency_timer * 3.0) * 0.5 + 0.5

	for light in _emergency_lights:
		if _power_enabled:
			# 正常脉冲效果
			light.light_energy = 1.5 + pulse * 1.0
		else:
			# 电源关闭时应急灯更亮
			light.light_energy = 2.5 + pulse * 1.5

## 初始化环境危险
func _setup_hazards() -> void:
	var hazards_node = $EnvironmentalHazards
	if hazards_node:
		for child in hazards_node.get_children():
			if child is Area3D:
				_hazard_areas.append(child)
				child.body_entered.connect(_on_hazard_entered.bind(child))
				child.body_exited.connect(_on_hazard_exited.bind(child))

## 玩家进入危险区域
func _on_hazard_entered(body: Node, hazard: Area3D) -> void:
	if body.is_in_group("player"):
		_player_in_hazard[hazard.name] = 0.0
		print("[Factory] 玩家进入危险区域: " + hazard.name)

## 玩家离开危险区域
func _on_hazard_exited(body: Node, hazard: Area3D) -> void:
	if body.is_in_group("player"):
		_player_in_hazard.erase(hazard.name)
		print("[Factory] 玩家离开危险区域: " + hazard.name)

## 处理危险伤害
func _process_hazard_damage(delta: float) -> void:
	for hazard_name in _player_in_hazard.keys():
		_player_in_hazard[hazard_name] += delta

		if _player_in_hazard[hazard_name] >= HAZARD_DAMAGE_INTERVAL:
			# 重置计时器
			_player_in_hazard[hazard_name] = 0.0

			# 计算伤害
			var damage: int = 0
			var damage_type: String = ""

			if hazard_name.begins_with("SteamVent"):
				damage = STEAM_DAMAGE
				damage_type = "蒸汽"
			elif hazard_name.begins_with("ToxicPuddle"):
				damage = TOXIC_DAMAGE
				damage_type = "毒液"
			elif hazard_name.begins_with("ElectricalHazard"):
				damage = ELECTRIC_DAMAGE
				damage_type = "电气"

			# 应用伤害（如果玩家有health属性）
			if player and player.has_method("take_damage"):
				player.take_damage(damage, damage_type)
				print("[Factory] " + damage_type + "伤害: " + str(damage))

			# 显示HUD提示
			if _game_hud and _game_hud.has_method("show_damage_warning"):
				_game_hud.show_damage_warning(damage_type)

## 初始化交互元素
func _setup_interactive_elements() -> void:
	var interactive_node = $InteractiveElements
	if interactive_node:
		for child in interactive_node.get_children():
			if child is Area3D:
				_interactive_elements.append(child)
				child.body_entered.connect(_on_interactive_entered.bind(child))

## 检测交互元素
func _check_interactive_elements() -> void:
	if not player:
		return

	# 检测玩家是否在交互范围内
	for element in _interactive_elements:
		var overlapping_bodies = element.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				# 显示交互提示（如果玩家按下交互键）
				if Input.is_action_just_pressed("interact"):
					_interact_with_element(element)

## 进入交互元素区域
func _on_interactive_entered(body: Node, element: Area3D) -> void:
	if body.is_in_group("player"):
		# 显示交互提示
		if _game_hud and _game_hud.has_method("show_interaction_hint"):
			var hint_text: String = ""
			if element.name == "PowerSwitch":
				hint_text = "按E切换电源"
			elif element.name == "Lever":
				hint_text = "按E拉动拉杆"
			_game_hud.show_interaction_hint(hint_text)

## 与元素交互
func _interact_with_element(element: Area3D) -> void:
	if element.name == "PowerSwitch":
		_toggle_power()
	elif element.name == "Lever":
		_activate_lever()

## 切换电源
func _toggle_power() -> void:
	_power_enabled = not _power_enabled
	print("[Factory] 电源切换: " + str(_power_enabled))

	# 调整灯光效果
	for light in _flickering_lights:
		if _power_enabled:
			light.light_energy = randf_range(0.8, 1.2)
		else:
			light.light_energy = 0.1

	# 显示HUD消息
	if _game_hud and _game_hud.has_method("show_message"):
		if _power_enabled:
			_game_hud.show_message("电源已开启")
		else:
			_game_hud.show_message("电源已关闭 - 应急灯启动")

## 激活拉杆
func _activate_lever() -> void:
	if not _lever_activated:
		_lever_activated = true
		print("[Factory] 拉杆已激活")

		# 特殊效果：解锁隐藏宝箱或开启通道
		# 这里可以触发特定事件

		# 显示HUD消息
		if _game_hud and _game_hud.has_method("show_message"):
			_game_hud.show_message("拉杆已激活 - 隐藏通道已开启")

## 更新暗角效果
func _update_vignette_effect() -> void:
	if not vignette_overlay or not player:
		return

	var mat: ShaderMaterial = vignette_overlay.material as ShaderMaterial
	if mat:
		# 基于玩家位置动态调整暗角强度
		# 在BOSS房间附近增强效果
		var player_z: float = player.position.z
		var intensity: float = 0.7

		if player_z < -15:
			# BOSS房间区域 - 更强的暗角
			intensity = 0.85
		elif player_z < -10:
			# 中等危险区域
			intensity = 0.75
		elif player_z > 10:
			# 入口区域 - 较弱暗角
			intensity = 0.6

		# 如果在危险区域，增加暗角效果
		if _player_in_hazard.size() > 0:
			intensity += 0.1

		mat.set_shader_parameter("vignette_intensity", intensity)

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
	BgmManager.stop_bgm()
	GameData.game_flags["battle_area"] = "factory"
	GameFlow.enter_battle()