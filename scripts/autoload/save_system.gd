extends Node
## 存档系统 (SaveSystem)
## 使用 JSON 序列化游戏状态到 user://save_slot_X.json
## 作为 Autoload 单例运行

signal game_saved()
signal game_loaded()

const SAVE_DIR := "user://"

func _get_save_path(slot: int) -> String:
        return SAVE_DIR + "save_slot_%d.json" % slot

func has_save_data(slot: int = 0) -> bool:
        return FileAccess.file_exists(_get_save_path(slot))

func has_save_slot(slot: int) -> bool:
        return FileAccess.file_exists(_get_save_path(slot))

## 获取存档信息 (不加载整个存档)
func get_save_info(slot: int) -> Dictionary:
        if not has_save_slot(slot):
                return {}
        var file := FileAccess.open(_get_save_path(slot), FileAccess.READ)
        if file == null:
                return {}
        var json_text := file.get_as_text()
        file.close()
        var json := JSON.new()
        if json.parse(json_text) != OK:
                return {}
        var data: Dictionary = json.data
        return {
                "play_time": float(data.get("play_time", 0.0)),
                "coins": int(data.get("coins", 0)),
                "area": data.get("current_area", "???"),
                "timestamp": float(data.get("timestamp", 0)),
        }

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
                "achievements": _serialize_achievements(),
                "quests": _serialize_quests(),
                "current_area": GameData.game_flags.get("current_area", "aoduo"),
                "flags": GameData.game_flags,
        }

        var file := FileAccess.open(_get_save_path(slot), FileAccess.WRITE)
        if file == null:
                push_error("[SaveSystem] 无法写入存档: " + str(FileAccess.get_open_error()))
                return false

        file.store_string(JSON.stringify(save_data, "\t"))
        file.close()

        print("[SaveSystem] 存档成功! slot=%d, coins=%d" % [slot, GameData.coins])
        game_saved.emit()
        return true

func load_game(slot: int = 0) -> bool:
        if not has_save_slot(slot):
                push_error("[SaveSystem] 存档文件不存在: slot=%d" % slot)
                return false

        var file := FileAccess.open(_get_save_path(slot), FileAccess.READ)
        if file == null:
                push_error("[SaveSystem] 无法读取存档")
                return false

        var json_text := file.get_as_text()
        file.close()

        var json := JSON.new()
        var err := json.parse(json_text)
        if err != OK:
                push_error("[SaveSystem] JSON 解析失败: " + json.get_error_message())
                return false

        var data: Dictionary = json.data

        # 恢复游戏状态
        GameData.play_time = float(data.get("play_time", 0.0))
        GameData.coins = int(data.get("coins", 0))
        GameData.game_flags = data.get("flags", {})

        _deserialize_party(data.get("party", []))
        _deserialize_inventory(data.get("inventory", []))
        _deserialize_tanks(data.get("tanks", []))
        _deserialize_achievements(data.get("achievements", []))
        _deserialize_quests(data.get("quests", []))

        print("[SaveSystem] 读档成功! slot=%d, coins=%d, play_time=%.0f" % [slot, GameData.coins, GameData.play_time])
        game_loaded.emit()
        return true

## ---- 序列化 ----

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
                        "max_exp": member.max_exp,
                        "attack": member.attack,
                        "defense": member.defense,
                        "speed": member.speed,
                        "weapon_id": member.weapon.id if member.weapon else "",
                        "armor_id": member.armor.id if member.armor else "",
                        "accessory_id": member.accessory.id if member.accessory else "",
                })
        return result

func _serialize_inventory() -> Array:
        var result := []
        for item in GameData.inventory:
                result.append({
                        "id": item.id,
                        "name": item.name,
                        "description": item.description,
                        "type": item.type,
                        "price": item.price,
                        "attack": item.attack,
                        "defense": item.defense,
                        "speed": item.speed,
                        "count": item.count,
                        "stackable": item.stackable,
                })
        return result

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

func _serialize_achievements() -> Array:
        var result := []
        for ach in AchievementSystem.achievements.values():
                result.append({
                        "id": ach.id,
                        "unlocked": ach.unlocked,
                })
        return result

func _serialize_quests() -> Array:
        var result := []
        for quest in QuestSystem.quests.values():
                var objectives_data := []
                for obj in quest.objectives:
                        objectives_data.append({
                                "type": obj.type,
                                "target": obj.target,
                                "count": obj.count,
                                "current": obj.current,
                        })
                result.append({
                        "id": quest.id,
                        "status": quest.status,
                        "objectives": objectives_data,
                })
        return result

## ---- 反序列化 ----

func _deserialize_party(party_data: Array) -> void:
        GameData.party.clear()
        for pd in party_data:
                var member := GameData.PartyMember.new()
                member.id = pd.get("id", "")
                member.name = pd.get("name", "Unknown")
                member.level = int(pd.get("level", 1))
                member.current_hp = int(pd.get("current_hp", 100))
                member.max_hp = int(pd.get("max_hp", 200))
                member.current_exp = int(pd.get("current_exp", 0))
                member.max_exp = int(pd.get("max_exp", 55))
                member.attack = int(pd.get("attack", 5))
                member.defense = int(pd.get("defense", 5))
                member.speed = int(pd.get("speed", 3))
                GameData.party.append(member)

func _deserialize_inventory(inventory_data: Array) -> void:
        GameData.inventory.clear()
        for id in inventory_data:
                var item := GameData.Item.new()
                item.id = id.get("id", "")
                item.name = id.get("name", "Unknown")
                item.description = id.get("description", "")
                item.type = int(id.get("type", 0))
                item.price = int(id.get("price", 0))
                item.attack = int(id.get("attack", 0))
                item.defense = int(id.get("defense", 0))
                item.speed = int(id.get("speed", 0))
                item.count = int(id.get("count", 1))
                item.stackable = bool(id.get("stackable", true))
                GameData.inventory.append(item)

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

func _deserialize_achievements(achievement_data: Array) -> void:
        for ad in achievement_data:
                var id: String = ad.get("id", "")
                if AchievementSystem.achievements.has(id):
                        AchievementSystem.achievements[id].unlocked = bool(ad.get("unlocked", false))

func _deserialize_quests(quest_data: Array) -> void:
        for qd in quest_data:
                var id: String = qd.get("id", "")
                if not QuestSystem.quests.has(id):
                        continue
                var quest = QuestSystem.quests[id]
                quest.status = int(qd.get("status", QuestSystem.QuestStatus.LOCKED))
                var objectives_data: Array = qd.get("objectives", [])
                for i in range(min(objectives_data.size(), quest.objectives.size())):
                        var obj_data = objectives_data[i]
                        var obj = quest.objectives[i]
                        obj.type = obj_data.get("type", obj.type)
                        obj.target = obj_data.get("target", obj.target)
                        obj.count = int(obj_data.get("count", obj.count))
                        obj.current = int(obj_data.get("current", 0))
