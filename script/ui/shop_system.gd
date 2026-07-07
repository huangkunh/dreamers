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
var _current_shop_name: String = ""

func _ready() -> void:
	visible = false
	shop_panel.visible = false
	buy_button.pressed.connect(_on_buy)
	sell_button.pressed.connect(_on_sell_mode)
	close_button.pressed.connect(close)
	item_list.item_selected.connect(_on_item_selected)
	item_list.item_activated.connect(_on_item_activated)

func _process(_delta: float) -> void:
	if visible:
		coins_label.text = "💰 " + str(GameData.coins)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				close()

## 打开商店
func open_shop(shop_name: String, items: Array) -> void:
	_current_shop_name = shop_name
	_shop_items = items
	_is_sell_mode = false
	mode_label.text = "购买模式"
	title_label.text = shop_name
	visible = true
	shop_panel.visible = true
	get_tree().paused = true
	_refresh_item_list()

## 关闭商店
func close() -> void:
	visible = false
	shop_panel.visible = false
	get_tree().paused = false

## 刷新物品列表
func _refresh_item_list() -> void:
	item_list.clear()
	if _is_sell_mode:
		# 出售模式: 显示背包物品
		for item in GameData.inventory:
			var sell_price = int(item.price * 0.5)
			var prefix := _get_type_prefix(item.type)
			item_list.add_item("%s%s (卖出: %dG)" % [prefix, item.name, sell_price])
			if item.count > 1:
				item_list.set_item_metadata(item_list.item_count - 1, {"item": item, "price": sell_price})
	else:
		# 购买模式: 显示商店物品
		for item in _shop_items:
			var prefix := _get_type_prefix(item.type)
			item_list.add_item("%s%s (购入: %dG)" % [prefix, item.name, item.price])
			item_list.set_item_metadata(item_list.item_count - 1, {"item": item, "price": item.price})

	_current_index = 0
	if item_list.item_count > 0:
		item_list.select(0)
		_on_item_selected(0)

## 获取类型前缀
func _get_type_prefix(type: int) -> String:
	match type:
		GameData.Item.ItemType.CONSUMABLE: return "🧪 "
		GameData.Item.ItemType.WEAPON: return "⚔ "
		GameData.Item.ItemType.ARMOR: return "🛡 "
		GameData.Item.ItemType.ACCESSORY: return "💍 "
		GameData.Item.ItemType.KEY_ITEM: return "🔑 "
		_: return ""

## 选中物品
func _on_item_selected(index: int) -> void:
	_current_index = index
	if index < 0 or index >= item_list.item_count:
		info_label.text = ""
		return
	var meta = item_list.get_item_metadata(index)
	if meta == null:
		return
	var item = meta["item"]
	var price = int(meta["price"])
	var mode_text = "卖出" if _is_sell_mode else "购入"
	info_label.text = "[b][color=#ffcc44]%s[/color][/b]\n\n%s\n\n%s价格: %dG" % [item.name, item.description, mode_text, price]
	if item.type == GameData.Item.ItemType.WEAPON:
		info_label.text += "\n攻击力: +%d" % item.attack
	elif item.type == GameData.Item.ItemType.ARMOR:
		info_label.text += "\n防御力: +%d" % item.defense
	elif item.type == GameData.Item.ItemType.ACCESSORY:
		info_label.text += "\n速度: +%d" % item.speed

## 双击购买/出售
func _on_item_activated(index: int) -> void:
	if _is_sell_mode:
		_do_sell(index)
	else:
		_do_buy(index)

## 购买
func _on_buy() -> void:
	if _is_sell_mode:
		_is_sell_mode = false
		mode_label.text = "购买模式"
		_refresh_item_list()
		return
	_do_buy(_current_index)

func _do_buy(index: int) -> void:
	if index < 0 or index >= _shop_items.size():
		return
	var item = _shop_items[index]
	if GameData.coins < item.price:
		info_label.text = "[color=#ff4444]金币不足！[/color]"
		return
	GameData.coins -= item.price
	# 创建物品副本
	var new_item := GameData.Item.new()
	new_item.id = item.id
	new_item.name = item.name
	new_item.description = item.description
	new_item.type = item.type
	new_item.count = 1
	new_item.price = item.price
	new_item.attack = item.attack
	new_item.defense = item.defense
	new_item.speed = item.speed
	new_item.stackable = item.stackable
	GameData.add_item(new_item)
	info_label.text = "[color=#44ff44]购买了 %s！[/color]" % item.name
	_refresh_item_list()

## 切换到出售模式
func _on_sell_mode() -> void:
	if not _is_sell_mode:
		_is_sell_mode = true
		mode_label.text = "出售模式"
		_refresh_item_list()
	else:
		_do_sell(_current_index)

func _do_sell(index: int) -> void:
	if index < 0 or index >= GameData.inventory.size():
		return
	var item = GameData.inventory[index]
	var sell_price = int(item.price * 0.5)
	GameData.coins += sell_price
	GameData.inventory.erase(item)
	info_label.text = "[color=#44ff44]卖出了 %s (+%dG)[/color]" % [item.name, sell_price]
	_refresh_item_list()
