extends Control
## 暂停菜单 (PauseMenu)
## 游戏中按 M 键打开的菜单系统
## 包含: 队伍状态、背包、装备、任务、快速旅行、设置

const QUEST_LOG_SCENE := preload("res://scenes/ui/quest_log_screen.tscn")
const FAST_TRAVEL_SCENE := preload("res://scenes/ui/fast_travel_screen.tscn")
const SAVE_LOAD_SCENE := preload("res://scenes/ui/save_load_screen.tscn")
const OPTIONS_SCENE := preload("res://scenes/ui/options_screen.tscn")

@onready var tab_container: TabContainer = $Panel/TabContainer
@onready var party_tab: VBoxContainer = $Panel/TabContainer/PartyTab
@onready var inventory_tab: VBoxContainer = $Panel/TabContainer/InventoryTab
@onready var status_label: Label = $Panel/TopBar/StatusLabel
@onready var coins_label: Label = $Panel/TopBar/CoinsLabel
@onready var time_label: Label = $Panel/TopBar/TimeLabel
@onready var close_button: Button = $Panel/TopBar/CloseButton
@onready var action_buttons: HBoxContainer = $Panel/ActionButtons

var _inventory_list: ItemList
var _party_info: VBoxContainer

func _ready() -> void:
        visible = false
        close_button.pressed.connect(close)
        _build_party_tab()
        _build_inventory_tab()
        _build_action_buttons()

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

## 构建操作按钮
func _build_action_buttons() -> void:
        if not action_buttons:
                return
        # 清除现有按钮
        for child in action_buttons.get_children():
                child.queue_free()

        # 任务日志按钮
        var quest_btn := Button.new()
        quest_btn.text = "📋 任务"
        quest_btn.custom_minimum_size = Vector2(100, 36)
        quest_btn.add_theme_font_size_override("font_size", 16)
        quest_btn.pressed.connect(_open_quest_log)
        action_buttons.add_child(quest_btn)

        # 快速旅行按钮
        var travel_btn := Button.new()
        travel_btn.text = "🗺 旅行"
        travel_btn.custom_minimum_size = Vector2(100, 36)
        travel_btn.add_theme_font_size_override("font_size", 16)
        travel_btn.pressed.connect(_open_fast_travel)
        action_buttons.add_child(travel_btn)

        # 存档按钮
        var save_btn := Button.new()
        save_btn.text = "💾 存档"
        save_btn.custom_minimum_size = Vector2(100, 36)
        save_btn.add_theme_font_size_override("font_size", 16)
        save_btn.pressed.connect(_open_save)
        action_buttons.add_child(save_btn)

        # 设置按钮
        var options_btn := Button.new()
        options_btn.text = "⚙ 设置"
        options_btn.custom_minimum_size = Vector2(100, 36)
        options_btn.add_theme_font_size_override("font_size", 16)
        options_btn.pressed.connect(_open_options)
        action_buttons.add_child(options_btn)

## 打开任务日志
func _open_quest_log() -> void:
        var quest_log: Control = QUEST_LOG_SCENE.instantiate()
        add_child(quest_log)
        quest_log.open()

## 打开快速旅行
func _open_fast_travel() -> void:
        var travel: Control = FAST_TRAVEL_SCENE.instantiate()
        add_child(travel)
        travel.open()

## 打开存档
func _open_save() -> void:
        var save_screen: Control = SAVE_LOAD_SCENE.instantiate()
        add_child(save_screen)
        save_screen.open_save()

## 打开设置
func _open_options() -> void:
        var options: Control = OPTIONS_SCENE.instantiate()
        add_child(options)
        options.open()
