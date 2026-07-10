extends Node
## 成就系统 (AchievementSystem)
## 记录玩家达成的各种成就
## 作为 Autoload 单例运行

## 成就数据结构
class Achievement:
	var id: String
	var name: String
	var description: String
	var icon: String
	var unlocked: bool = false
	var unlock_time: float = 0.0
	var hidden: bool = false  ## 是否隐藏 (解锁前不显示条件)

## 所有成就
var achievements: Dictionary = {}

## 信号
signal achievement_unlocked(achievement_id: String)

func _ready() -> void:
	_init_achievements()
	# 连接全局信号
	BountySystem.bounty_defeated.connect(_on_bounty_defeated)

## 初始化成就数据
func _init_achievements() -> void:
	# 战斗类成就
	_register("first_battle", "初战告捷", "完成第一场战斗", "⚔", false)
	_register("battle_10", "身经百战", "完成10场战斗", "⚔", false)
	_register("battle_50", "战争机器", "完成50场战斗", "⚔", false)
	_register("battle_100", "百战不殆", "完成100场战斗", "⚔", false)

	# 击败类成就
	_register("defeat_10", "猎人新手", "击败10个敌人", "💀", false)
	_register("defeat_50", "赏金猎人", "击败50个敌人", "💀", false)
	_register("defeat_100", "杀戮者", "击败100个敌人", "💀", false)

	# 赏金首成就
	_register("bounty_first", "首个赏金", "击败第一个赏金首", "💰", false)
	_register("bounty_all", "赏金终结者", "击败所有赏金首", "💰", true)

	# 探索类成就
	_register("explore_factory", "工厂探险家", "探索废弃工厂", "🗺", false)
	_register("explore_ant_nest", "蚁穴冒险者", "探索蚂蚁巢穴", "🗺", false)
	_register("explore_ruins", "遗迹发现者", "探索古代遗迹", "🗺", false)
	_register("explore_all", "世界探索者", "探索所有区域", "🗺", true)

	# 宝箱类成就
	_register("chest_first", "初次发现", "打开第一个宝箱", "📦", false)
	_register("chest_all", "宝藏猎人", "打开所有宝箱", "📦", true)

	# 升级类成就
	_register("level_10", "小有成就", "达到10级", "⬆", false)
	_register("level_20", "经验丰富", "达到20级", "⬆", false)
	_register("level_30", "传奇猎人", "达到30级", "⬆", false)

	# 金币类成就
	_register("coins_1000", "小富翁", "累计获得1000金币", "💰", false)
	_register("coins_5000", "富翁", "累计获得5000金币", "💰", false)
	_register("coins_10000", "大富翁", "累计获得10000金币", "💰", false)

	# 战车类成就
	_register("tank_first", "战车驾驶员", "首次驾驶战车", "🚗", false)
	_register("tank_upgrade", "战车改装者", "升级战车装备", "🔧", false)

	# 队伍类成就
	_register("party_2", "双人组", "招募第一个队友", "👥", false)
	_register("party_full", "完整队伍", "招募所有队友", "👥", true)

	# 特殊成就
	_register("no_damage", "无伤通关", "无伤击败一个BOSS", "🛡", true)
	_register("speedrun", "速通大师", "在1小时内击败3个BOSS", "⏱", true)

## 注册成就
func _register(id: String, name: String, desc: String, icon: String, hidden: bool) -> void:
	var ach := Achievement.new()
	ach.id = id
	ach.name = name
	ach.description = desc
	ach.icon = icon
	ach.hidden = hidden
	achievements[id] = ach

## 解锁成就
func unlock(id: String) -> void:
	if not achievements.has(id):
		return
	var ach = achievements[id]
	if ach.unlocked:
		return
	ach.unlocked = true
	ach.unlock_time = GameData.play_time
	achievement_unlocked.emit(id)
	print("[Achievement] 解锁成就: " + ach.name + " (" + ach.description + ")")

## 检查并更新战斗相关成就
func check_battle_achievements() -> void:
	var battles = GameData.game_flags.get("battles_won", 0)
	if battles >= 1:
		unlock("first_battle")
	if battles >= 10:
		unlock("battle_10")
	if battles >= 50:
		unlock("battle_50")
	if battles >= 100:
		unlock("battle_100")

	if GameData.defeat_count >= 10:
		unlock("defeat_10")
	if GameData.defeat_count >= 50:
		unlock("defeat_50")
	if GameData.defeat_count >= 100:
		unlock("defeat_100")

## 赏金首击败回调
func _on_bounty_defeated(bounty_id: String) -> void:
	unlock("bounty_first")
	# 检查是否击败所有赏金首
	var all_defeated = true
	for bounty in BountySystem.bounties.values():
		if bounty.status < BountySystem.BountyStatus.DEFEATED:
			all_defeated = false
			break
	if all_defeated:
		unlock("bounty_all")

## 检查探索成就
func check_explore_achievements(area_id: String) -> void:
	match area_id:
		"factory": unlock("explore_factory")
		"ant_nest": unlock("explore_ant_nest")
		"ancient_ruins": unlock("explore_ruins")

	# 检查是否探索所有区域
	if GameData.game_flags.get("visited_factory", false) and \
	   GameData.game_flags.get("visited_ant_nest", false) and \
	   GameData.game_flags.get("visited_ancient_ruins", false):
		unlock("explore_all")

## 检查宝箱成就
func check_chest_achievements(chest_count: int) -> void:
	if chest_count >= 1:
		unlock("chest_first")
	if chest_count >= 7:  ## 总共7个宝箱
		unlock("chest_all")

## 检查升级成就
func check_level_achievements(level: int) -> void:
	if level >= 10:
		unlock("level_10")
	if level >= 20:
		unlock("level_20")
	if level >= 30:
		unlock("level_30")

## 检查金币成就
func check_coins_achievements(total_coins: int) -> void:
	if total_coins >= 1000:
		unlock("coins_1000")
	if total_coins >= 5000:
		unlock("coins_5000")
	if total_coins >= 10000:
		unlock("coins_10000")

## 获取已解锁成就数
func get_unlocked_count() -> int:
	var count = 0
	for ach in achievements.values():
		if ach.unlocked:
			count += 1
	return count

## 获取总成就数
func get_total_count() -> int:
	return achievements.size()

## 获取成就列表 (用于UI显示)
func get_achievement_list() -> Array:
	var result = []
	for ach in achievements.values():
		result.append({
			"id": ach.id,
			"name": ach.name,
			"description": ach.description if not ach.hidden or ach.unlocked else "???",
			"icon": ach.icon,
			"unlocked": ach.unlocked,
			"hidden": ach.hidden,
		})
	return result
