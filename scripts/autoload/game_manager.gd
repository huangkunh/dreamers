extends Node
## 游戏管理器 (GameManager)
## 统一管理游戏初始化、玩家数据初始化、全局事件
## 作为 Autoload 单例运行

signal game_initialized()

## 游戏配置
const STARTING_COINS: int = 500
const STARTING_HP: int = 200

func _ready() -> void:
	# 初始化游戏数据
	_init_game_data()
	print("[GameManager] 游戏数据初始化完成")

## 初始化游戏数据 (新游戏时调用)
func _init_game_data() -> void:
	# 初始化玩家队伍
	if GameData.party.is_empty():
		var player: GameData.PartyMember = GameData.PartyMember.new()
		player.id = "ray_ban_na"
		player.name = "雷班纳"
		player.level = 1
		player.max_hp = STARTING_HP
		player.current_hp = STARTING_HP - 1
		player.current_exp = 0
		player.max_exp = 55
		player.attack = 10
		player.defense = 5
		player.speed = 3
		GameData.party.append(player)

	# 初始化金币
	if GameData.coins == 0:
		GameData.coins = STARTING_COINS

	# 初始化战车 — TankSystem 已在 _ready() 中初始化 red_wolf
	# 确保玩家拥有初始战车
	if TankSystem.tanks.has("red_wolf"):
		TankSystem.tanks["red_wolf"].is_owned = true

	# 初始化游戏标志
	if GameData.game_flags.is_empty():
		GameData.game_flags = {
			"current_area": "aoduo",
			"tutorial_done": false,
			"first_battle": false,
			"battles_won": 0,
		}

	game_initialized.emit()

## 开始新游戏
func start_new_game() -> void:
	# 重置所有数据
	GameData.party.clear()
	GameData.inventory.clear()
	GameData.coins = 0
	GameData.play_time = 0.0
	GameData.game_flags.clear()
	TankSystem.tanks.clear()

	# 初始化
	_init_game_data()

	# 切换到世界地图
	GameFlow.start_new_game()

## 获取当前区域ID
func get_current_area() -> String:
	return GameData.game_flags.get("current_area", "aoduo")

## 设置当前区域
func set_current_area(area_id: String) -> void:
	GameData.game_flags["current_area"] = area_id

## 增加战斗胜场
func record_battle_won() -> void:
	var won: int = GameData.game_flags.get("battles_won", 0)
	GameData.game_flags["battles_won"] = won + 1
