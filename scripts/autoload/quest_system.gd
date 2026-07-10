extends Node
## 任务系统 (QuestSystem)
## 管理主线和支线任务
## 作为 Autoload 单例运行

## 任务状态
enum QuestStatus {
	LOCKED,      ## 未解锁
	AVAILABLE,   ## 可接取
	ACTIVE,      ## 进行中
	COMPLETED,   ## 已完成
	CLAIMED,     ## 已领奖
}

## 任务数据结构
class Quest:
	var id: String
	var title: String
	var description: String
	var status: int = QuestStatus.LOCKED
	var objectives: Array = []  ## 目标列表 [{type, target, count, current}]
	var rewards: Dictionary = {}  ## 奖励 {coins, exp, items}
	var prerequisite: String = ""  ## 前置任务ID
	var auto_start: bool = false  ## 是否自动开始

## 所有任务
var quests: Dictionary = {}

## 信号
signal quest_started(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_claimed(quest_id: String)
signal objective_updated(quest_id: String, objective_index: int)

func _ready() -> void:
	_init_quests()

## 初始化任务数据
func _init_quests() -> void:
	# 主线任务1: 初次冒险
	_register_quest("q01_first_adventure", "初次冒险", "前往荒野击败5个敌人，证明你的实力。", 
		[{"type": "defeat_enemies", "target": "any", "count": 5, "current": 0}],
		{"coins": 200, "exp": 50}, "", true)

	# 主线任务2: 工厂危机
	_register_quest("q02_factory_crisis", "工厂危机", "废弃工厂中的失控坦克威胁着周边安全。击败它！",
		[{"type": "defeat_bounty", "target": "b02_mad_tank", "count": 1, "current": 0}],
		{"coins": 1500, "exp": 200}, "q01_first_adventure")

	# 主线任务3: 蚁穴清剿
	_register_quest("q03_ant_nest", "蚁穴清剿", "蚂蚁巢穴的蚁后变得异常暴躁。消灭它！",
		[{"type": "defeat_bounty", "target": "b03_ant_queen", "count": 1, "current": 0}],
		{"coins": 800, "exp": 150}, "q02_factory_crisis")

	# 主线任务4: 遗迹探索
	_register_quest("q04_ancient_ruins", "遗迹探索", "探索古代遗迹，消灭不定形生命体。",
		[{"type": "defeat_bounty", "target": "b04_amorphous", "count": 1, "current": 0}],
		{"coins": 1200, "exp": 300}, "q03_ant_nest")

	# 支线任务1: 收集者
	_register_quest("s01_collector", "收集者", "收集3个宝箱中的物品。",
		[{"type": "open_chests", "target": "any", "count": 3, "current": 0}],
		{"coins": 300, "exp": 30}, "q01_first_adventure")

	# 支线任务2: 战车改装
	_register_quest("s02_tank_upgrade", "战车改装", "在战车改造厂升级一次战车装备。",
		[{"type": "upgrade_tank", "target": "any", "count": 1, "current": 0}],
		{"coins": 500, "exp": 50}, "q02_factory_crisis")

	# 检查自动开始的任务
	_check_auto_start()

## 注册任务
func _register_quest(qid: String, qtitle: String, qdesc: String, objectives: Array, rewards: Dictionary, prereq: String, auto_start: bool = false) -> void:
	var quest := Quest.new()
	quest.id = qid
	quest.title = qtitle
	quest.description = qdesc
	quest.objectives = objectives
	quest.rewards = rewards
	quest.prerequisite = prereq
	quest.auto_start = auto_start
	quests[qid] = quest

## 检查自动开始的任务
func _check_auto_start() -> void:
	for quest in quests.values():
		if quest.auto_start and quest.status == QuestStatus.LOCKED:
			if quest.prerequisite.is_empty() or is_quest_completed(quest.prerequisite):
				quest.status = QuestStatus.ACTIVE
				quest_started.emit(quest.id)

## 检查任务是否完成
func is_quest_completed(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	return quests[quest_id].status == QuestStatus.COMPLETED or quests[quest_id].status == QuestStatus.CLAIMED

## 更新任务目标进度
func update_objective(objective_type: String, target: String, amount: int = 1) -> void:
	for quest in quests.values():
		if quest.status != QuestStatus.ACTIVE:
			continue
		for i in range(quest.objectives.size()):
			var obj = quest.objectives[i]
			if obj.type == objective_type:
				if target == "any" or obj.target == target:
					obj.current = min(obj.count, obj.current + amount)
					objective_updated.emit(quest.id, i)
					# 检查是否所有目标完成
					if _check_quest_complete(quest):
						quest.status = QuestStatus.COMPLETED
						quest_completed.emit(quest.id)
						print("[QuestSystem] 任务完成: " + quest.title)

## 检查任务是否所有目标完成
func _check_quest_complete(quest) -> bool:
	for obj in quest.objectives:
		if obj.current < obj.count:
			return false
	return true

## 领取任务奖励
func claim_reward(quest_id: String) -> void:
	if not quests.has(quest_id):
		return
	var quest = quests[quest_id]
	if quest.status != QuestStatus.COMPLETED:
		return

	# 发放奖励
	if quest.rewards.has("coins"):
		GameData.coins += quest.rewards["coins"]
		GameData.coins_changed.emit(GameData.coins)
	if quest.rewards.has("exp"):
		for member in GameData.party:
			LevelUpSystem.add_exp(member, quest.rewards["exp"])

	quest.status = QuestStatus.CLAIMED
	quest_claimed.emit(quest_id)
	print("[QuestSystem] 领取奖励: " + quest.title)

	# 解锁后续任务
	_unlock_following_quests(quest_id)

## 解锁后续任务
func _unlock_following_quests(quest_id: String) -> void:
	for quest in quests.values():
		if quest.prerequisite == quest_id and quest.status == QuestStatus.LOCKED:
			quest.status = QuestStatus.AVAILABLE
			# 自动开始
			quest.status = QuestStatus.ACTIVE
			quest_started.emit(quest.id)
			print("[QuestSystem] 新任务开始: " + quest.title)

## 获取进行中的任务列表
func get_active_quests() -> Array:
	var result = []
	for quest in quests.values():
		if quest.status == QuestStatus.ACTIVE:
			result.append(quest)
	return result

## 获取已完成未领奖的任务
func get_completed_quests() -> Array:
	var result = []
	for quest in quests.values():
		if quest.status == QuestStatus.COMPLETED:
			result.append(quest)
	return result

## 获取任务进度文本
func get_quest_progress(quest_id: String) -> String:
	if not quests.has(quest_id):
		return ""
	var quest = quests[quest_id]
	var text = quest.title + "\n" + quest.description + "\n"
	for obj in quest.objectives:
		text += "  %d/%d\n" % [obj.current, obj.count]
	return text
