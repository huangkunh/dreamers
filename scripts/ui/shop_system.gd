extends Control
## 商店系统 (ShopSystem)
## 购买/出售物品和装备
## 使用方式: ShopSystem.open_shop("武器店", shop_items)

@onready var shop_panel: PanelContainer = $ShopPanel
@onready var title_label: Label = $ShopPanel/MarginContainer/VBoxContainer/TitleBar/TitleLabel
@onready var coins_label: Label = $ShopPanel/MarginContainer/VBoxContainer/TitleBar/CoinsLabel
@onready var item_list: ItemList = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/ItemList
@onready var info_label: RichTextLabel = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/InfoLabel
@onready var buy_button: Button = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ButtonContainer/BuyButton
@onready var sell_button: Button = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ButtonContainer/SellButton
@onready var close_button: Button = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ButtonContainer/CloseButton
@onready var mode_label: Label = $ShopPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ModeLabel

var _shop_items: Array = []
var _current_index: int = 0
var _is_sell_mode: bool = false

func _ready() -> void:
        visible = false
        shop_panel.visible = false
        process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        buy_button.pressed.connect(_on_buy)
        sell_button.pressed.connect(_on_sell_mode)
        close_button.pressed.connect(close_shop)
        item_list.item_selected.connect(_on_item_selected)

## 打开商店
func open_shop(shop_name: String, items: Array) -> void:
        _shop_items = items
        _is_sell_mode = false
        mode_label.text = "购买模式"
        title_label.text = shop_name
        visible = true
        shop_panel.visible = true
        _refresh_item_list()
        get_tree().paused = true

## 关闭商店
func close_shop() -> void:
        visible = false
        shop_panel.visible = false
        get_tree().paused = false
        queue_free()

## 刷新物品列表
func _refresh_item_list() -> void:
        item_list.clear()
        if _is_sell_mode:
                # 出售模式：显示背包
                for item in GameData.inventory:
                        var type_name = _get_type_name(item.type)
                        var text = "%s [%s] %dG" % [item.name, type_name, int(item.price * 0.5)]
                        item_list.add_item(text)
        else:
                # 购买模式：显示商店物品
                for item in _shop_items:
                        var type_name = _get_type_name(item.get("type", 0))
                        var text = "%s [%s] %dG" % [item.get("name", "?"), type_name, item.get("price", 0)]
                        item_list.add_item(text)
        # 更新金币显示
        coins_label.text = "💰 " + str(GameData.coins)

## 选中物品
func _on_item_selected(index: int) -> void:
        _current_index = index
        if _is_sell_mode:
                if index < 0 or index >= GameData.inventory.size():
                        return
                var item = GameData.inventory[index]
                var sell_price = int(item.price * 0.5)
                info_label.text = "[b]%s[/b]\n%s\n\n[color=#ffaa44]售价: %dG[/color]" % [item.name, item.description, sell_price]
        else:
                if index < 0 or index >= _shop_items.size():
                        return
                var item = _shop_items[index]
                var stats = ""
                if item.get("attack", 0) > 0:
                        stats += "攻击 +%d " % item.attack
                if item.get("defense", 0) > 0:
                        stats += "防御 +%d " % item.defense
                if item.get("speed", 0) > 0:
                        stats += "速度 +%d" % item.speed
                info_label.text = "[b]%s[/b]\n%s\n\n%s\n[color=#ffaa44]价格: %dG[/color]" % [
                        item.get("name", "?"),
                        item.get("description", ""),
                        stats,
                        item.get("price", 0)
                ]

## 购买
func _on_buy() -> void:
        if _is_sell_mode:
                # 切回购买模式
                _is_sell_mode = false
                mode_label.text = "购买模式"
                _refresh_item_list()
                return

        if _current_index < 0 or _current_index >= _shop_items.size():
                return
        var item = _shop_items[_current_index]
        var price: int = item.get("price", 0)
        if GameData.coins < price:
                info_label.text = "[color=#ff4444]金币不足！[/color]"
                return

        # 购买
        GameData.coins -= price
        var new_item := GameData.Item.new()
        new_item.id = item.get("id", "")
        new_item.name = item.get("name", "???")
        new_item.description = item.get("description", "")
        new_item.type = item.get("type", 0)
        new_item.count = 1
        new_item.price = price
        new_item.attack = item.get("attack", 0)
        new_item.defense = item.get("defense", 0)
        new_item.speed = item.get("speed", 0)
        new_item.stackable = item.get("stackable", false)
        GameData.add_item(new_item)
        info_label.text = "[color=#44ff44]购买了 %s！[/color]" % new_item.name
        _refresh_item_list()

## 切换到出售模式
func _on_sell_mode() -> void:
        if not _is_sell_mode:
                _is_sell_mode = true
                mode_label.text = "出售模式"
                _refresh_item_list()
        else:
                # 出售选中物品
                if _current_index < 0 or _current_index >= GameData.inventory.size():
                        return
                var item = GameData.inventory[_current_index]
                var sell_price = int(item.price * 0.5)
                GameData.coins += sell_price
                GameData.inventory.erase(item)
                info_label.text = "[color=#44ff44]卖出了 %s (+%dG)[/color]" % [item.name, sell_price]
                _refresh_item_list()

## 获取类型名称
func _get_type_name(type: int) -> String:
        match type:
                0: return "消耗"
                1: return "武器"
                2: return "防具"
                3: return "饰品"
                4: return "关键"
                _: return "???"

func _unhandled_input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close_shop()
                get_viewport().set_input_as_handled()
