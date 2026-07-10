extends Node
## 队伍管理系统 (PartyManager)
## 管理队伍成员的加入/离开/切换
## 作为 Autoload 单例运行

## 可招募的队友数据
var recruitable_characters: Dictionary = {}

## 信号
signal member_joined(member_id: String)
signal member_left(member_id: String)
signal party_changed

func _ready() -> void:
	_init_recruitable_characters()

## 初始化可招募角色
func _init_recruitable_characters() -> void:
	# 机械师 - 工厂区域招募
	recruitable_characters["mechanic_mika"] = {
		"id": "mechanic_mika",
		"name": "米卡",
		"title": "机械师",
		"description": "擅长修理战车的机械师，可以恢复战车HP。",
		"recruit_area": "factory",
		"recruit_condition": "defeat_b02_mad_tank",
		"base_stats": {
			"max_hp": 150,
			"attack": 8,
			"defense": 6,
			"speed": 5,
		},
		"skills": ["normal_attack", "repair_kit", "defend"],
		"weapon": "weapons_pistol",
		"portrait": "res://resource/sprite/battlers/fight_player.png",
	}

	# 猎人 - 荒野区域招募
	recruitable_characters["hunter_zeke"] = {
		"id": "hunter_zeke",
		"name": "泽克",
		"title": "老猎人",
		"description": "经验丰富的赏金猎人，攻击力高但防御较低。",
		"recruit_area": "wasteland",
		"recruit_condition": "defeat_5_enemies",
		"base_stats": {
			"max_hp": 180,
			"attack": 15,
			"defense": 4,
			"speed": 7,
		},
		"skills": ["normal_attack", "power_strike", "poison_dagger"],
		"weapon": "weapons_rifle",
		"portrait": "res://resource/sprite/battlers/fight_player.png",
	}

	# 医生 - 蚂蚁巢穴区域招募
	recruitable_characters["doctor_anna"] = {
		"id": "doctor_anna",
		"name": "安娜",
		"title": "流浪医生",
		"description": "能治疗队友的医生，生存能力较强。",
		"recruit_area": "ant_nest",
		"recruit_condition": "defeat_b03_ant_queen",
		"base_stats": {
			"max_hp": 160,
			"attack": 6,
			"defense": 8,
			"speed": 6,
		},
		"skills": ["normal_attack", "heal_ally", "group_heal", "defend"],
		"weapon": "weapons_slingshot",
		"portrait": "res://resource/sprite/battlers/fight_player.png",
	}

## 尝试招募角色
func try_recruit(member_id: String) -> bool:
	if not recruitable_characters.has(member_id):
		return false

	var char_data = recruitable_characters[member_id]

	# 检查是否已在队伍中
	for member in GameData.party:
		if member.id == member_id:
			return false  # 已在队伍

	# 检查招募条件
	var condition = char_data.recruit_condition
	if not condition.is_empty():
		if not GameData.game_flags.get(condition, false):
			return false  # 条件未满足

	# 创建队伍成员
	var member = GameData.PartyMember.new()
	member.id = char_data.id
	member.name = char_data.name
	member.level = 1
	member.max_hp = char_data.base_stats.max_hp
	member.current_hp = member.max_hp
	member.attack = char_data.base_stats.attack
	member.defense = char_data.base_stats.defense
	member.speed = char_data.base_stats.speed
	member.in_party = true

	# 添加技能
	for skill_id in char_data.skills:
		member.skills.append(skill_id)

	GameData.party.append(member)
	member_joined.emit(member_id)
	party_changed.emit()
	print("[PartyManager] " + char_data.name + " 加入了队伍!")
	return true

## 角色离开队伍
func remove_member(member_id: String) -> bool:
	for i in range(GameData.party.size()):
		if GameData.party[i].id == member_id:
			var member = GameData.party[i]
			GameData.party.remove_at(i)
			member_left.emit(member_id)
			party_changed.emit()
			print("[PartyManager] " + member.name + " 离开了队伍")
			return true
	return false

## 获取可招募角色列表 (按区域)
func get_recruitable_by_area(area: String) -> Array:
	var result = []
	for char_data in recruitable_characters.values():
		if char_data.recruit_area == area:
			# 检查是否已招募
			var already_joined = false
			for member in GameData.party:
				if member.id == char_data.id:
					already_joined = true
					break
			if not already_joined:
				result.append(char_data)
	return result

## 检查角色是否可招募
func can_recruit(member_id: String) -> bool:
	if not recruitable_characters.has(member_id):
		return false

	var char_data = recruitable_characters[member_id]

	# 检查是否已在队伍中
	for member in GameData.party:
		if member.id == member_id:
			return false

	# 检查招募条件
	var condition = char_data.recruit_condition
	if not condition.is_empty():
		if not GameData.game_flags.get(condition, false):
			return false

	return true

## 获取队伍人数
func get_party_size() -> int:
	return GameData.party.size()

## 获取队伍中存活成员
func get_alive_members() -> Array:
	var result = []
	for member in GameData.party:
		if member.current_hp > 0:
			result.append(member)
	return result
