extends Control
## 战车改造界面 (TankGarage)
## 在机械师处改造战车：装备更换、修复、补给
## 使用方式: 从 NPC 交互触发

@onready var garage_panel: PanelContainer = $GaragePanel
@onready var tank_list: ItemList = $GaragePanel/MarginContainer/VBoxContainer/HBoxContainer/TankList
@onready var info_label: RichTextLabel = $GaragePanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/InfoLabel
@onready var equip_list: ItemList = $GaragePanel/MarginContainer/VBoxContainer/HBoxContainer/EquipPanel/EquipList
@onready var title_label: Label = $GaragePanel/MarginContainer/VBoxContainer/TitleBar/TitleLabel
@onready var coins_label: Label = $GaragePanel/MarginContainer/VBoxContainer/TitleBar/CoinsLabel

var _current_tank_id: String = ""
var _current_equip_slot: int = 0  # 0=主炮 1=副炮 2=引擎 3=装甲 4=C装置
var _available_equips: Array = []

const SLOT_NAMES := ["主炮", "副武器", "引擎", "装甲板", "C装置"]

func _ready() -> void:
        visible = false
        process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        tank_list.item_selected.connect(_on_tank_selected)
        equip_list.item_selected.connect(_on_equip_selected)

func open_garage() -> void:
        visible = true
        get_tree().paused = true
        _refresh_tank_list()
        coins_label.text = "💰 " + str(GameData.coins)

func close_garage() -> void:
        visible = false
        get_tree().paused = false
        queue_free()

func _refresh_tank_list() -> void:
        tank_list.clear()
        var owned = TankSystem.get_owned_tanks()
        for tank in owned:
                tank_list.add_item("%s (HP:%d/%d)" % [tank.name, tank.current_hp, tank.max_hp])
        if owned.size() > 0:
                tank_list.select(0)
                _on_tank_selected(0)

func _on_tank_selected(index: int) -> void:
        var owned = TankSystem.get_owned_tanks()
        if index < 0 or index >= owned.size():
                return
        var tank = owned[index]
        _current_tank_id = tank.id
        var text := "[b][color=#ffcc44]%s[/color][/b]\n\n" % tank.name
        text += "装甲: %d/%d\n" % [tank.current_hp, tank.max_hp]
        text += "燃料: %d/%d\n" % [tank.current_fuel, tank.max_fuel]
        text += "弹药: %d/%d\n" % [tank.current_ammo, tank.max_ammo]
        text += "攻击: %d  防御: %d  速度: %d\n\n" % [tank.attack, tank.defense, tank.speed]
        text += "[b]装备:[/b]\n"
        text += "  主炮: %s\n" % (tank.main_cannon.get("name", "无") if not tank.main_cannon.is_empty() else "无")
        text += "  副武器: %s\n" % (tank.sub_weapon.get("name", "无") if not tank.sub_weapon.is_empty() else "无")
        text += "  引擎: %s\n" % (tank.engine.get("name", "无") if not tank.engine.is_empty() else "无")
        text += "  装甲: %s\n" % (tank.armor.get("name", "无") if not tank.armor.is_empty() else "无")
        text += "  C装置: %s\n" % (tank.c_device.get("name", "无") if not tank.c_device.is_empty() else "无")
        info_label.text = text
        _refresh_equip_list()

func _refresh_equip_list() -> void:
        equip_list.clear()
        # 显示装备槽
        for i in range(SLOT_NAMES.size()):
                var prefix = "▶ " if i == _current_equip_slot else "  "
                equip_list.add_item(prefix + SLOT_NAMES[i])
        equip_list.add_item("---")
        # 显示当前槽位可装备的配件
        _available_equips = TankEquipData.get_equipment_by_type(_current_equip_slot)
        for equip in _available_equips:
                var eq_name: String = equip.get("name", "???")
                var eq_price: int = equip.get("price", 0)
                var eq_atk: int = equip.get("attack", 0)
                equip_list.add_item("%s (%dG) ATK:%d" % [eq_name, eq_price, eq_atk])
        # 添加操作选项
        equip_list.add_item("---")
        equip_list.add_item("🔧 修复战车")
        equip_list.add_item("⛽ 补给战车")

func _on_equip_selected(index: int) -> void:
        # 处理装备槽选择和装备更换
        if index < SLOT_NAMES.size():
                _current_equip_slot = index
                _refresh_equip_list()
                return
        
        # 计算实际装备索引
        var offset = SLOT_NAMES.size() + 1  # 槽位 + 分隔线
        if index >= offset and index < offset + _available_equips.size():
                var equip = _available_equips[index - offset]
                var eq_price: int = equip.get("price", 0)
                if GameData.coins >= eq_price:
                        GameData.coins -= eq_price
                        TankSystem.equip_part(_current_tank_id, equip)
                        coins_label.text = "💰 " + str(GameData.coins)
                        _on_tank_selected(tank_list.get_selected_items()[0] if tank_list.get_selected_items().size() > 0 else 0)
                else:
                        info_label.text = "[color=#ff4444]金币不足！[/color]"
                return
        
        # 修复/补给
        var action_index = offset + _available_equips.size() + 1
        if index == action_index:
                var cost = TankSystem.repair_tank(_current_tank_id)
                GameData.coins -= cost
                coins_label.text = "💰 " + str(GameData.coins)
                _on_tank_selected(tank_list.get_selected_items()[0] if tank_list.get_selected_items().size() > 0 else 0)
        elif index == action_index + 1:
                TankSystem.resupply_tank(_current_tank_id)
                _on_tank_selected(tank_list.get_selected_items()[0] if tank_list.get_selected_items().size() > 0 else 0)

func _unhandled_input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close_garage()
                get_viewport().set_input_as_handled()
