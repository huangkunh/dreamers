extends Control
## 对话系统 (DialogSystem)
## HD-2D 风格的对话框，支持逐字显示、选项分支、对话队列
## 使用方式:
##   DialogSystem.show_dialog("NPC名", "对话文本")
##   DialogSystem.show_dialog_queue([{"name":"A","text":"..."}, ...])

signal dialog_finished()
signal choice_made(index: int)

@onready var dialog_panel: PanelContainer = $DialogPanel
@onready var name_label: Label = $DialogPanel/MarginContainer/VBoxContainer/NameLabel
@onready var text_label: RichTextLabel = $DialogPanel/MarginContainer/VBoxContainer/TextLabel
@onready var choice_container: VBoxContainer = $DialogPanel/MarginContainer/VBoxContainer/ChoiceContainer
@onready var continue_indicator: Label = $DialogPanel/MarginContainer/VBoxContainer/ContinueIndicator

var _full_text: String = ""
var _displayed_chars: int = 0
var _chars_per_second: float = 30.0
var _is_typing: bool = false
var _is_showing_choices: bool = false
var _current_choice_index: int = 0
var _choice_buttons: Array[Button] = []
var _dialog_queue: Array = []

func _ready() -> void:
	visible = false
	dialog_panel.visible = false
	continue_indicator.visible = false

func _process(delta: float) -> void:
	if _is_typing:
		_displayed_chars += int(_chars_per_second * delta)
		if _displayed_chars >= _full_text.length():
			_displayed_chars = _full_text.length()
			_is_typing = false
			continue_indicator.visible = true
		text_label.visible_characters = _displayed_chars

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		if _is_typing:
			# 跳过逐字显示
			_displayed_chars = _full_text.length()
			text_label.visible_characters = _displayed_chars
			_is_typing = false
			continue_indicator.visible = true
		elif _is_showing_choices:
			# 选项模式下不处理
			pass
		else:
			# 显示下一段对话
			_show_next_in_queue()
		get_viewport().set_input_as_handled()

	elif _is_showing_choices:
		if event.is_action_pressed("ui_up"):
			_current_choice_index = wrapi(_current_choice_index - 1, 0, _choice_buttons.size())
			_update_choice_selection()
		elif event.is_action_pressed("ui_down"):
			_current_choice_index = wrapi(_current_choice_index + 1, 0, _choice_buttons.size())
			_update_choice_selection()
		elif event.is_action_pressed("ui_accept"):
			if _current_choice_index < _choice_buttons.size():
				choice_made.emit(_current_choice_index)
				_close_dialog()

## 显示单段对话
func show_dialog(npc_name: String, text: String) -> void:
	_dialog_queue = [{"name": npc_name, "text": text}]
	_show_next_in_queue()

## 显示对话队列
func show_dialog_queue(dialogs: Array) -> void:
	_dialog_queue = dialogs.duplicate()
	_show_next_in_queue()

## 显示选项
func show_choices(prompt: String, choices: Array[String]) -> void:
	visible = true
	dialog_panel.visible = true
	name_label.text = ""
	_full_text = prompt
	_displayed_chars = 0
	text_label.visible_characters = 0
	_is_typing = true
	continue_indicator.visible = false

	# 清除旧选项
	for child in choice_container.get_children():
		child.queue_free()
	_choice_buttons.clear()

	# 创建选项按钮
	for i in range(choices.size()):
		var btn := Button.new()
		btn.text = choices[i]
		btn.custom_minimum_size = Vector2(300, 36)
		choice_container.add_child(btn)
		_choice_buttons.append(btn)

	_current_choice_index = 0
	_is_showing_choices = false  # 等文字打完再显示选项

## 关闭对话
func _close_dialog() -> void:
	visible = false
	dialog_panel.visible = false
	_is_showing_choices = false
	_is_typing = false
	_dialog_queue.clear()
	for child in choice_container.get_children():
		child.queue_free()
	dialog_finished.emit()

## 显示队列中的下一段对话
func _show_next_in_queue() -> void:
	if _dialog_queue.is_empty():
		_close_dialog()
		return
	var d = _dialog_queue.pop_front()
	visible = true
	dialog_panel.visible = true
	name_label.text = d.get("name", "")
	_full_text = d.get("text", "")
	_displayed_chars = 0
	text_label.visible_characters = 0
	_is_typing = true
	continue_indicator.visible = false

## 更新选项选中状态
func _update_choice_selection() -> void:
	for i in range(_choice_buttons.size()):
		var btn := _choice_buttons[i]
		if i == _current_choice_index:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
			btn.grab_focus()
		else:
			btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.65))

## 快捷方法: 显示提示信息
func show_message(text: String) -> void:
	show_dialog("系统", text)
