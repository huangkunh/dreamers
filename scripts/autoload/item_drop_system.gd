extends Node
## 物品掉落系统 (ItemDropSystem)
## 战斗胜利后随机掉落物品
## 作为工具类使用

## 掉落物品数据结构
class DropItem:
        var id: String
        var name: String
        var type: int        ## 0=消耗品, 1=武器, 2=防具, 3=饰品, 4=关键道具
        var chance: float    ## 掉落概率 (0-1)
        var count_min: int = 1
        var count_max: int = 1
        var icon_path: String = ""

## 通用掉落表 (按区域)
var drop_tables: Dictionary = {}

func _ready() -> void:
        _init_drop_tables()

## 初始化掉落表
func _init_drop_tables() -> void:
        # 奥多区域掉落表
        drop_tables["aoduo"] = [
                _create_drop("potion", "恢复药", 0, 0.3, 1, 2),
                _create_drop("antidote", "解毒药", 0, 0.15, 1, 1),
                _create_drop("coins_small", "小袋金币", 0, 0.4, 10, 30),
        ]

        # 荒野掉落表
        drop_tables["wasteland"] = [
                _create_drop("potion", "恢复药", 0, 0.25, 1, 2),
                _create_drop("energy_drink", "能量饮料", 0, 0.1, 1, 1),
                _create_drop("scrap_metal", "废金属", 4, 0.3, 1, 3),
                _create_drop("coins_medium", "中袋金币", 0, 0.35, 20, 50),
        ]

        # 工厂掉落表
        drop_tables["factory"] = [
                _create_drop("potion", "恢复药", 0, 0.3, 1, 3),
                _create_drop("repair_kit", "修理包", 0, 0.15, 1, 1),
                _create_drop("machine_part", "机械零件", 4, 0.25, 1, 2),
                _create_drop("coins_large", "大袋金币", 0, 0.3, 30, 80),
        ]

        # 蚂蚁巢穴掉落表
        drop_tables["ant_nest"] = [
                _create_drop("potion", "恢复药", 0, 0.3, 1, 3),
                _create_drop("antidote", "解毒药", 0, 0.35, 1, 2),
                _create_drop("ant_chitin", "蚁壳", 4, 0.4, 1, 3),
                _create_drop("coins_medium", "中袋金币", 0, 0.35, 20, 60),
        ]

        # 古代遗迹掉落表
        drop_tables["ancient_ruins"] = [
                _create_drop("potion", "恢复药", 0, 0.35, 2, 4),
                _create_drop("energy_cell", "能量电池", 0, 0.2, 1, 2),
                _create_drop("ancient_chip", "古代芯片", 4, 0.3, 1, 2),
                _create_drop("coins_huge", "巨袋金币", 0, 0.3, 50, 120),
        ]

## 创建掉落物品
func _create_drop(id: String, name: String, type: int, chance: float, count_min: int, count_max: int) -> DropItem:
        var drop := DropItem.new()
        drop.id = id
        drop.name = name
        drop.type = type
        drop.chance = chance
        drop.count_min = count_min
        drop.count_max = count_max
        return drop

## 计算战斗掉落
## area: 区域ID
## enemy_count: 敌人数量
## is_boss: 是否BOSS战
## 返回: 掉落物品列表 [{id, name, type, count}]
func calculate_drops(area: String, enemy_count: int = 1, is_boss: bool = false) -> Array:
        var drops := []

        # 获取区域掉落表
        var table = drop_tables.get(area, drop_tables["aoduo"])

        # 每个敌人独立计算掉落
        for i in range(enemy_count):
                for drop in table:
                        # BOSS战掉落率x2
                        var chance = drop.chance * (2.0 if is_boss else 1.0)
                        chance = min(chance, 0.95)  # 最高95%

                        if randf() <= chance:
                                var count = randi_range(drop.count_min, drop.count_max)
                                # 检查是否已有同类物品
                                var found = false
                                for existing in drops:
                                        if existing.id == drop.id:
                                                existing.count += count
                                                found = true
                                                break
                                if not found:
                                        drops.append({
                                                "id": drop.id,
                                                "name": drop.name,
                                                "type": drop.type,
                                                "count": count,
                                        })

        # BOSS战额外掉落
        if is_boss:
                drops.append({
                        "id": "rare_item",
                        "name": "稀有装备",
                        "type": 1,
                        "count": 1,
                })

        return drops

## 获取掉落物品的图标路径
func get_item_icon(item_id: String) -> String:
        match item_id:
                "potion": return "res://resource/sprite/buttons/potion.png"
                "antidote": return "res://resource/sprite/buttons/antidote.png"
                "coins_small", "coins_medium", "coins_large", "coins_huge":
                        return "res://resource/sprite/buttons/coins.png"
                _: return ""

## 获取掉落物品描述
func get_item_description(item_id: String) -> String:
        match item_id:
                "potion": return "恢复50HP的药水"
                "antidote": return "解除中毒状态"
                "energy_drink": return "恢复30HP并提升速度"
                "repair_kit": return "战车修理用，恢复100装甲"
                "energy_cell": return "恢复战车燃料"
                "scrap_metal": return "可出售的废金属"
                "machine_part": return "机械零件，可出售或改造用"
                "ant_chitin": return "坚硬的蚁壳，可制作防具"
                "ancient_chip": return "旧文明芯片，价值连城"
                "rare_item": return "BOSS掉落的稀有装备"
                _: return "未知物品"
        return ""
