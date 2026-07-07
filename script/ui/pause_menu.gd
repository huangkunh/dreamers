extends Control
## 暂停菜单 (PauseMenu)
## 游戏中按 M 键打开的菜单系统
## 包含: 队伍状态、背包、装备、设置

@onready var tab_container: TabContainer = $Panel/TabContainer
@onready var party_tab: VBoxContainer = $Panel/TabContainer/PartyTab
@onready var inventory_tab: VBoxContainer = $Panel/TabContainer/InventoryTab
@onready var status_label: Label = $Panel/TopBar/StatusLabel
@onready var coins_label: Label = $Panel/TopBar/CoinsLabel
@onready var time_label: Label = $Panel/TopBar/TimeLabel
@onready var close_button: Button = $Panel/TopBar/CloseButton

var _inventory_list: ItemList
var _party_info: VBoxContainer

func _ready() -> void:
        visible = false
        close_button.pressed.connect(close)
        _build_party_tab()
        _build_inventory_tab()

func _process(_delta: float) -> void:
        if visible:
                coins_label.text = "💰 " + str(GameData.coins)
                time_label.text = "⏱ " + GameData.get_play_time_string()

## 构建队伍标签页
func _build_party_tab() -> void:
        # 清空现有内容
        for child in party_tab.get_children():
                child.queue_free()

        # 标题
        var title := Label.new()
        title.text = "队伍状态"
        title.add_theme_font_size_override("font_size", 24)
        title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
        party_tab.add_child(title)

        # 分隔线
        party_tab.add_child(HSeparator.new())

        # 队伍成员列表
        _party_info = VBoxContainer.new()
        party_tab.add_child(_party_info)

        _refresh_party_info()

## 刷新队伍信息
func _refresh_party_info() -> void:
        for child in _party_info.get_children():
                child.queue_free()

        for member in GameData.party:
                if not member.in_party:
                        continue

                var member_box := HBoxContainer.new()
                member_box.add_theme_constant_override("separation", 20)

                # 名字
                var name_label := Label.new()
                name_label.text = member.name
                name_label.add_theme_font_size_override("font_size", 20)
                name_label.custom_minimum_size = Vector2(100, 0)
                member_box.add_child(name_label)

                # 等级
                var lv_label := Label.new()
                lv_label.text = "Lv." + str(member.level)
                lv_label.add_theme_font_size_override("font_size", 18)
                lv_label.custom_minimum_size = Vector2(60, 0)
                member_box.add_child(lv_label)

                # HP
                var hp_label := Label.new()
                hp_label.text = "HP: %d/%d" % [member.current_hp, member.max_hp]
                hp_label.add_theme_font_size_override("font_size", 18)
                hp_label.custom_minimum_size = Vector2(120, 0)
                member_box.add_child(hp_label)

                # 武器
                var weapon_label := Label.new()
                weapon_label.text = "武器: " + (member.weapon.name if member.weapon else "无")
                weapon_label.add_theme_font_size_override("font_size", 16)
                member_box.add_child(weapon_label)

                _party_info.add_child(member_box)

## 构建背包标签页
func _build_inventory_tab() -> void:
        for child in inventory_tab.get_children():
                child.queue_free()

        # 标题
        var title := Label.new()
        title.text = "背包"
        title.add_theme_font_size_override("font_size", 24)
        title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
        inventory_tab.add_child(title)

        inventory_tab.add_child(HSeparator.new())

        # 物品列表
        _inventory_list = ItemList.new()
        _inventory_list.custom_minimum_size = Vector2(0, 250)
        _inventory_list.item_activated.connect(_on_item_activated)
        inventory_tab.add_child(_inventory_list)

        # 物品描述
        var desc_label := Label.new()
        desc_label.name = "DescLabel"
        desc_label.text = "选择物品查看详情"
        desc_label.add_theme_font_size_override("font_size", 16)
        desc_label.custom_minimum_size = Vector2(0, 40)
        desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        inventory_tab.add_child(desc_label)

        # 保存按钮
        var save_btn := Button.new()
        save_btn.text = "💾 保存游戏"
        save_btn.custom_minimum_size = Vector2(0, 40)
        save_btn.pressed.connect(_on_save_game)
        inventory_tab.add_child(save_btn)

        _refresh_inventory()

## 保存游戏
func _on_save_game() -> void:
        if SaveSystem:
                var success = SaveSystem.save_game()
                if success:
                        status_label.text = "✅ 存档成功!"
                else:
                        status_label.text = "❌ 存档失败!"

## 刷新背包
func _refresh_inventory() -> void:
        if not _inventory_list:
                return
        _inventory_list.clear()
        for item in GameData.inventory:
                var prefix := ""
                match item.type:
                        GameData.Item.ItemType.CONSUMABLE: prefix = "🧪 "
                        GameData.Item.ItemType.WEAPON: prefix = "⚔ "
                        GameData.Item.ItemType.ARMOR: prefix = "🛡 "
                        GameData.Item.ItemType.ACCESSORY: prefix = "💍 "
                        GameData.Item.ItemType.KEY_ITEM: prefix = "🔑 "
                var count_str := " x%d" % item.count if item.count > 1 else ""
                _inventory_list.add_item(prefix + item.name + count_str)

## 物品双击使用
func _on_item_activated(index: int) -> void:
        if index < 0 or index >= GameData.inventory.size():
                return
        var item = GameData.inventory[index]
        var desc_label = inventory_tab.get_node("DescLabel")
        desc_label.text = item.name + " - " + item.description

        # 如果是消耗品，使用
        if item.type == GameData.Item.ItemType.CONSUMABLE:
                var target = GameData.get_active_party()[0] if GameData.get_active_party().size() > 0 else null
                if target:
                        GameData.use_consumable(item.id, target)
                        _refresh_inventory()
                        _refresh_party_info()

## 打开菜单
func open() -> void:
        visible = true
        _refresh_party_info()
        _refresh_inventory()
        coins_label.text = "💰 " + str(GameData.coins)
        # 暂停游戏
        get_tree().paused = true

## 关闭菜单
func close() -> void:
        visible = false
        get_tree().paused = false

## 切换菜单显示
func toggle() -> void:
        if visible:
                close()
        else:
                open()
