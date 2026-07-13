extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市/迷宫探索：随机遇敌、暂停菜单、战车切换、NPC交互、对话、商店
## 附加到城市场景的根节点下

const PAUSE_MENU_SCENE := preload("res://scenes/ui/pause_menu.tscn")
const TANK_HUD_SCENE := preload("res://scenes/ui/tank_hud.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/dialogue_box.tscn")
const SHOP_SCENE := preload("res://scenes/ui/shop_system.tscn")
const TANK_GARAGE_SCENE := preload("res://scenes/ui/tank_garage.tscn")
const BOUNTY_GUILD_SCENE := preload("res://scenes/ui/bounty_guild.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

var _encounter_system: Node
var _pause_menu: Control
var _tank_hud: Control
var _dialogue_box: Control
var _shop_system: Control
var _tank_garage: Control
var _bounty_guild: Control
var _game_hud: Control
var _in_tank: bool = false
var _nearby_npc: Node = null
var _is_ui_open: bool = false
var _is_playing_opening: bool = false
var area_id: String = "aoduo"

func _ready() -> void:
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY

	# 设置区域ID
	area_id = GameManager.get_current_area()

	# 播放区域BGM
	BgmManager.play_area_bgm(area_id)

	# 设置区域访问标志 (用于解锁后续区域和快速旅行)
	GameData.game_flags[area_id + "_visited"] = true

	# 检查探索成就
	AchievementSystem.check_explore_achievements(area_id)

	# 添加随机遇敌系统到玩家
	if player:
		var encounter_script = load("res://scripts/system/random_encounter.gd")
		_encounter_system = encounter_script.new()
		_encounter_system.encounter_rate = 0.015 if area_id != "factory" else 0.025
		_encounter_system.area_id = area_id
		_encounter_system.encounter_triggered.connect(_on_encounter)
		player.add_child(_encounter_system)

	# 实例化暂停菜单
	_pause_menu = PAUSE_MENU_SCENE.instantiate()
	add_child(_pause_menu)

	# 实例化对话框
	_dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
	add_child(_dialogue_box)
	DialogueManager.set_dialogue_box(_dialogue_box)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	DialogueManager.event_triggered.connect(_on_dialogue_event)

	# 实例化战车HUD
	_tank_hud = TANK_HUD_SCENE.instantiate()
	add_child(_tank_hud)

	# 实例化游戏HUD (HP/金币/区域/时间)
	_game_hud = GAME_HUD_SCENE.instantiate()
	add_child(_game_hud)
	_game_hud.show_hud()
	_game_hud.set_area_name(_get_area_display_name(area_id))

	# 检查是否需要播放开场剧情
	if GameData.game_flags.get("play_opening", false):
		GameData.game_flags.erase("play_opening")
		_play_opening_dialogue()

func _exit_tree() -> void:
	if _game_hud:
		_game_hud.hide_hud()

func _process(delta: float) -> void:
	# 更新游戏时间
	if not get_tree().paused:
		GameData.play_time += delta

func _unhandled_input(event: InputEvent) -> void:
	if _is_ui_open:
		return

	# 暂停菜单
	if event.is_action_pressed("menu"):
		if _pause_menu and not _pause_menu.visible:
			_pause_menu.open()
		get_viewport().set_input_as_handled()

	# ESC返回世界地图
	if event.is_action_pressed("ui_cancel"):
		if _pause_menu and _pause_menu.visible:
			_pause_menu.close()
		else:
			GameFlow.return_to_world_map()
		get_viewport().set_input_as_handled()

	# 战车切换
	if event.is_action_pressed("tank_toggle"):
		_toggle_tank()

	# NPC交互
	if event.is_action_pressed("interact"):
		if _nearby_npc:
			_interact_with_npc(_nearby_npc)

## 设置附近NPC
func set_nearby_npc(npc: Node) -> void:
	_nearby_npc = npc

## 清除附近NPC
func clear_nearby_npc() -> void:
	_nearby_npc = null

## 与NPC交互
func _interact_with_npc(npc: Node) -> void:
	# 检查是否是 NPCInteractable 组件
	if npc.has_method("interact"):
		_is_ui_open = true
		npc.interact()
		return

	# 旧版 NPC 节点 (通过 metadata 存储信息)
	var npc_id = npc.get_meta("npc_id", "")
	var npc_area = npc.get_meta("area_id", "aoduo")
	var shop_id = npc.get_meta("shop_id", "")

	if not shop_id.is_empty():
		_open_shop(shop_id)
		return

	# 使用 NPCData 获取对话
	var npc_data = NPCData.get_npc_dialog(npc_area, npc_id)
	if npc_data.is_empty():
		print("[CityExplorer] NPC对话数据为空: ", npc_id)
		return

	# 将对话加入 DialogueManager
	var dialog_queue: Array = []
	for d in npc_data.get("dialogs", []):
		dialog_queue.append({
			"speaker": d.get("name", ""),
			"text": d.get("text", "")
		})

	if dialog_queue.size() > 0:
		_is_ui_open = true
		DialogueManager.start_dialogue_queue(dialog_queue)

## 播放开场剧情
func _play_opening_dialogue() -> void:
	_is_playing_opening = true
	_is_ui_open = true
	get_tree().paused = true
	var dialogue_data = DialogueManager.load_dialogue_from_file("res://assets/data/dialogues/dialogue_opening.json")
	DialogueManager.start_dialogue(dialogue_data, "start")

## 对话结束回调
func _on_dialogue_finished() -> void:
	if _is_playing_opening:
		_is_playing_opening = false
		get_tree().paused = false
	_is_ui_open = false

## 对话事件回调
func _on_dialogue_event(event_name: String) -> void:
	print("[CityExplorer] 对话事件: ", event_name)
	match event_name:
		"heal_player":
			# 恢复玩家HP
			for member in GameData.party:
				member.current_hp = member.max_hp
			print("[CityExplorer] 玩家已恢复HP")
		"open_garage":
			_open_garage()
		"repair_tank":
			for tank in TankSystem.get_owned_tanks():
				TankSystem.repair_tank(tank.id)
		"open_bounty_list":
			_open_bounty_guild()
		"open_bounty_claim":
			_open_bounty_guild()
		"open_shop_weapon":
			_open_shop("aoduo_weapon")
			print("[CityExplorer] 打开武器店")
		"open_shop_armor":
			_open_shop("aoduo_armor")
			print("[CityExplorer] 打开防具店")
		"open_shop_item":
			_open_shop("aoduo_item")
			print("[CityExplorer] 打开道具店")
		"open_shop_accessory":
			_open_shop("aoduo_accessory")
			print("[CityExplorer] 打开饰品店")
		"give_father_item":
			# 给玩家添加父亲的徽章
			var badge := GameData.Item.new()
			badge.id = "fathers_badge"
			badge.name = "父亲的徽章"
			badge.description = "父亲留下的徽章，似乎与某段记忆有关。"
			badge.type = GameData.Item.ItemType.KEY_ITEM
			badge.price = 0
			badge.stackable = false
			GameData.key_items.append(badge)
			print("[CityExplorer] 获得关键道具: 父亲的徽章")
			# 给玩家添加初始金币 500G（如果不够的话）
			if GameData.coins < 500:
				GameData.add_coins(500 - GameData.coins)
				print("[CityExplorer] 获得初始金币: 500G")
			# 解锁第一辆战车（红色野狼）
			if TankSystem.tanks.has("red_wolf"):
				TankSystem.tanks["red_wolf"].is_owned = true
				print("[CityExplorer] 解锁战车: 红色野狼")
		"opening_finished":
			# 设置开场剧情结束标志
			GameData.game_flags["opening_done"] = true
			print("[CityExplorer] 开场剧情结束")
			# 设置当前区域为 aoduo
			GameManager.set_current_area("aoduo")
			area_id = "aoduo"
			print("[CityExplorer] 当前区域设置为: 奥多市")
			# 确保玩家初始状态正确
			for member in GameData.party:
				if member.current_hp <= 0:
					member.current_hp = member.max_hp
			print("[CityExplorer] 玩家初始状态已确认")
		"rest_inn":
			# 扣除 20G
			if GameData.spend_coins(20):
				print("[CityExplorer] 住宿花费 20G")
				# 恢复所有队员HP
				for member in GameData.party:
					member.current_hp = member.max_hp
				print("[CityExplorer] 所有队员HP已恢复")
				# 恢复战车所有状态
				for tank in TankSystem.get_owned_tanks():
					TankSystem.resupply_tank(tank.id)
				print("[CityExplorer] 所有战车已补给")
			else:
				print("[CityExplorer] 金币不足，无法住宿")
		"start_noah_battle":
			print("[CityExplorer] 触发诺亚最终BOSS战!")
			# 解锁诺亚化身赏金首状态（确保可战斗）
			BountySystem.unlock_bounty("b07_noah_avatar")
			# 设置战斗区域
			GameData.game_flags["battle_area"] = "ancient_ruins"
			GameData.game_flags["boss_battle"] = "b07_noah_avatar"
			# 进入战斗场景
			get_tree().create_timer(1.0).timeout.connect(func():
				GameFlow.enter_battle()
			)
		"noah_defeated_ending":
			print("[CityExplorer] 诺亚被击败，播放结局!")
			# 设置结局标志
			GameData.game_flags["game_cleared"] = true
			GameData.game_flags["ending_type"] = "good"
			# 解锁全成就
			AchievementSystem.check_explore_achievements("ancient_ruins")
			# 播放结局后延迟返回标题
			get_tree().create_timer(5.0).timeout.connect(func():
				GameFlow.change_scene("res://scenes/ui/title_screen.tscn")
			)
		"unlock_noah":
			# 解锁最终BOSS诺亚
			BountySystem.unlock_bounty("b07_noah_avatar")
			print("[CityExplorer] 最终BOSS诺亚已解锁!")
		"register_hunter":
			# 猎人注册
			if GameData.game_flags.get("is_hunter_registered", false):
				print("[CityExplorer] 已经是注册猎人了")
				# 跳转已注册对话 (通过重新加载对话)
				_show_already_registered()
			elif GameData.spend_coins(100):
				GameData.game_flags["is_hunter_registered"] = true
				# 给猎人徽章
				var badge := GameData.Item.new()
				badge.id = "hunter_badge"
				badge.name = "猎人徽章"
				badge.description = "赏金猎人公会的正式徽章，猎人的身份象征。"
				badge.type = GameData.Item.ItemType.KEY_ITEM
				badge.price = 0
				badge.stackable = false
				GameData.key_items.append(badge)
				SfxManager.play_sfx("quest_complete")
				print("[CityExplorer] 注册成为猎人! 花费100G")
			else:
				print("[CityExplorer] 金币不足，无法注册")
				_show_no_money_for_register()

## 打开商店
func _open_shop(shop_id: String) -> void:
	if _shop_system and _shop_system.visible:
		return
	_shop_system = SHOP_SCENE.instantiate()
	add_child(_shop_system)
	_shop_system.open_shop(shop_id, ShopData.get_shop_items(shop_id))
	_is_ui_open = true

## 打开战车改造
func _open_garage() -> void:
	if _tank_garage and _tank_garage.visible:
		return
	_tank_garage = TANK_GARAGE_SCENE.instantiate()
	add_child(_tank_garage)
	_tank_garage.open_garage()
	_is_ui_open = true

## 打开赏金公会
func _open_bounty_guild() -> void:
	if _bounty_guild and _bounty_guild.visible:
		return
	_bounty_guild = BOUNTY_GUILD_SCENE.instantiate()
	add_child(_bounty_guild)
	_bounty_guild.open_guild()
	_is_ui_open = true

## 切换上下战车
func _toggle_tank() -> void:
	if _in_tank:
		TankSystem.exit_tank()
		_in_tank = false
		if player:
			player.in_tank = false
		print("[CityExplorer] 下车，步行模式")
	else:
		var owned = TankSystem.get_owned_tanks()
		if owned.size() > 0:
			TankSystem.enter_tank(owned[0].id)
			_in_tank = true
			if player:
				player.in_tank = true
			print("[CityExplorer] 上车，战车模式")
		else:
			print("[CityExplorer] 没有战车")

## 遇敌回调
func _on_encounter() -> void:
	if _is_ui_open:
		return
	print("[CityExplorer] 进入战斗! 区域: " + area_id)
	BgmManager.stop_bgm()
	GameData.game_flags["battle_area"] = area_id
	GameFlow.enter_battle()

## 获取区域显示名称
func _get_area_display_name(area: String) -> String:
	match area:
		"aoduo": return "奥多市"
		"wasteland": return "荒野"
		"factory": return "废弃工厂"
		"ant_nest": return "蚂蚁巢穴"
		"ancient_ruins": return "古代遗迹"
		_: return area

## 显示已注册猎人对话
func _show_already_registered() -> void:
	var dialog_queue = []
	dialog_queue.append({
		"speaker": "公会会长",
		"text": "你已经注册过了。怎么，徽章丢了？再办一个得交50G。",
		"event": ""
	})
	DialogueManager.start_dialogue_queue(dialog_queue)

## 显示金币不足对话
func _show_no_money_for_register() -> void:
	var dialog_queue = []
	dialog_queue.append({
		"speaker": "公会会长",
		"text": "钱不够？那就先去荒野打几只怪赚点本钱再来吧。",
		"event": ""
	})
	DialogueManager.start_dialogue_queue(dialog_queue)
