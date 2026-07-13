extends Node
## 猎人等级系统 (HunterRankSystem)
## Metal Max原作特色: 猎人等级影响可接取的任务和商店折扣
## 等级提升通过击败赏金首和完成任务

## 猎人等级
enum HunterRank {
	F,  ## 最低等级 (初始)
	E,
	D,
	C,
	B,
	A,
	S,  ## 最高等级 (传奇猎人)
}

## 当前猎人等级
var current_rank: int = HunterRank.F

## 猎人点数 (通过击败赏金首/完成任务获得)
var hunter_points: int = 0

## 等级配置
const RANK_CONFIG := {
	HunterRank.F: {"name": "F级猎人", "points_needed": 0, "shop_discount": 0.0, "quest_unlock": []},
	HunterRank.E: {"name": "E级猎人", "points_needed": 50, "shop_discount": 0.05, "quest_unlock": ["q02_factory_crisis"]},
	HunterRank.D: {"name": "D级猎人", "points_needed": 150, "shop_discount": 0.10, "quest_unlock": ["q03_ant_nest"]},
	HunterRank.C: {"name": "C级猎人", "points_needed": 300, "shop_discount": 0.15, "quest_unlock": ["q04_ruins_exploration"]},
	HunterRank.B: {"name": "B级猎人", "points_needed": 500, "shop_discount": 0.20, "quest_unlock": []},
	HunterRank.A: {"name": "A级猎人", "points_needed": 800, "shop_discount": 0.25, "quest_unlock": []},
	HunterRank.S: {"name": "S级猎人", "points_needed": 1200, "shop_discount": 0.30, "quest_unlock": []},
}

## 信号
signal rank_up(new_rank: int)
signal points_changed(points: int)

## 添加猎人点数
func add_points(points: int) -> void:
	hunter_points += points
	points_changed.emit(hunter_points)
	print("[HunterRank] 获得 %d 猎人点数 (当前: %d)" % [points, hunter_points])

	# 检查是否升级
	_check_rank_up()

## 检查升级
func _check_rank_up() -> void:
	var old_rank = current_rank
	for rank in [HunterRank.S, HunterRank.A, HunterRank.B, HunterRank.C, HunterRank.D, HunterRank.E, HunterRank.F]:
		var config = RANK_CONFIG[rank]
		if hunter_points >= config.points_needed:
			if current_rank < rank:
				current_rank = rank
				rank_up.emit(current_rank)
				print("[HunterRank] 猎人等级提升! -> " + get_rank_name())
				# 解锁任务
				for quest_id in config.quest_unlock:
					GameData.game_flags["quest_unlocked_" + quest_id] = true
			break

## 获取当前等级名称
func get_rank_name() -> String:
	return RANK_CONFIG.get(current_rank, {}).get("name", "未知")

## 获取商店折扣
func get_shop_discount() -> float:
	return RANK_CONFIG.get(current_rank, {}).get("shop_discount", 0.0)

## 获取折扣后价格
func get_discounted_price(original_price: int) -> int:
	var discount = get_shop_discount()
	return int(original_price * (1.0 - discount))

## 获取升级进度 (0-1)
func get_rank_progress() -> float:
	var current_config = RANK_CONFIG[current_rank]
	var current_needed = current_config.points_needed

	# 找到下一级
	var next_rank = current_rank + 1
	if next_rank > HunterRank.S:
		return 1.0  ## 已满级

	var next_config = RANK_CONFIG[next_rank]
	var next_needed = next_config.points_needed

	var progress = float(hunter_points - current_needed) / float(next_needed - current_needed)
	return clamp(progress, 0.0, 1.0)

## 获取下一级需要的点数
func get_points_to_next_rank() -> int:
	var next_rank = current_rank + 1
	if next_rank > HunterRank.S:
		return 0  ## 已满级

	var next_needed = RANK_CONFIG[next_rank].points_needed
	return max(0, next_needed - hunter_points)

## 获取所有等级信息 (用于UI显示)
func get_all_ranks_info() -> Array:
	var result = []
	for rank in [HunterRank.F, HunterRank.E, HunterRank.D, HunterRank.C, HunterRank.B, HunterRank.A, HunterRank.S]:
		var config = RANK_CONFIG[rank]
		result.append({
			"rank": rank,
			"name": config.name,
			"points_needed": config.points_needed,
			"shop_discount": config.shop_discount,
			"unlocked": rank <= current_rank,
			"current": rank == current_rank,
		})
	return result

## 击败赏金首时调用
func on_bounty_defeated(bounty_difficulty: int) -> void:
	# 难度越高，点数越多
	var points = 20 + bounty_difficulty * 15
	add_points(points)

## 完成任务时调用
func on_quest_completed(quest_difficulty: int) -> void:
	var points = 10 + quest_difficulty * 5
	add_points(points)
