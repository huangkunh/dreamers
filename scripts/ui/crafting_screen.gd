extends Control
## 合成界面 (CraftingScreen)
## 显示合成配方列表，允许玩家合成物品

@onready var recipe_container: VBoxContainer = $Panel/ScrollContainer/RecipeContainer
@onready var detail_label: RichTextLabel = $Panel/DetailPanel/DetailLabel
@onready var craft_button: Button = $Panel/DetailPanel/CraftButton
@onready var coins_label: Label = $Panel/TopBar/CoinsLabel
@onready var close_button: Button = $Panel/CloseButton

var _current_recipe = null
var _recipe_buttons: Array = []

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close)
	craft_button.pressed.connect(_on_craft)

## 打开合成界面
func open() -> void:
	_refresh_recipes()
	visible = true

## 刷新配方列表
func _refresh_recipes() -> void:
	# 清除旧内容
	for child in recipe_container.get_children():
		child.queue_free()
	_recipe_buttons.clear()

	coins_label.text = "💰 " + str(GameData.coins) + " G"

	# 显示所有已解锁配方
	var all_recipes = CraftingSystem.get_all_recipes()
	for recipe in all_recipes:
		var btn := Button.new()
		var can_make = CraftingSystem.can_craft(recipe.id)
		btn.text = ("✓ " if can_make else "✗ ") + recipe.result_name
		btn.custom_minimum_size = Vector2(250, 36)
		btn.add_theme_font_size_override("font_size", 16)
		if can_make:
			btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		btn.pressed.connect(_on_recipe_selected.bind(recipe))
		recipe_container.add_child(btn)
		_recipe_buttons.append(btn)

## 选择配方
func _on_recipe_selected(recipe) -> void:
	_current_recipe = recipe
	_update_detail()

## 更新详情
func _update_detail() -> void:
	if not _current_recipe:
		return

	var text = "[b][color=#ffcc44]%s[/color][/b]\n\n" % _current_recipe.result_name
	text += "[color=#88ff88]%s[/color]\n\n" % CraftingSystem.get_result_description(_current_recipe.result_id)
	text += "[b]所需材料:[/b]\n"

	var can_make = true
	for mat_id in _current_recipe.materials.keys():
		var need = _current_recipe.materials[mat_id]
		var have = CraftingSystem._count_item(mat_id)
		var color = "#88ff88" if have >= need else "#ff4444"
		text += "[color=%s]  %s: %d/%d[/color]\n" % [color, mat_id, have, need]
		if have < need:
			can_make = false

	if _current_recipe.coins_cost > 0:
		var coins_color = "#88ff88" if GameData.coins >= _current_recipe.coins_cost else "#ff4444"
		text += "\n[color=%s]💰 金币: %d/%d[/color]" % [coins_color, GameData.coins, _current_recipe.coins_cost]
		if GameData.coins < _current_recipe.coins_cost:
			can_make = false

	detail_label.text = text
	craft_button.disabled = not can_make

## 合成
func _on_craft() -> void:
	if not _current_recipe:
		return
	if CraftingSystem.craft(_current_recipe.id):
		_refresh_recipes()
		_update_detail()

## 关闭
func close() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
