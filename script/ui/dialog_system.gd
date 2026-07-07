extends Control
## 对话系统 (DialogSystem)
## HD-2D 风格的对话框，支持逐字显示、选项分支
## 使用方式: DialogSystem.show_dialog("NPC名", "对话文本")
##            DialogSystem.show_choices("选择", ["选项A", "选项B"], callback)

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

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if _is_showing_choices:
			match event.keycode:
				KEY_UP, KEY_W:
					_current_choice_index = (_current_choice_index - 1 + _choice_buttons.size()) % _choice_buttons.size()
					_update_choice_selection()
				KEY_DOWN, KEY_S:
					_current_choice_index = (_current_choice_index + 1) % _choice_buttons.size()
					_update_choice_selection()
				KEY_ENTER, KEY_SPACE:
					choice_made.emit(_current_choice_index)
					_close_dialog()
		elif _is_typing:
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				_displayed_chars = _full_text.length()
				text_label.visible_characters = _displayed_chars
				_is_typing = false
				continue_indicator.visible = true
		else:
			if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
				continue_indicator.visible = false
				if _dialog_queue.size() > 0:
					_show_next_in_queue()
				else:
					dialog_finished.emit()
					_close_dialog()

## 显示对话
func show_dialog(speaker_name: String, text: String) -> void:
	_dialog_queue.append({"name": speaker_name, "text": text})
	if not visible:
		_show_next_in_queue()

## 显示多段对话
func show_dialog_chain(dialogs: Array) -> void:
	for d in dialogs:
		_dialog_queue.append(d)
	if not visible:
		_show_next_in_queue()

## 显示选项
func show_choices(speaker_name: String, text: String, choices: Array[String]) -> void:
	visible = true
	dialog_panel.visible = true
	_is_showing_choices = false
	name_label.text = speaker_name
	_full_text = text
	_displayed_chars = 0
	text_label.visible_characters = 0
	_is_typing = true

	# 等待打字完成后显示选项
	# 这里先存储选项, 打字完成后自动显示
	_choice_buttons.clear()
	for child in choice_container.get_children():
		child.queue_free()

	# 延迟显示选项
	await get_tree().create_timer(text.length() / _chars_per_second + 0.5).timeout

	_is_showing_choices = true
	_current_choice_index = 0
	for i in range(choices.size()):
		var btn := Button.new()
		btn.text = choices[i]
		btn.custom_minimum_size = Vector2(300, 36)
		btn.add_theme_font_size_override("font_size", 18)
		btn.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
		btn.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.3))
		choice_container.add_child(btn)
		_choice_buttons.append(btn)
	_update_choice_selection()

## 关闭对话
func _close_dialog() -> void:
	visible = false
	dialog_panel.visible = false
	_is_showing_choices = false
	_is_typing = false
	_dialog_queue.clear()
	for child in choice_container.get_children():
		child.queue_free()

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
