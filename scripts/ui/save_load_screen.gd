extends Control
## 存档/读档界面 (SaveLoadScreen)
## 显示存档槽位列表，支持保存和读取

enum Mode { SAVE, LOAD }

@onready var title_label: Label = $Panel/TitleLabel
@onready var slot_container: VBoxContainer = $Panel/ScrollContainer/SlotContainer
@onready var back_button: Button = $Panel/BackButton

var _mode: int = Mode.SAVE
var _slots: Array[Control] = []

const MAX_SLOTS: int = 3

## 是否正在处理操作
var _is_processing: bool = false
## 当前选中的槽位
var _selected_slot: int = 0
## 确认对话框
var _confirm_dialog: ConfirmationDialog = null

func _ready() -> void:
	visible = false
	_is_processing = false
	_selected_slot = 0
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	back_button.pressed.connect(_on_back_pressed)

## 打开存档界面
func open_save() -> void:
	if _is_processing:
		return
	_mode = Mode.SAVE
	title_label.text = "保存进度"
	_refresh_slots()
	visible = true
	_is_processing = false

## 打开读档界面
func open_load() -> void:
	if _is_processing:
		return
	_mode = Mode.LOAD
	title_label.text = "读取进度"
	_refresh_slots()
	visible = true
	_is_processing = false

## 返回按钮处理
func _on_back_pressed() -> void:
	if _is_processing:
		return
	close()

## 关闭
func close() -> void:
	if _is_processing:
		return
	visible = false
	# 使用延迟释放确保所有信号处理完成
	var timer := get_tree().create_timer(0.1)
	timer.timeout.connect(_do_close)

## 实际关闭操作
func _do_close() -> void:
	queue_free()

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

	var has_save: bool = SaveSystem.has_save_slot(slot_num)
	if has_save:
		var save_info: Dictionary = SaveSystem.get_save_info(slot_num)
		var play_time: float = save_info.get("play_time", 0.0)
		var coins: int = save_info.get("coins", 0)
		var area: String = save_info.get("area", "???")
		info_label.text = "时间: %s | 金币: %dG | 区域: %s" % [_format_time(play_time), coins, area]
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
	if _is_processing:
		return
	
	print("[SaveLoadScreen] 保存到槽位 ", slot_num)
	_is_processing = true
	_selected_slot = slot_num
	
	# 检查是否覆盖已有存档
	if SaveSystem.has_save_slot(slot_num):
		_show_confirm_dialog("覆盖存档", "槽位 %d 已有存档，是否覆盖？" % slot_num, 
			func(): _do_save(slot_num), 
			func(): _is_processing = false)
	else:
		_do_save(slot_num)

## 执行保存
func _do_save(slot_num: int) -> void:
	var success: bool = SaveSystem.save_game(slot_num)
	if success:
		print("[SaveLoadScreen] 保存成功")
	else:
		push_error("[SaveLoadScreen] 保存失败")
	
	_is_processing = false
	close()

## 从指定槽位读取
func _on_load_slot(slot_num: int) -> void:
	if _is_processing:
		return
	
	print("[SaveLoadScreen] 读取槽位 ", slot_num)
	_is_processing = true
	_selected_slot = slot_num
	
	_show_confirm_dialog("读取存档", "确定要读取槽位 %d 的存档吗？当前进度将丢失。" % slot_num,
		func(): _do_load(slot_num),
		func(): _is_processing = false)

## 执行读取
func _do_load(slot_num: int) -> void:
	var success: bool = SaveSystem.load_game(slot_num)
	if success:
		print("[SaveLoadScreen] 读取成功")
	else:
		push_error("[SaveLoadScreen] 读取失败")
	
	_is_processing = false
	close()

## 显示确认对话框
func _show_confirm_dialog(title: String, message: String, on_confirm: Callable, on_cancel: Callable) -> void:
	# 创建简单的确认对话框
	var dialog := ConfirmationDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.ok_button_text = "确定"
	dialog.cancel_button_text = "取消"
	dialog.confirmed.connect(on_confirm)
	dialog.canceled.connect(on_cancel)
	add_child(dialog)
	dialog.popup_centered()
	_confirm_dialog = dialog

func _input(event: InputEvent) -> void:
	if visible and not _is_processing and event.is_action_pressed("ui_cancel"):
		close()

## 格式化游戏时间
func _format_time(seconds: float) -> String:
	var s := int(seconds)
	var h := s / 3600
	var m := (s % 3600) / 60
	var sec := s % 60
	return "%02d:%02d:%02d" % [h, m, sec]
