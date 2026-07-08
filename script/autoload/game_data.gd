extends Node
## 游戏数据管理器 (GameData)
## 统一管理玩家队伍、背包、金钱、物品等全局状态
## 作为 Autoload 单例运行

## ---- 物品数据结构 ----
class Item:
        var id: String
        var name: String
        var description: String
        var icon_path: String
        var type: ItemType
        var stackable: bool = true
        var count: int = 1
        var price: int = 0
        # 装备属性
        var attack: int = 0
        var defense: int = 0
        var speed: int = 0

        enum ItemType {
                CONSUMABLE,  ## 消耗品
                WEAPON,      ## 武器
                ARMOR,       ## 防具
                ACCESSORY,   ## 饰品
                KEY_ITEM,    ## 关键道具
        }

## ---- 队伍成员数据 ----
class PartyMember:
        var id: String
        var name: String
        var level: int = 1
        var current_exp: int = 0
        var max_exp: int = 55
        var current_hp: int = 200
        var max_hp: int = 200
        var attack: int = 10
        var defense: int = 5
        var speed: int = 3
        var weapon: Item = null
        var armor: Item = null
        var accessory: Item = null
        var skills: Array = []
        var in_party: bool = false

## ---- 全局状态 ----
var coins: int = 500  ## 金钱
var party: Array[PartyMember] = []  ## 队伍成员
var inventory: Array[Item] = []  ## 背包
var key_items: Array[Item] = []  ## 关键道具
var play_time: float = 0.0  ## 游戏时间(秒)
var encounter_count: int = 0  ## 战斗次数
var defeat_count: int = 0  ## 击败敌人数
var game_flags: Dictionary = {}  ## 游戏标志位 (用于剧情触发/存档)

## 信号
signal coins_changed(new_coins: int)
signal inventory_changed
signal party_changed
signal hp_changed(member_id: String, new_hp: int)

func _ready() -> void:
        _init_default_party()
        _init_default_inventory()

func _process(delta: float) -> void:
        play_time += delta

## 初始化默认队伍
func _init_default_party() -> void:
        # 雷班纳 - 主角
        var rebana := PartyMember.new()
        rebana.id = "rebana"
        rebana.name = "雷班纳"
        rebana.level = 1
        rebana.current_hp = 199
        rebana.max_hp = 200
        rebana.attack = 10
        rebana.defense = 5
        rebana.speed = 3
        rebana.in_party = true
        party.append(rebana)

## 初始化默认背包
func _init_default_inventory() -> void:
        # 恢复药
        var potion := Item.new()
        potion.id = "potion"
        potion.name = "恢复药"
        potion.description = "恢复 50 HP"
        potion.type = Item.ItemType.CONSUMABLE
        potion.count = 3
        potion.price = 50
        inventory.append(potion)

        # 弹弓 (初始武器)
        var slingshot := Item.new()
        slingshot.id = "slingshot"
        slingshot.name = "弹弓"
        slingshot.description = "简单的远程武器"
        slingshot.type = Item.ItemType.WEAPON
        slingshot.attack = 8
        slingshot.price = 100
        inventory.append(slingshot)

## 获取队伍中参战的成员
func get_active_party() -> Array[PartyMember]:
        var active: Array[PartyMember] = []
        for member in party:
                if member.in_party and member.current_hp > 0:
                        active.append(member)
        return active

## 添加金钱
func add_coins(amount: int) -> void:
        coins += amount
        coins_changed.emit(coins)

## 消费金钱 (返回是否成功)
func spend_coins(amount: int) -> bool:
        if coins < amount:
                return false
        coins -= amount
        coins_changed.emit(coins)
        return true

## 添加物品到背包
func add_item(item: Item) -> void:
        if item.stackable:
                # 查找同类物品
                for inv_item in inventory:
                        if inv_item.id == item.id:
                                inv_item.count += item.count
                                inventory_changed.emit()
                                return
        inventory.append(item)
        inventory_changed.emit()

## 使用消耗品
func use_consumable(item_id: String, target: PartyMember) -> bool:
        for item in inventory:
                if item.id == item_id and item.type == Item.ItemType.CONSUMABLE:
                        # 恢复药效果
                        if item_id == "potion":
                                target.current_hp = min(target.current_hp + 50, target.max_hp)
                                hp_changed.emit(target.id, target.current_hp)
                        item.count -= 1
                        if item.count <= 0:
                                inventory.erase(item)
                        inventory_changed.emit()
                        return true
        return false

## 装备物品
func equip_item(item: Item, target: PartyMember) -> void:
        match item.type:
                Item.ItemType.WEAPON:
                        if target.weapon:
                                # 卸下旧装备放回背包
                                add_item(target.weapon)
                        target.weapon = item
                        target.attack += item.attack
                Item.ItemType.ARMOR:
                        if target.armor:
                                add_item(target.armor)
                        target.armor = item
                        target.defense += item.defense
                Item.ItemType.ACCESSORY:
                        if target.accessory:
                                add_item(target.accessory)
                        target.accessory = item
                        target.speed += item.speed
        # 从背包移除
        inventory.erase(item)
        inventory_changed.emit()
        party_changed.emit()

## 获取格式化的游戏时间
func get_play_time_string() -> String:
        var hours = int(play_time) / 3600
        var minutes = (int(play_time) % 3600) / 60
        var seconds = int(play_time) % 60
        return "%02d:%02d:%02d" % [hours, minutes, seconds]
