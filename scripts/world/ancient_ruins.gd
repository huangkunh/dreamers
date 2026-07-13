extends Node3D
## 古代遗迹 (AncientRuins)
## 第三个迷宫关卡，高级区域，包含:
## - 旧文明地下研究所环境（诺亚超级计算机遗迹）
## - 强力敌人随机遇敌（古代守卫、全息守卫）
## - BOSS战 (不定形 - 赏金首b04, 诺亚化身 - 赏金首b07)
## - 宝箱奖励（高级古代科技装备）
## - 隐藏房间（诺亚核心数据室）
## - 环境谜题（能量终端解谜）
## - HD-2D后处理效果

const NPC_SCENE := preload("res://scenes/characters/npc/npc.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")
const TREASURE_CHEST_SCRIPT := preload("res://scripts/components/treasure_chest.gd")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player
@onready var vignette_overlay: ColorRect = $VignetteOverlay

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败不定形BOSS
var _boss_defeated: bool = false
## 是否已击败诺亚化身BOSS
var _noah_defeated: bool = false
## 入口NPC (古代AI全息影像)
var _entry_npc: CharacterBody3D
## BOSS触发器 (不定形)
var _boss_trigger: Area3D
## 诺亚BOSS触发器
var _noah_trigger: Area3D
## 游戏内HUD
var _game_hud: Control
## 宝箱列表
var _chests: Array = []

## 闪烁灯光列表
var _flickering_lights: Array[OmniLight3D] = []
## 全息显示灯光列表
var _hologram_lights: Array[OmniLight3D] = []
## 能量核心灯光列表
var _energy_core_lights: Array[OmniLight3D] = []

## 灯光闪烁计时器
var _flicker_timer: float = 0.0
## 全息脉冲计时器
var _hologram_timer: float = 0.0
## 能量脉冲计时器
var _energy_pulse_timer: float = 0.0

## 交互元素列表
var _interactive_elements: Array[Area3D] = []
## 当前交互提示
var _current_interaction: String = ""

## 谜题状态
var _terminal_solved: Dictionary = {
	"terminal1": false,
	"terminal2": false,
	"terminal3": false,
}
var _puzzle_complete: bool = false
var _energy_enabled: bool = true
var _hidden_room_unlocked: bool = false

## 诺亚相关文本
const NOAH_MESSAGES: Array[String] = [
	"「诺亚」- 旧文明超级计算机",
	"大破坏... 是为了拯救人类...",
	"人类已经无法自我管理...",
	"必须重置这个世界...",
	"我是诺亚... 观察者... 审判者...",
]

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
	_create_noah_trigger()

	# 创建宝箱
	_create_chests()

	# 初始化灯光系统
	_setup_lighting()

	# 初始化交互元素
	_setup_interactive_elements()

	# 实例化游戏内HUD
	_game_hud = GAME_HUD_SCENE.instantiate()
	add_child(_game_hud)
	_game_hud.show_hud()
	_game_hud.set_area_name("古代遗迹 - 诺亚遗迹")

	# 检查BOSS是否已被击败
	_check_boss_status()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				GameFlow.change_scene("world_map")

	# 处理交互
	if event.is_action_pressed("interact") and not _current_interaction.is_empty():
		_trigger_interaction()

func _process(delta: float) -> void:
	# 更新灯光效果
	_update_flickering_lights(delta)
	_update_hologram_lights(delta)
	_update_energy_pulse(delta)

	# 更新暗角效果（基于玩家位置）
	_update_vignette_effect()

	# 检测交互元素
	_check_interactive_elements()

## 检查BOSS状态
func _check_boss_status() -> void:
	# 检查不定形
	if BountySystem.bounties.has("b04_amorphous"):
		var bounty = BountySystem.bounties["b04_amorphous"]
		if bounty.status == BountySystem.BountyStatus.CLAIMED:
			_boss_defeated = true
			print("[AncientRuins] 不定形BOSS已被击败")

	# 检查诺亚化身
	if BountySystem.bounties.has("b07_noah_avatar"):
		var bounty = BountySystem.bounties["b07_noah_avatar"]
		if bounty.status == BountySystem.BountyStatus.CLAIMED:
			_noah_defeated = true
			print("[AncientRuins] 诺亚化身BOSS已被击败")

	# 解锁诺亚BOSS（如果击败了不定形）
	if _boss_defeated and not _noah_defeated:
		BountySystem.unlock_bounty("b07_noah_avatar")
		print("[AncientRuins] 诺亚化身BOSS已解锁!")

## 创建入口NPC (古代AI全息影像)
func _create_entry_npc() -> void:
	_entry_npc = NPC_SCENE.instantiate()
	_entry_npc.npc_id = "ancient_ai"
	_entry_npc.npc_area = "ancient_ruins"
	_entry_npc.display_name = "诺亚终端"
	_entry_npc.position = Vector3(0, 0, 10)
	add_child(_entry_npc)

## 创建不定形BOSS触发区域
func _create_boss_trigger() -> void:
	if _boss_defeated:
		return

	_boss_trigger = Area3D.new()
	_boss_trigger.position = Vector3(0, 0, -20)

	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(8, 4, 8)
	collision.shape = box
	_boss_trigger.add_child(collision)

	# 可视化标记 (青色 - 古代科技)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(8, 4, 0.2)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, 2, -4)
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

## 创建诺亚化身BOSS触发区域
func _create_noah_trigger() -> void:
	# 诺亚需要先击败不定形才能触发
	if not _boss_defeated:
		return

	if _noah_defeated:
		return

	_noah_trigger = Area3D.new()
	_noah_trigger.position = Vector3(0, 0, -38)

	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(10, 5, 10)
	collision.shape = box
	_noah_trigger.add_child(collision)

	# 可视化标记 (紫色 - 诺亚核心)
	var mesh := BoxMesh.new()
	mesh.size = Vector3(10, 5, 0.2)
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.position = Vector3(0, 2.5, -5)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.1, 0.8, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.emission_enabled = true
	mat.emission = Color(0.5, 0.2, 1.0)
	mat.emission_energy_multiplier = 0.8
	mi.material_override = mat
	_noah_trigger.add_child(mi)

	_noah_trigger.body_entered.connect(_on_noah_trigger_entered)
	add_child(_noah_trigger)

## 创建宝箱
func _create_chests() -> void:
	# 宝箱1: 金币奖励 (入口附近)
	_create_chest("ruins_chest_1", Vector3(-8, 0, 5), 0, "800", 1, "古代金币箱")

	# 宝箱2: 全恢复 (中段)
	_create_chest("ruins_chest_2", Vector3(8, 0, -8), 4, "", 1, "能量恢复装置")

	# 宝箱3: 古代科技材料
	_create_chest("ruins_chest_3", Vector3(-25, 0, -15), 1, "ancient_circuit", 1, "科技材料箱")

	# 宝箱4: 高级武器配件 (BOSS房附近)
	_create_chest("ruins_chest_4", Vector3(15, 0, -30), 2, "plasma_core", 1, "等离子核心")

	# 宝箱5: 隐藏房间宝箱
	_create_chest("ruins_chest_5", Vector3(-42, 0, -25), 3, "noah_key_fragment", 1, "诺亚数据碎片")

	# 宝箱6: 稀有装备 (能量核心附近)
	_create_chest("ruins_chest_6", Vector3(0, 0, -35), 2, "energy_shield", 1, "能量护盾")

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

## 初始化灯光系统
func _setup_lighting() -> void:
	var lighting_node = $AtmosphericLighting
	if lighting_node:
		for child in lighting_node.get_children():
			if child is OmniLight3D:
				if child.name.begins_with("Flickering"):
					_flickering_lights.append(child)
				elif child.name.begins_with("Hologram") or child.name.begins_with("Terminal"):
					_hologram_lights.append(child)
				elif child.name.begins_with("Altar") or child.name.begins_with("Energy"):
					_energy_core_lights.append(child)

## 更新闪烁灯光效果
func _update_flickering_lights(delta: float) -> void:
	_flicker_timer += delta

	for light in _flickering_lights:
		if randf() < 0.03:
			# 临时关闭
			light.light_energy = 0.0
		elif randf() < 0.08:
			# 强光闪烁
			light.light_energy = randf_range(1.5, 2.2)
		else:
			# 正常亮度（带小波动）
			var base_energy: float = 1.0
			light.light_energy = base_energy + randf_range(-0.15, 0.15)

## 更新全息显示灯光效果
func _update_hologram_lights(delta: float) -> void:
	_hologram_timer += delta

	# 全息脉冲周期约3秒
	var pulse: float = sin(_hologram_timer * 2.0) * 0.5 + 0.5

	for light in _hologram_lights:
		if _energy_enabled:
			light.light_energy = 1.5 + pulse * 0.8
		else:
			light.light_energy = 0.3 + pulse * 0.2

## 更新能量核心脉冲效果
func _update_energy_pulse(delta: float) -> void:
	_energy_pulse_timer += delta

	# 能量核心脉冲周期约4秒
	var pulse: float = sin(_energy_pulse_timer * 1.5) * 0.5 + 0.5

	for light in _energy_core_lights:
		light.light_energy = 2.5 + pulse * 1.5

	# 诺亚核心特殊效果（紫色脉冲）
	if _noah_trigger and not _noah_defeated:
		var noah_pulse = sin(_energy_pulse_timer * 3.0) * 0.5 + 0.5
		var boss_light = $BossArea/BossLight1
		if boss_light:
			boss_light.light_energy = 3.0 + noah_pulse * 2.0

## 初始化交互元素
func _setup_interactive_elements() -> void:
	var interactive_node = $InteractiveElements
	if interactive_node:
		for child in interactive_node.get_children():
			if child is Area3D:
				_interactive_elements.append(child)

## 检测交互元素
func _check_interactive_elements() -> void:
	if not player:
		return

	_current_interaction = ""

	for element in _interactive_elements:
		var overlapping_bodies = element.get_overlapping_bodies()
		for body in overlapping_bodies:
			if body.is_in_group("player"):
				# 根据元素名称设置交互提示
				_set_interaction_hint(element)
				return

## 设置交互提示
func _set_interaction_hint(element: Area3D) -> void:
	if element.name == "AncientTerminal1":
		if not _terminal_solved["terminal1"]:
			_current_interaction = "terminal1"
			_show_hint("按 E 激活古代终端 #1")
		else:
			_show_hint("终端已激活")
	elif element.name == "AncientTerminal2":
		if not _terminal_solved["terminal2"]:
			_current_interaction = "terminal2"
			_show_hint("按 E 激活古代终端 #2")
		else:
			_show_hint("终端已激活")
	elif element.name == "HologramDisplay":
		_current_interaction = "hologram"
		_show_hint("按 E 查看诺亚记录")
	elif element.name == "EnergySwitch":
		_current_interaction = "switch"
		_show_hint("按 E 切换能量系统")
	elif element.name == "PuzzleConsole":
		if _puzzle_complete:
			_current_interaction = "noah_console"
			_show_hint("按 E 访问诺亚核心")
		else:
			_show_hint("需要激活所有终端: %d/3" % [_get_solved_terminal_count()])

## 显示提示
func _show_hint(text: String) -> void:
	if _game_hud and _game_hud.has_method("show_interaction_hint"):
		_game_hud.show_interaction_hint(text)

## 触发交互
func _trigger_interaction() -> void:
	match _current_interaction:
		"terminal1":
			_activate_terminal("terminal1")
		"terminal2":
			_activate_terminal("terminal2")
		"hologram":
			_view_hologram_display()
		"switch":
			_toggle_energy_switch()
		"noah_console":
			_access_noah_console()

## 激活终端
func _activate_terminal(terminal_id: String) -> void:
	if _terminal_solved[terminal_id]:
		return

	_terminal_solved[terminal_id] = true
	print("[AncientRuins] 终端已激活: " + terminal_id)

	# 显示激活效果
	_show_terminal_activation_effect(terminal_id)

	# 检查是否完成所有谜题
	_check_puzzle_completion()

## 显示终端激活效果
func _show_terminal_activation_effect(terminal_id: String) -> void:
	if _game_hud and _game_hud.has_method("show_message"):
		_game_hud.show_message("终端激活成功 - 诺亚数据流已连接")

	# 播放音效（如果有）
	# SfxManager.play("terminal_activate")

## 获取已解决终端数量
func _get_solved_terminal_count() -> int:
	var count: int = 0
	for solved in _terminal_solved.values():
		if solved:
			count += 1
	return count

## 检查谜题完成
func _check_puzzle_completion() -> void:
	var solved_count = _get_solved_terminal_count()
	if solved_count >= 3 and not _puzzle_complete:
		_puzzle_complete = true
		print("[AncientRuins] 谜题完成! 诺亚核心已解锁!")

		if _game_hud and _game_hud.has_method("show_message"):
			_game_hud.show_message("所有终端已激活 - 诺亚核心已解锁!")

		# 解锁隐藏房间
		_unlock_hidden_room()

## 解锁隐藏房间
func _unlock_hidden_room() -> void:
	if _hidden_room_unlocked:
		return

	_hidden_room_unlocked = true

	# 隐藏墙壁移除效果
	var hidden_wall = $HiddenRoom/HiddenWall
	if hidden_wall:
		var tw := create_tween()
		tw.tween_property(hidden_wall, "transparency", 1.0, 1.0)
		await tw.finished
		hidden_wall.queue_free()

	print("[AncientRuins] 隐藏房间已解锁!")

## 查看全息显示
func _view_hologram_display() -> void:
	if _game_hud and _game_hud.has_method("show_message"):
		# 随机显示诺亚消息
		var msg = NOAH_MESSAGES[randi() % NOAH_MESSAGES.size()]
		_game_hud.show_message(msg)

## 切换能量开关
func _toggle_energy_switch() -> void:
	_energy_enabled = not _energy_enabled
	print("[AncientRuins] 能量系统: " + ("开启" if _energy_enabled else "关闭"))

	if _game_hud and _game_hud.has_method("show_message"):
		if _energy_enabled:
			_game_hud.show_message("能量系统已激活")
		else:
			_game_hud.show_message("能量系统已关闭 - 进入节能模式")

## 访问诺亚控制台
func _access_noah_console() -> void:
	if _game_hud and _game_hud.has_method("show_message"):
		_game_hud.show_message("「诺亚核心」 - 大破坏的主谋者...")

	# 解锁诺亚BOSS（如果尚未解锁）
	if BountySystem.bounties.has("b07_noah_avatar"):
		var bounty = BountySystem.bounties["b07_noah_avatar"]
		if bounty.status == BountySystem.BountyStatus.LOCKED:
			BountySystem.unlock_bounty("b07_noah_avatar")

## 更新暗角效果
func _update_vignette_effect() -> void:
	if not vignette_overlay or not player:
		return

	var mat: ShaderMaterial = vignette_overlay.material as ShaderMaterial
	if mat:
		# 基于玩家位置动态调整暗角强度
		var player_z: float = player.position.z
		var intensity: float = 0.75

		if player_z < -35:
			# 诺亚核心区域 - 最强暗角
			intensity = 0.92
		elif player_z < -25:
			# BOSS房间区域 - 强暗角
			intensity = 0.85
		elif player_z < -15:
			# 中等危险区域
			intensity = 0.80
		elif player_z > 5:
			# 入口区域 - 较弱暗角
			intensity = 0.65

		mat.set_shader_parameter("vignette_intensity", intensity)

## 不定形BOSS触发
func _on_boss_trigger_entered(body: Node) -> void:
	if body.is_in_group("player") and not _boss_defeated:
		print("[AncientRuins] 触发不定形BOSS战!")
		GameData.game_flags["boss_battle"] = "b04_amorphous"
		GameData.game_flags["battle_area"] = "ancient_ruins"
		GameFlow.enter_battle()

## 诺亚化身BOSS触发
func _on_noah_trigger_entered(body: Node) -> void:
	if body.is_in_group("player") and not _noah_defeated and _boss_defeated:
		print("[AncientRuins] 触发诺亚化身BOSS战!")
		GameData.game_flags["boss_battle"] = "b07_noah_avatar"
		GameData.game_flags["battle_area"] = "ancient_ruins"
		GameFlow.enter_battle()

## 遇敌回调
func _on_encounter() -> void:
	print("[AncientRuins] 遭遇古代守卫!")
	BgmManager.stop_bgm()
	GameData.game_flags["battle_area"] = "ancient_ruins"
	GameFlow.enter_battle()