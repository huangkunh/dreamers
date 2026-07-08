extends Control
## 对话框UI (DialogueBox)
## 显示对话文本、说话者名字、选项
## 由 DialogueManager 控制

@onready var speaker_label: Label = $Panel/SpeakerLabel
@onready var text_label: RichTextLabel = $Panel/TextLabel
@onready var choices_container: VBoxContainer = $Panel/ChoicesContainer
@onready var continue_hint: Label = $Panel/ContinueHint

var _choice_buttons: Array[Button] = []
var _choice_index: int = 0

func _ready() -> void:
	visible = false
	continue_hint.modulate.a = 0.0

func _process(_delta: float) -> void:
	# 处理选项导航
	if visible and choices_container.visible and _choice_buttons.size() > 0:
		if Input.is_action_just_pressed("move_up"):
			_choice_index = (_choice_index - 1 + _choice_buttons.size()) % _choice_buttons.size()
			_update_choice_highlight()
		elif Input.is_action_just_pressed("move_down"):
			_choice_index = (_choice_index + 1) % _choice_buttons.size()
			_update_choice_highlight()
		elif Input.is_action_just_pressed("ui_accept"):
			DialogueManager.select_choice(_choice_index)

## 设置说话者名字
func set_speaker(name: String) -> void:
	speaker_label.text = name
	speaker_label.visible = name != ""

## 设置对话文本
func set_text(text: String) -> void:
	text_label.text = text
	if not DialogueManager._is_typing:
		_show_continue_hint()

## 设置选项
func set_choices(choices: Array) -> void:
	for child in choices_container.get_children():
		child.queue_free()
	_choice_buttons.clear()

	if choices.is_empty():
		choices_container.visible = false
		return

	choices_container.visible = true
	_choice_index = 0

	for i in range(choices.size()):
		var choice = choices[i]
		var btn := Button.new()
		btn.text = choice.get("text", "选项" + str(i + 1))
		btn.custom_minimum_size = Vector2(400, 36)
		btn.add_theme_font_size_override("font_size", 18)
		btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		btn.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.3))
		btn.focus_mode = Control.FOCUS_NONE
		choices_container.add_child(btn)
		_choice_buttons.append(btn)

	_update_choice_highlight()

## 更新选项高亮
func _update_choice_highlight() -> void:
	for i in range(_choice_buttons.size()):
		var btn = _choice_buttons[i]
		if i == _choice_index:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		else:
			btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.6))

## 显示继续提示
func _show_continue_hint() -> void:
	var tw := create_tween()
	tw.tween_property(continue_hint, "modulate:a", 1.0, 0.3)
	var tw2 := create_tween()
	tw2.set_loops()
	tw2.tween_property(continue_hint, "modulate:a", 0.3, 0.6)
	tw2.tween_property(continue_hint, "modulate:a", 1.0, 0.6)
