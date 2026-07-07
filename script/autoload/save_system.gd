extends Node
## 存档系统 (SaveSystem)
## 使用 JSON 序列化游戏状态到 user://save_data.json
## 作为 Autoload 单例运行

const SAVE_PATH := "user://save_data.json"

signal game_saved()
signal game_loaded()

func has_save_data() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(slot: int = 0) -> bool:
	var save_data := {
		"version": 1,
		"slot": slot,
		"timestamp": Time.get_unix_time_from_system(),
		"play_time": GameData.play_time,
		"coins": GameData.coins,
		"party": _serialize_party(),
		"inventory": _serialize_inventory(),
		"tanks": _serialize_tanks(),
		"current_area": "aoduo",
		"player_position": _serialize_player_position(),
		"flags": GameData.game_flags,
	}

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("[SaveSystem] 无法写入存档: " + str(FileAccess.get_open_error()))
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

	print("[SaveSystem] 存档成功! slot=%d, coins=%d" % [slot, GameData.coins])
	game_saved.emit()
	return true

func load_game(slot: int = 0) -> bool:
	if not has_save_data():
		push_warning("[SaveSystem] 无存档文件")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("[SaveSystem] 无法读取存档")
		return false

	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		push_error("[SaveSystem] 存档解析失败: " + json.get_error_message())
		return false

	var data = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("[SaveSystem] 存档格式错误")
		return false

	# 恢复游戏数据
	GameData.coins = int(data.get("coins", 0))
	GameData.play_time = float(data.get("play_time", 0))
	GameData.game_flags = data.get("flags", {})

	# 恢复队伍
	_deserialize_party(data.get("party", []))

	# 恢复背包
	_deserialize_inventory(data.get("inventory", []))

	# 恢复战车
	_deserialize_tanks(data.get("tanks", []))

	print("[SaveSystem] 读档成功! coins=%d, play_time=%.0f" % [GameData.coins, GameData.play_time])
	game_loaded.emit()
	return true

func delete_save() -> void:
	if has_save_data():
		DirAccess.remove_absolute(SAVE_PATH)
		print("[SaveSystem] 存档已删除")

func get_save_info() -> Dictionary:
	if not has_save_data():
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	json.parse(text)
	var data = json.data
	return {
		"coins": int(data.get("coins", 0)),
		"play_time": float(data.get("play_time", 0)),
		"timestamp": float(data.get("timestamp", 0)),
		"party_names": _get_party_names(data.get("party", [])),
	}

## 序列化队伍
func _serialize_party() -> Array:
	var result := []
	for member in GameData.party:
		result.append({
			"id": member.id,
			"name": member.name,
			"level": member.level,
			"current_hp": member.current_hp,
			"max_hp": member.max_hp,
			"current_exp": member.current_exp,
			"attack": member.attack,
			"defense": member.defense,
			"speed": member.speed,
			"in_party": member.in_party,
			"weapon_id": member.weapon.id if member.weapon else "",
			"armor_id": member.armor.id if member.armor else "",
			"accessory_id": member.accessory.id if member.accessory else "",
		})
	return result

## 序列化背包
func _serialize_inventory() -> Array:
	var result := []
	for item in GameData.inventory:
		result.append({
			"id": item.id,
			"name": item.name,
			"description": item.description,
			"type": item.type,
			"count": item.count,
			"price": item.price,
			"attack": item.attack,
			"defense": item.defense,
			"speed": item.speed,
			"stackable": item.stackable,
		})
	return result

## 序列化战车
func _serialize_tanks() -> Array:
	var result := []
	for tank in TankSystem.tanks.values():
		result.append({
			"id": tank.id,
			"name": tank.name,
			"max_hp": tank.max_hp,
			"current_hp": tank.current_hp,
			"max_fuel": tank.max_fuel,
			"current_fuel": tank.current_fuel,
			"max_ammo": tank.max_ammo,
			"current_ammo": tank.current_ammo,
			"attack": tank.attack,
			"defense": tank.defense,
			"speed": tank.speed,
			"is_owned": tank.is_owned,
			"is_active": tank.is_active,
		})
	return result

## 序列化玩家位置 (简化版)
func _serialize_player_position() -> Dictionary:
	return {"x": 0.0, "y": 0.0, "z": 0.0}

## 反序列化队伍
func _deserialize_party(party_data: Array) -> void:
	GameData.party.clear()
	for pd in party_data:
		var member := GameData.PartyMember.new()
		member.id = pd.get("id", "")
		member.name = pd.get("name", "Unknown")
		member.level = int(pd.get("level", 1))
		member.max_hp = int(pd.get("max_hp", 100))
		member.current_hp = int(pd.get("current_hp", member.max_hp))
		member.current_exp = int(pd.get("current_exp", 0))
		member.attack = int(pd.get("attack", 10))
		member.defense = int(pd.get("defense", 5))
		member.speed = int(pd.get("speed", 3))
		member.in_party = bool(pd.get("in_party", true))
		GameData.party.append(member)

## 反序列化背包
func _deserialize_inventory(inv_data: Array) -> void:
	GameData.inventory.clear()
	for id in inv_data:
		var item := GameData.Item.new()
		item.id = id.get("id", "")
		item.name = id.get("name", "Unknown")
		item.description = id.get("description", "")
		item.type = int(id.get("type", 0))
		item.count = int(id.get("count", 1))
		item.price = int(id.get("price", 0))
		item.attack = int(id.get("attack", 0))
		item.defense = int(id.get("defense", 0))
		item.speed = int(id.get("speed", 0))
		item.stackable = bool(id.get("stackable", true))
		GameData.inventory.append(item)

## 反序列化战车
func _deserialize_tanks(tank_data: Array) -> void:
	TankSystem.tanks.clear()
	for td in tank_data:
		var tank := TankSystem.TankData.new()
		tank.id = td.get("id", "")
		tank.name = td.get("name", "Unknown")
		tank.max_hp = int(td.get("max_hp", 500))
		tank.current_hp = int(td.get("current_hp", tank.max_hp))
		tank.max_fuel = int(td.get("max_fuel", 100))
		tank.current_fuel = int(td.get("current_fuel", tank.max_fuel))
		tank.max_ammo = int(td.get("max_ammo", 30))
		tank.current_ammo = int(td.get("current_ammo", tank.max_ammo))
		tank.attack = int(td.get("attack", 50))
		tank.defense = int(td.get("defense", 30))
		tank.speed = int(td.get("speed", 8))
		tank.is_owned = bool(td.get("is_owned", false))
		tank.is_active = bool(td.get("is_active", false))
		TankSystem.tanks[tank.id] = tank

## 获取队伍名称列表 (用于存档信息显示)
func _get_party_names(party_data: Array) -> Array:
	var names := []
	for pd in party_data:
		names.append(pd.get("name", "?"))
	return names
