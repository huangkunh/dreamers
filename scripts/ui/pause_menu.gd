extends Control
## 暂停菜单 (PauseMenu)
## 游戏中按 M 键打开的菜单系统
## 包含: 物品、装备、状态、存档、读档、返回游戏、返回标题

enum MenuItem {
	ITEMS,
	EQUIPMENT,
	STATUS,
	SAVE,
	LOAD,
	RETURN_TO_GAME,
	RETURN_TO_TITLE,
}

const TITLE_SCREEN := "res://scenes/ui/title_screen.tscn"

@onready var menu_list: VBoxContainer = $Panel/MainContainer/MenuList
@onready var content_panel: Panel = $Panel/MainContainer/ContentContainer/ContentPanel
@onready var status_label: Label = $Panel/TopBar/StatusLabel
@onready var coins_label: Label = $Panel/TopBar/CoinsLabel
@onready var time_label: Label = $Panel/TopBar/TimeLabel
@onready var close_button: Button = $Panel/TopBar/CloseButton

var _current_menu: int = MenuItem.ITEMS
var _is_processing: bool = false
var _menu_buttons: Array[Button] = []

var _inventory_list: ItemList = null
var _item_desc_label: Label = null
var _item_action_btn: Button = null
var _selected_item_index: int = -1

var _equip_member_list: ItemList = null
var _equip_slot_list: ItemList = null
var _equip_info_label: Label = null
var _selected_member_index: int = 0
var _selected_equip_slot: int = -1

var _status_member_list: ItemList = null
var _status_detail_panel: VBoxContainer = null

var _save_slot_container: VBoxContainer = null
var _save_mode: bool = true

func _ready() -> void:
	visible = false
	_is_processing = false
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	close_button.pressed.connect(_on_close_pressed)
	
	_build_menu_list()

func _process(_delta: float) -> void:
	if visible:
		coins_label.text = "💰 " + str(GameData.coins)
		time_label.text = "⏱ " + GameData.get_play_time_string()

func _build_menu_list() -> void:
	for child in menu_list.get_children():
		child.queue_free()
	_menu_buttons.clear()
	
	var menu_items := [
		{"id": MenuItem.ITEMS, "text": "🎒 物品", "hint": "查看和使用背包物品"},
		{"id": MenuItem.EQUIPMENT, "text": "⚔ 装备", "hint": "管理角色装备"},
		{"id": MenuItem.STATUS, "text": "📊 状态", "hint": "查看队伍成员状态"},
		{"id": MenuItem.SAVE, "text": "💾 存档", "hint": "保存游戏进度"},
		{"id": MenuItem.LOAD, "text": "📂 读档", "hint": "读取游戏进度"},
		{"id": MenuItem.RETURN_TO_GAME, "text": "▶ 返回游戏", "hint": "继续游戏"},
		{"id": MenuItem.RETURN_TO_TITLE, "text": "🏠 返回标题", "hint": "返回标题画面"},
	]
	
	for item in menu_items:
		var btn := Button.new()
		btn.text = item.text
		btn.custom_minimum_size = Vector2(0, 44)
		btn.add_theme_font_size_override("font_size", 18)
		btn.pressed.connect(_on_menu_selected.bind(item.id))
		menu_list.add_child(btn)
		_menu_buttons.append(btn)

func _on_menu_selected(menu_id: int) -> void:
	if _is_processing:
		return
	
	_current_menu = menu_id
	_update_menu_selection()
	
	match menu_id:
		MenuItem.ITEMS:
			status_label.text = "物品"
			_build_items_screen()
		MenuItem.EQUIPMENT:
			status_label.text = "装备"
			_build_equipment_screen()
		MenuItem.STATUS:
			status_label.text = "状态"
			_build_status_screen()
		MenuItem.SAVE:
			status_label.text = "存档"
			_save_mode = true
			_build_save_load_screen()
		MenuItem.LOAD:
			status_label.text = "读档"
			_save_mode = false
			_build_save_load_screen()
		MenuItem.RETURN_TO_GAME:
			close()
		MenuItem.RETURN_TO_TITLE:
			_return_to_title()

func _update_menu_selection() -> void:
	for i in range(_menu_buttons.size()):
		if i == _current_menu:
			_menu_buttons[i].add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		else:
			_menu_buttons[i].add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))

func _clear_content() -> void:
	for child in content_panel.get_children():
		child.queue_free()
	_inventory_list = null
	_item_desc_label = null
	_item_action_btn = null
	_selected_item_index = -1
	_equip_member_list = null
	_equip_slot_list = null
	_equip_info_label = null
	_status_member_list = null
	_status_detail_panel = null
	_save_slot_container = null

# ============================================================
# 物品界面
# ============================================================

func _build_items_screen() -> void:
	_clear_content()
	
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 15
	main_vbox.offset_top = 15
	main_vbox.offset_right = -15
	main_vbox.offset_bottom = -15
	main_vbox.add_theme_constant_override("separation", 10)
	content_panel.add_child(main_vbox)
	
	var title := Label.new()
	title.text = "背包物品"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	main_vbox.add_child(title)
	
	main_vbox.add_child(HSeparator.new())
	
	_inventory_list = ItemList.new()
	_inventory_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_inventory_list.add_theme_font_size_override("font_size", 16)
	_inventory_list.item_selected.connect(_on_item_selected)
	_inventory_list.item_activated.connect(_on_item_activated)
	main_vbox.add_child(_inventory_list)
	
	_item_desc_label = Label.new()
	_item_desc_label.text = "选择物品查看详情"
	_item_desc_label.add_theme_font_size_override("font_size", 15)
	_item_desc_label.custom_minimum_size = Vector2(0, 50)
	_item_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_item_desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	main_vbox.add_child(_item_desc_label)
	
	_item_action_btn = Button.new()
	_item_action_btn.text = "使用"
	_item_action_btn.custom_minimum_size = Vector2(0, 40)
	_item_action_btn.add_theme_font_size_override("font_size", 16)
	_item_action_btn.disabled = true
	_item_action_btn.pressed.connect(_on_use_item)
	main_vbox.add_child(_item_action_btn)
	
	_refresh_inventory_list()

func _refresh_inventory_list() -> void:
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

func _on_item_selected(index: int) -> void:
	_selected_item_index = index
	if index < 0 or index >= GameData.inventory.size():
		return
	var item = GameData.inventory[index]
	var type_str := ""
	match item.type:
		GameData.Item.ItemType.CONSUMABLE: type_str = "消耗品"
		GameData.Item.ItemType.WEAPON: type_str = "武器"
		GameData.Item.ItemType.ARMOR: type_str = "防具"
		GameData.Item.ItemType.ACCESSORY: type_str = "饰品"
		GameData.Item.ItemType.KEY_ITEM: type_str = "关键道具"
	
	var stats_str := ""
	if item.type == GameData.Item.ItemType.WEAPON:
		stats_str = "\n攻击 +%d" % item.attack
	elif item.type == GameData.Item.ItemType.ARMOR:
		stats_str = "\n防御 +%d" % item.defense
	elif item.type == GameData.Item.ItemType.ACCESSORY:
		stats_str = "\n速度 +%d" % item.speed
	
	_item_desc_label.text = "[%s] %s\n%s%s" % [type_str, item.name, item.description, stats_str]
	
	if item.type == GameData.Item.ItemType.CONSUMABLE:
		_item_action_btn.text = "使用"
		_item_action_btn.disabled = false
	elif item.type == GameData.Item.ItemType.WEAPON or item.type == GameData.Item.ItemType.ARMOR or item.type == GameData.Item.ItemType.ACCESSORY:
		_item_action_btn.text = "装备"
		_item_action_btn.disabled = false
	else:
		_item_action_btn.text = "使用"
		_item_action_btn.disabled = true

func _on_item_activated(index: int) -> void:
	_on_item_selected(index)
	_on_use_item()

func _on_use_item() -> void:
	if _is_processing:
		return
	if _selected_item_index < 0 or _selected_item_index >= GameData.inventory.size():
		return
	
	var item = GameData.inventory[_selected_item_index]
	
	if item.type == GameData.Item.ItemType.CONSUMABLE:
		_use_consumable(item)
	elif item.type == GameData.Item.ItemType.WEAPON or item.type == GameData.Item.ItemType.ARMOR or item.type == GameData.Item.ItemType.ACCESSORY:
		_equip_item_dialog(item)

func _use_consumable(item) -> void:
	var target = GameData.get_active_party()[0] if GameData.get_active_party().size() > 0 else null
	if not target:
		return
	GameData.use_consumable(item.id, target)
	_refresh_inventory_list()
	_refresh_equipment_if_needed()
	_refresh_status_if_needed()
	_selected_item_index = -1
	_item_desc_label.text = "使用成功！"
	_item_action_btn.disabled = true

func _equip_item_dialog(item) -> void:
	var party := GameData.get_active_party()
	if party.size() == 0:
		return
	_equip_item_to_member(item, party[0])

func _equip_item_to_member(item, member) -> void:
	GameData.equip_item(item, member)
	_refresh_inventory_list()
	_refresh_equipment_if_needed()
	_refresh_status_if_needed()
	_selected_item_index = -1
	_item_desc_label.text = "%s 装备了 %s！" % [member.name, item.name]
	_item_action_btn.disabled = true

# ============================================================
# 装备界面
# ============================================================

func _build_equipment_screen() -> void:
	_clear_content()
	
	var main_hbox := HBoxContainer.new()
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_left = 15
	main_hbox.offset_top = 15
	main_hbox.offset_right = -15
	main_hbox.offset_bottom = -15
	main_hbox.add_theme_constant_override("separation", 15)
	content_panel.add_child(main_hbox)
	
	var left_vbox := VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(200, 0)
	left_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(left_vbox)
	
	var member_title := Label.new()
	member_title.text = "队伍成员"
	member_title.add_theme_font_size_override("font_size", 20)
	member_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	left_vbox.add_child(member_title)
	
	left_vbox.add_child(HSeparator.new())
	
	_equip_member_list = ItemList.new()
	_equip_member_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_equip_member_list.add_theme_font_size_override("font_size", 16)
	_equip_member_list.item_selected.connect(_on_equip_member_selected)
	left_vbox.add_child(_equip_member_list)
	
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(right_vbox)
	
	var equip_title := Label.new()
	equip_title.text = "装备栏"
	equip_title.add_theme_font_size_override("font_size", 20)
	equip_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	right_vbox.add_child(equip_title)
	
	right_vbox.add_child(HSeparator.new())
	
	_equip_slot_list = ItemList.new()
	_equip_slot_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_equip_slot_list.add_theme_font_size_override("font_size", 16)
	_equip_slot_list.item_selected.connect(_on_equip_slot_selected)
	right_vbox.add_child(_equip_slot_list)
	
	_equip_info_label = Label.new()
	_equip_info_label.text = ""
	_equip_info_label.add_theme_font_size_override("font_size", 14)
	_equip_info_label.custom_minimum_size = Vector2(0, 40)
	_equip_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_equip_info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	right_vbox.add_child(_equip_info_label)
	
	var unequip_btn := Button.new()
	unequip_btn.text = "卸下装备"
	unequip_btn.custom_minimum_size = Vector2(0, 36)
	unequip_btn.add_theme_font_size_override("font_size", 16)
	unequip_btn.pressed.connect(_on_unequip)
	right_vbox.add_child(unequip_btn)
	
	_refresh_equip_member_list()

func _refresh_equip_member_list() -> void:
	if not _equip_member_list:
		return
	_equip_member_list.clear()
	for member in GameData.party:
		if member.in_party:
			_equip_member_list.add_item("%s (Lv.%d)" % [member.name, member.level])
	if _equip_member_list.size() > 0:
		_equip_member_list.select(0)
		_on_equip_member_selected(0)

func _on_equip_member_selected(index: int) -> void:
	_selected_member_index = index
	_refresh_equip_slot_list()

func _refresh_equip_slot_list() -> void:
	if not _equip_slot_list:
		return
	_equip_slot_list.clear()
	var party := GameData.party.filter(func(m): return m.in_party)
	if _selected_member_index < 0 or _selected_member_index >= party.size():
		return
	var member = party[_selected_member_index]
	
	var weapon_name: String = member.weapon.name if member.weapon else "无"
	_equip_slot_list.add_item("⚔ 武器: " + weapon_name)
	
	var armor_name: String = member.armor.name if member.armor else "无"
	_equip_slot_list.add_item("🛡 防具: " + armor_name)
	
	var accessory_name: String = member.accessory.name if member.accessory else "无"
	_equip_slot_list.add_item("💍 饰品: " + accessory_name)

func _on_equip_slot_selected(index: int) -> void:
	_selected_equip_slot = index
	var party := GameData.party.filter(func(m): return m.in_party)
	if _selected_member_index < 0 or _selected_member_index >= party.size():
		return
	var member = party[_selected_member_index]
	
	var item = null
	match index:
		0: item = member.weapon
		1: item = member.armor
		2: item = member.accessory
	
	if item:
		_equip_info_label.text = "%s\n%s" % [item.name, item.description]
	else:
		_equip_info_label.text = "此位置没有装备"

func _on_unequip() -> void:
	if _is_processing:
		return
	var party := GameData.party.filter(func(m): return m.in_party)
	if _selected_member_index < 0 or _selected_member_index >= party.size():
		return
	if _selected_equip_slot < 0:
		return
	
	var member = party[_selected_member_index]
	var item = null
	match _selected_equip_slot:
		0:
			item = member.weapon
			if item:
				member.attack -= item.attack
				member.weapon = null
		1:
			item = member.armor
			if item:
				member.defense -= item.defense
				member.armor = null
		2:
			item = member.accessory
			if item:
				member.speed -= item.speed
				member.accessory = null
	
	if item:
		GameData.add_item(item)
		_refresh_equip_slot_list()
		_refresh_inventory_if_needed()
		_refresh_status_if_needed()
		_equip_info_label.text = "已卸下: " + item.name

# ============================================================
# 状态界面
# ============================================================

func _build_status_screen() -> void:
	_clear_content()
	
	var main_hbox := HBoxContainer.new()
	main_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_hbox.offset_left = 15
	main_hbox.offset_top = 15
	main_hbox.offset_right = -15
	main_hbox.offset_bottom = -15
	main_hbox.add_theme_constant_override("separation", 15)
	content_panel.add_child(main_hbox)
	
	var left_vbox := VBoxContainer.new()
	left_vbox.custom_minimum_size = Vector2(200, 0)
	left_vbox.add_theme_constant_override("separation", 8)
	main_hbox.add_child(left_vbox)
	
	var member_title := Label.new()
	member_title.text = "队伍成员"
	member_title.add_theme_font_size_override("font_size", 20)
	member_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	left_vbox.add_child(member_title)
	
	left_vbox.add_child(HSeparator.new())
	
	_status_member_list = ItemList.new()
	_status_member_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_status_member_list.add_theme_font_size_override("font_size", 16)
	_status_member_list.item_selected.connect(_on_status_member_selected)
	left_vbox.add_child(_status_member_list)
	
	var right_vbox := VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 6)
	main_hbox.add_child(right_vbox)
	
	_status_detail_panel = VBoxContainer.new()
	_status_detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_status_detail_panel.add_theme_constant_override("separation", 6)
	right_vbox.add_child(_status_detail_panel)
	
	_refresh_status_member_list()

func _refresh_status_member_list() -> void:
	if not _status_member_list:
		return
	_status_member_list.clear()
	for member in GameData.party:
		if member.in_party:
			_status_member_list.add_item("%s (Lv.%d)" % [member.name, member.level])
	if _status_member_list.size() > 0:
		_status_member_list.select(0)
		_on_status_member_selected(0)

func _on_status_member_selected(index: int) -> void:
	_refresh_status_detail(index)

func _refresh_status_detail(index: int) -> void:
	if not _status_detail_panel:
		return
	for child in _status_detail_panel.get_children():
		child.queue_free()
	
	var party := GameData.party.filter(func(m): return m.in_party)
	if index < 0 or index >= party.size():
		return
	var member = party[index]
	
	var name_label := Label.new()
	name_label.text = member.name
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_status_detail_panel.add_child(name_label)
	
	_status_detail_panel.add_child(HSeparator.new())
	
	var level_label := Label.new()
	level_label.text = "等级: Lv.%d" % member.level
	level_label.add_theme_font_size_override("font_size", 18)
	_status_detail_panel.add_child(level_label)
	
	var exp_label := Label.new()
	exp_label.text = "经验: %d / %d" % [member.current_exp, member.max_exp]
	exp_label.add_theme_font_size_override("font_size", 16)
	exp_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_status_detail_panel.add_child(exp_label)
	
	_status_detail_panel.add_child(HSeparator.new())
	
	var hp_label := Label.new()
	hp_label.text = "HP: %d / %d" % [member.current_hp, member.max_hp]
	hp_label.add_theme_font_size_override("font_size", 18)
	hp_label.add_theme_color_override("font_color", Color(0.8, 0.9, 1))
	_status_detail_panel.add_child(hp_label)
	
	_status_detail_panel.add_child(HSeparator.new())
	
	var stats_title := Label.new()
	stats_title.text = "战斗属性"
	stats_title.add_theme_font_size_override("font_size", 20)
	stats_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_status_detail_panel.add_child(stats_title)
	
	var atk_label := Label.new()
	atk_label.text = "⚔ 攻击: %d" % member.attack
	atk_label.add_theme_font_size_override("font_size", 18)
	_status_detail_panel.add_child(atk_label)
	
	var def_label := Label.new()
	def_label.text = "🛡 防御: %d" % member.defense
	def_label.add_theme_font_size_override("font_size", 18)
	_status_detail_panel.add_child(def_label)
	
	var spd_label := Label.new()
	spd_label.text = "💨 速度: %d" % member.speed
	spd_label.add_theme_font_size_override("font_size", 18)
	_status_detail_panel.add_child(spd_label)
	
	_status_detail_panel.add_child(HSeparator.new())
	
	var equip_title := Label.new()
	equip_title.text = "装备"
	equip_title.add_theme_font_size_override("font_size", 20)
	equip_title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_status_detail_panel.add_child(equip_title)
	
	var weapon_label := Label.new()
	weapon_label.text = "武器: %s" % (member.weapon.name if member.weapon else "无")
	weapon_label.add_theme_font_size_override("font_size", 16)
	weapon_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_status_detail_panel.add_child(weapon_label)
	
	var armor_label := Label.new()
	armor_label.text = "防具: %s" % (member.armor.name if member.armor else "无")
	armor_label.add_theme_font_size_override("font_size", 16)
	armor_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_status_detail_panel.add_child(armor_label)
	
	var acc_label := Label.new()
	acc_label.text = "饰品: %s" % (member.accessory.name if member.accessory else "无")
	acc_label.add_theme_font_size_override("font_size", 16)
	acc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	_status_detail_panel.add_child(acc_label)

# ============================================================
# 存档/读档界面
# ============================================================

func _build_save_load_screen() -> void:
	_clear_content()
	
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 15
	main_vbox.offset_top = 15
	main_vbox.offset_right = -15
	main_vbox.offset_bottom = -15
	main_vbox.add_theme_constant_override("separation", 10)
	content_panel.add_child(main_vbox)
	
	var title_text := "保存游戏进度" if _save_mode else "读取游戏进度"
	var title := Label.new()
	title.text = title_text
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	main_vbox.add_child(title)
	
	main_vbox.add_child(HSeparator.new())
	
	_save_slot_container = VBoxContainer.new()
	_save_slot_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_save_slot_container.add_theme_constant_override("separation", 10)
	main_vbox.add_child(_save_slot_container)
	
	_refresh_save_slots()

func _refresh_save_slots() -> void:
	if not _save_slot_container:
		return
	for child in _save_slot_container.get_children():
		child.queue_free()
	
	for i in range(1, 4):
		var slot_panel := Panel.new()
		slot_panel.custom_minimum_size = Vector2(0, 80)
		_save_slot_container.add_child(slot_panel)
		
		var hbox := HBoxContainer.new()
		hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		hbox.offset_left = 15
		hbox.offset_top = 10
		hbox.offset_right = -15
		hbox.offset_bottom = -10
		hbox.add_theme_constant_override("separation", 20)
		slot_panel.add_child(hbox)
		
		var slot_num_label := Label.new()
		slot_num_label.text = "槽位 %d" % i
		slot_num_label.custom_minimum_size = Vector2(80, 0)
		slot_num_label.add_theme_font_size_override("font_size", 20)
		slot_num_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		hbox.add_child(slot_num_label)
		
		var info_label := Label.new()
		info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_label.add_theme_font_size_override("font_size", 16)
		
		var has_save := SaveSystem.has_save_slot(i)
		if has_save:
			var save_info := SaveSystem.get_save_info(i)
			var play_time := save_info.get("play_time", 0.0)
			var coins := save_info.get("coins", 0)
			var area := save_info.get("area", "???")
			info_label.text = "时间: %s | 金币: %dG | 区域: %s" % [_format_time(play_time), coins, area]
			info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			info_label.text = "空槽位" if _save_mode else "无存档"
			info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hbox.add_child(info_label)
		
		var action_btn := Button.new()
		action_btn.custom_minimum_size = Vector2(120, 0)
		action_btn.add_theme_font_size_override("font_size", 16)
		if _save_mode:
			action_btn.text = "保存"
			action_btn.pressed.connect(_on_save_slot.bind(i))
		else:
			action_btn.text = "读取"
			action_btn.pressed.connect(_on_load_slot.bind(i))
			if not has_save:
				action_btn.disabled = true
		hbox.add_child(action_btn)

func _on_save_slot(slot_num: int) -> void:
	if _is_processing:
		return
	_is_processing = true
	
	if SaveSystem.has_save_slot(slot_num):
		_show_confirm_dialog("覆盖存档", "槽位 %d 已有存档，是否覆盖？" % slot_num,
			func(): _do_save(slot_num),
			func(): _is_processing = false)
	else:
		_do_save(slot_num)

func _do_save(slot_num: int) -> void:
	var success := SaveSystem.save_game(slot_num)
	if success:
		status_label.text = "✅ 存档成功!"
	else:
		status_label.text = "❌ 存档失败!"
	_refresh_save_slots()
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		_is_processing = false
		status_label.text = "存档"
	)

func _on_load_slot(slot_num: int) -> void:
	if _is_processing:
		return
	_is_processing = true
	
	_show_confirm_dialog("读取存档", "确定要读取槽位 %d 的存档吗？当前进度将丢失。" % slot_num,
		func(): _do_load(slot_num),
		func(): _is_processing = false)

func _do_load(slot_num: int) -> void:
	var success := SaveSystem.load_game(slot_num)
	if success:
		status_label.text = "✅ 读档成功!"
		_refresh_all_screens()
	else:
		status_label.text = "❌ 读档失败!"
	_refresh_save_slots()
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		_is_processing = false
		status_label.text = "读档"
	)

func _show_confirm_dialog(title: String, message: String, on_confirm: Callable, on_cancel: Callable) -> void:
	var dialog := ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.ok_button_text = "确定"
	dialog.cancel_button_text = "取消"
	dialog.confirmed.connect(on_confirm)
	dialog.canceled.connect(on_cancel)
	add_child(dialog)
	dialog.popup_centered()

func _format_time(seconds: float) -> String:
	var s := int(seconds)
	var h := s / 3600
	var m := (s % 3600) / 60
	var sec := s % 60
	return "%02d:%02d:%02d" % [h, m, sec]

# ============================================================
# 辅助刷新函数
# ============================================================

func _refresh_all_screens() -> void:
	_refresh_inventory_if_needed()
	_refresh_equipment_if_needed()
	_refresh_status_if_needed()

func _refresh_inventory_if_needed() -> void:
	if _inventory_list:
		_refresh_inventory_list()

func _refresh_equipment_if_needed() -> void:
	if _equip_member_list:
		_refresh_equip_member_list()

func _refresh_status_if_needed() -> void:
	if _status_member_list:
		_refresh_status_member_list()

# ============================================================
# 返回标题
# ============================================================

func _return_to_title() -> void:
	if _is_processing:
		return
	_is_processing = true
	_show_confirm_dialog("返回标题", "确定要返回标题画面吗？当前进度将丢失。",
		func(): _do_return_to_title(),
		func(): _is_processing = false)

func _do_return_to_title() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(TITLE_SCREEN)

# ============================================================
# 打开/关闭
# ============================================================

func _on_close_pressed() -> void:
	if _is_processing:
		return
	close()

func open() -> void:
	if _is_processing:
		return
	visible = true
	_is_processing = false
	_current_menu = MenuItem.ITEMS
	_update_menu_selection()
	_build_items_screen()
	status_label.text = "物品"
	coins_label.text = "💰 " + str(GameData.coins)
	time_label.text = "⏱ " + GameData.get_play_time_string()
	get_tree().paused = true

func close() -> void:
	if _is_processing:
		return
	visible = false
	get_tree().paused = false

func toggle() -> void:
	if visible:
		close()
	else:
		open()

func _input(event: InputEvent) -> void:
	if visible and not _is_processing and event.is_action_pressed("ui_cancel"):
		close()
