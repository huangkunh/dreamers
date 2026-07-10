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
var _has_choices: bool = false

func _ready() -> void:
	visible = false
	continue_hint.modulate.a = 0.0

func _process(_delta: float) -> void:
	if not visible:
		return
	# 处理选项导航
	if _has_choices and _choice_buttons.size() > 0:
		if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up"):
			_choice_index = (_choice_index - 1 + _choice_buttons.size()) % _choice_buttons.size()
			_update_choice_highlight()
		elif Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down"):
			_choice_index = (_choice_index + 1) % _choice_buttons.size()
			_update_choice_highlight()
	# 推进对话
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
		if not _has_choices:
			DialogueManager.advance()

## 显示选项
func show_choices(choices: Array) -> void:
	_choice_buttons.clear()
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = "  " + choice.get("text", "???")
		btn.pressed.connect(_on_choice_selected.bind(i, choice))
		choices_container.add_child(btn)
		_choice_buttons.append(btn)
	
	_choice_index = 0
	_has_choices = choices.size() > 0
	choices_container.visible = _has_choices
	_update_choice_highlight()

## 选项被选择
func _on_choice_selected(index: int, choice: Dictionary) -> void:
	_has_choices = false
	choices_container.visible = false
	var next_id = choice.get("next_id", "")
	var event = choice.get("event", "")
	if not event.is_empty():
		DialogueManager.event_triggered.emit(event)
	if not next_id.is_empty():
		DialogueManager._current_id = next_id
		DialogueManager._show_current_line()
	else:
		DialogueManager._end_dialogue()

## 更新选项高亮
func _update_choice_highlight() -> void:
	for i in range(_choice_buttons.size()):
		var btn = _choice_buttons[i]
		if i == _choice_index:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		else:
			btn.add_theme_color_override("font_color", Color(0.7, 0.7, 0.6))

## 显示继续提示
func show_continue_hint() -> void:
	continue_hint.visible = true
	var tw := create_tween()
	tw.tween_property(continue_hint, "modulate:a", 1.0, 0.3)
	var tw2 := create_tween()
	tw2.set_loops()
	tw2.tween_property(continue_hint, "modulate:a", 0.3, 0.6)
	tw2.tween_property(continue_hint, "modulate:a", 1.0, 0.6)
