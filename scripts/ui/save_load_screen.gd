extends Control
## 存档/读档界面 (SaveLoadScreen)
## 显示存档槽位列表，支持保存和读取

enum Mode { SAVE, LOAD }

@onready var title_label: Label = $Panel/TitleLabel
@onready var slot_container: VBoxContainer = $Panel/ScrollContainer/SlotContainer
@onready var back_button: Button = $Panel/BackButton

var _mode: int = Mode.SAVE
var _slots: Array[Control] = []

const MAX_SLOTS := 3

func _ready() -> void:
	visible = false
	back_button.pressed.connect(close)

## 打开存档界面
func open_save() -> void:
	_mode = Mode.SAVE
	title_label.text = "保存进度"
	_refresh_slots()
	visible = true

## 打开读档界面
func open_load() -> void:
	_mode = Mode.LOAD
	title_label.text = "读取进度"
	_refresh_slots()
	visible = true

## 关闭
func close() -> void:
	visible = false

## 刷新存档槽位
func _refresh_slots() -> void:
	# 清除旧槽位
	for child in slot_container.get_children():
		child.queue_free()
	_slots.clear()

	for i in range(1, MAX_SLOTS + 1):
		var slot := _create_slot(i)
		slot_container.add_child(slot)
		_slots.append(slot)

## 创建单个存档槽位
func _create_slot(slot_num: int) -> Control:
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(600, 80)

	var hbox := HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 10
	hbox.offset_top = 10
	hbox.offset_right = -10
	hbox.offset_bottom = -10
	panel.add_child(hbox)

	# 槽位号
	var num_label := Label.new()
	num_label.text = "槽位 %d" % slot_num
	num_label.custom_minimum_size = Vector2(80, 0)
	num_label.add_theme_font_size_override("font_size", 20)
	num_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	hbox.add_child(num_label)

	# 存档信息
	var info_label := Label.new()
	info_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_label.add_theme_font_size_override("font_size", 16)

	var has_save := SaveSystem.has_save_data()
	if has_save:
		# TODO: 显示存档详情 (游戏时间、金币等)
		info_label.text = "存档存在 - 点击%s" % ("覆盖" if _mode == Mode.SAVE else "读取")
		info_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	else:
		info_label.text = "空槽位" if _mode == Mode.SAVE else "无存档"
		info_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

	hbox.add_child(info_label)

	# 操作按钮
	var action_btn := Button.new()
	action_btn.custom_minimum_size = Vector2(100, 0)
	if _mode == Mode.SAVE:
		action_btn.text = "保存"
		action_btn.pressed.connect(_on_save_slot.bind(slot_num))
	else:
		action_btn.text = "读取"
		action_btn.pressed.connect(_on_load_slot.bind(slot_num))
		if not has_save:
			action_btn.disabled = true
	hbox.add_child(action_btn)

	return panel

## 保存到指定槽位
func _on_save_slot(slot_num: int) -> void:
	print("[SaveLoadScreen] 保存到槽位 ", slot_num)
	SaveSystem.save_game(slot_num)
	close()

## 从指定槽位读取
func _on_load_slot(slot_num: int) -> void:
	print("[SaveLoadScreen] 读取槽位 ", slot_num)
	SaveSystem.load_game(slot_num)
	close()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
