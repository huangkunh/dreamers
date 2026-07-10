extends Control
## 成就界面 (AchievementScreen)
## 显示所有成就及其解锁状态

@onready var grid_container: GridContainer = $Panel/ScrollContainer/GridContainer
@onready var stats_label: Label = $Panel/StatsLabel
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close)

## 打开成就界面
func open() -> void:
	_refresh_achievements()
	visible = true

## 刷新成就列表
func _refresh_achievements() -> void:
	# 清除旧内容
	for child in grid_container.get_children():
		child.queue_free()

	# 更新统计
	var unlocked = AchievementSystem.get_unlocked_count()
	var total = AchievementSystem.get_total_count()
	stats_label.text = "已解锁: %d / %d" % [unlocked, total]

	# 创建成就卡片
	var achievements = AchievementSystem.get_achievement_list()
	for ach in achievements:
		var card := _create_achievement_card(ach)
		grid_container.add_child(card)

## 创建单个成就卡片
func _create_achievement_card(ach: Dictionary) -> Panel:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(280, 80)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8
	vbox.add_theme_constant_override("separation", 2)
	panel.add_child(vbox)

	# 图标 + 名称
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)

	var icon_label := Label.new()
	icon_label.text = ach.icon
	icon_label.custom_minimum_size = Vector2(30, 0)
	icon_label.add_theme_font_size_override("font_size", 20)
	if ach.unlocked:
		icon_label.modulate = Color(1, 0.85, 0.3)
	else:
		icon_label.modulate = Color(0.4, 0.4, 0.4)
	header.add_child(icon_label)

	var name_label := Label.new()
	name_label.text = ach.name
	name_label.add_theme_font_size_override("font_size", 16)
	if ach.unlocked:
		name_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	else:
		name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	header.add_child(name_label)

	vbox.add_child(header)

	# 描述
	var desc_label := Label.new()
	desc_label.text = ach.description
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)

	# 状态标签
	var status_label := Label.new()
	if ach.unlocked:
		status_label.text = "✓ 已解锁"
		status_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
	else:
		status_label.text = "🔒 未解锁"
		status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	status_label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(status_label)

	return panel

## 关闭
func close() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
