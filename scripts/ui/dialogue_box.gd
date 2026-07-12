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
## 输入处理锁，防止重复触发
var _input_locked: bool = false
## 输入锁定计时器
var _input_lock_timer: float = 0.0
## 最小输入间隔(秒)
const INPUT_COOLDOWN: float = 0.15

func _ready() -> void:
	visible = false
	continue_hint.modulate.a = 0.0

func _process(delta: float) -> void:
	# 处理输入冷却
	if _input_locked:
		_input_lock_timer += delta
		if _input_lock_timer >= INPUT_COOLDOWN:
			_input_locked = false
			_input_lock_timer = 0.0
		return
	
	if not visible:
		return
	
	# 检查DialogueManager是否处于活动状态
	if not DialogueManager or not DialogueManager.is_active():
		return
	
	# 处理选项导航
	if _has_choices and _choice_buttons.size() > 0:
		_handle_choice_navigation()
	else:
		# 推进对话 (无选项时)
		_handle_advance_input()

## 处理选项导航输入
func _handle_choice_navigation() -> void:
	var input_handled := false
	
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up"):
		_choice_index = (_choice_index - 1 + _choice_buttons.size()) % _choice_buttons.size()
		_update_choice_highlight()
		input_handled = true
	elif Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down"):
		_choice_index = (_choice_index + 1) % _choice_buttons.size()
		_update_choice_highlight()
		input_handled = true
	elif Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
		if _choice_index >= 0 and _choice_index < _choice_buttons.size():
			_lock_input()
			_choice_buttons[_choice_index].emit_signal("pressed")
			input_handled = true
	
	if input_handled:
		_lock_input()

## 处理对话推进输入
func _handle_advance_input() -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
		_lock_input()
		DialogueManager.advance()

## 锁定输入防止重复触发
func _lock_input() -> void:
	_input_locked = true
	_input_lock_timer = 0.0

## 显示选项
func show_choices(choices: Array) -> void:
	_choice_buttons.clear()
	for child in choices_container.get_children():
		child.queue_free()
	
	for i in range(choices.size()):
		var choice: Dictionary = choices[i]
		var btn := Button.new()
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
	var next_id: String = choice.get("next_id", "")
	var event: String = choice.get("event", "")
	if not event.is_empty():
		DialogueManager.event_triggered.emit(event)
	if not next_id.is_empty():
		DialogueManager.set_current_id(next_id)
		DialogueManager.show_current_line()
	else:
		DialogueManager.end_dialogue()

## 更新选项高亮
func _update_choice_highlight() -> void:
	for i in range(_choice_buttons.size()):
		if i == _choice_index:
			_choice_buttons[i].add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		else:
			_choice_buttons[i].remove_theme_color_override("font_color")

## 显示继续提示
func show_continue_hint() -> void:
	continue_hint.visible = true
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(continue_hint, "modulate:a", 1.0, 0.5)
	tw.tween_property(continue_hint, "modulate:a", 0.3, 0.5)

## 隐藏继续提示
func hide_continue_hint() -> void:
	continue_hint.visible = false
	continue_hint.modulate.a = 0.0

## 重置输入状态
func reset_input_state() -> void:
	_input_locked = false
	_input_lock_timer = 0.0
	_choice_index = 0
	_has_choices = false
