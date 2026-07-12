extends Node
## 升级系统 (LevelUpSystem)
## 处理角色经验值获取、升级、属性提升
## 作为工具类使用 (静态方法)

## 升级时的属性提升
const HP_PER_LEVEL := 20       ## 每级HP提升
const ATTACK_PER_LEVEL := 3    ## 每级攻击力提升
const DEFENSE_PER_LEVEL := 2   ## 每级防御力提升
const SPEED_PER_LEVEL := 1     ## 每级速度提升

## 信号
signal level_up(member_id: String, new_level: int)
signal exp_gained(member_id: String, amount: int)

func _ready() -> void:
	level_up.connect(_on_level_up_check_achievements)

## 获取升级所需经验值
## level: 当前等级
## 返回: 升到下一级所需经验
static func get_exp_for_level(level: int) -> int:
	# 经验值公式: 55 + level * 35 (递增)
	return 55 + (level - 1) * 35

## 给角色添加经验值
## member: PartyMember 对象
## amount: 经验值数量
## 返回: 是否升级
static func add_exp(member, amount: int) -> bool:
	if not member:
		return false

	member.current_exp += amount
	print("[LevelUp] %s 获得 %d 经验值 (当前: %d/%d)" % [member.name, amount, member.current_exp, member.max_exp])

	var leveled_up := false
	while member.current_exp >= member.max_exp:
		_do_level_up(member)
		leveled_up = true

	return leveled_up

## 执行升级
static func _do_level_up(member) -> void:
	member.current_exp -= member.max_exp
	member.level += 1
	member.max_exp = get_exp_for_level(member.level)

	# 属性提升
	member.max_hp += HP_PER_LEVEL
	member.current_hp = member.max_hp  # 升级回满HP
	member.attack += ATTACK_PER_LEVEL
	member.defense += DEFENSE_PER_LEVEL
	member.speed += SPEED_PER_LEVEL

	print("[LevelUp] %s 升级到 Lv.%d! HP:%d ATK:%d DEF:%d SPD:%d" % [
		member.name, member.level, member.max_hp, member.attack, member.defense, member.speed
	])

	LevelUpSystem.level_up.emit(member.id, member.level)

## 升级时检查成就
func _on_level_up_check_achievements(member_id: String, new_level: int) -> void:
	AchievementSystem.check_level_achievements(new_level)

## 获取经验值等级颜色 (用于UI显示)
static func get_level_color(level: int) -> Color:
	if level >= 20:
		return Color(1, 0.3, 0.3)  # 红色 - 高等级
	elif level >= 10:
		return Color(1, 0.85, 0.3)  # 金色 - 中等级
	else:
		return Color(0.8, 0.8, 0.8)  # 灰色 - 低等级

## 计算战斗获得的经验值
## enemy_level: 敌人等级
## enemy_count: 敌人数量
## 返回: 经验值
static func calculate_battle_exp(enemy_level: int, enemy_count: int) -> int:
	var base_exp := 10 + enemy_level * 3
	var total := base_exp * enemy_count
	# 随机浮动 ±20%
	var variance := randi_range(-2, 2)
	total += variance
	return max(5, total)

## 计算战斗获得的金币
## enemy_level: 敌人等级
## enemy_count: 敌人数量
## 返回: 金币
static func calculate_battle_coins(enemy_level: int, enemy_count: int) -> int:
	var base_coins := 8 + enemy_level * 2
	var total := base_coins * enemy_count
	var variance := randi_range(-2, 3)
	total += variance
	return max(3, total)
