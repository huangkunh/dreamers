extends Node
## 剧情演出管理器 (CutscenePlayer)
## 控制剧情演出序列：黑屏旁白 → 区域名演出 → 对话 → 屏幕效果
## 附加到城市场景根节点，由 CityExplorer 创建

signal cutscene_finished()

## 演出是否正在播放
var is_playing: bool = false

## 内部引用
var _overlay: ColorRect
var _title_label: Label
var _subtitle_label: Label
var _body_label: RichTextLabel
var _canvas_layer: CanvasLayer
var _parent: Node

## 当前演出步骤队列
var _steps: Array = []
var _step_index: int = 0

func _init(parent: Node) -> void:
	_parent = parent

func _ready() -> void:
	_build_ui()

## 构建UI层
func _build_ui() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 90
	_canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_parent.add_child(_canvas_layer)

	# 全屏黑色遮罩
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 1.0)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.modulate.a = 0.0
	_canvas_layer.add_child(_overlay)

	# 区域名标题
	_title_label = Label.new()
	_title_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_title_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_title_label.position = Vector2(0, 200)
	_title_label.size = Vector2(1280, 80)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
	_title_label.modulate.a = 0.0
	_canvas_layer.add_child(_title_label)

	# 副标题
	_subtitle_label = Label.new()
	_subtitle_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_subtitle_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_subtitle_label.position = Vector2(0, 275)
	_subtitle_label.size = Vector2(1280, 40)
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle_label.add_theme_font_size_override("font_size", 22)
	_subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_subtitle_label.modulate.a = 0.0
	_canvas_layer.add_child(_subtitle_label)

	# 旁白/描述文字
	_body_label = RichTextLabel.new()
	_body_label.set_anchors_preset(Control.PRESET_CENTER)
	_body_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_body_label.grow_vertical = Control.GROW_DIRECTION_BOTH
	_body_label.position = Vector2(140, 360)
	_body_label.size = Vector2(1000, 200)
	_body_label.add_theme_font_size_override("normal_font_size", 24)
	_body_label.add_theme_color_override("default_color", Color(0.85, 0.85, 0.85))
	_body_label.bbcode_enabled = true
	_body_label.modulate.a = 0.0
	_canvas_layer.add_child(_body_label)

## 开始播放演出序列
## steps: Array of step dicts, each step has:
##   "type": "narrate" | "area_title" | "dialogue" | "fade_out" | "wait"
##   + type-specific fields
func play(steps: Array) -> void:
	_steps = steps
	_step_index = 0
	is_playing = true
	get_tree().paused = true
	_play_next_step()

## 播放下一步
func _play_next_step() -> void:
	if _step_index >= _steps.size():
		_on_cutscene_done()
		return

	var step: Dictionary = _steps[_step_index]
	_step_index += 1

	match step.type:
		"narrate":
			_play_narrate(step)
		"area_title":
			_play_area_title(step)
		"dialogue":
			_play_dialogue(step)
		"fade_out":
			_play_fade_out(step)
		"wait":
			_play_wait(step)
		"fade_in":
			_play_fade_in(step)
		_:
			_play_next_step()

## 旁白演出：黑屏 + 逐字显示文字
func _play_narrate(step: Dictionary) -> void:
	_overlay.modulate.a = 1.0
	_title_label.modulate.a = 0.0
	_subtitle_label.modulate.a = 0.0
	_body_label.modulate.a = 1.0

	var text: String = step.get("text", "")
	var speaker: String = step.get("speaker", "")
	var duration: float = step.get("duration", 0.0)  # 0 = auto calc
	var fade_in_time: float = step.get("fade_in", 1.0)

	_body_label.text = ""
	if speaker != "":
		_body_label.text = "[color=#ffcc44]%s[/color]\n" % speaker
	_body_label.text += text

	# 淡入文字
	var tw := create_tween()
	tw.tween_property(_body_label, "modulate:a", 1.0, fade_in_time)

	# 打字机效果 - 逐字显示
	_body_label.visible_characters = 0
	var total_chars = _body_label.get_total_character_count()
	var type_time = max(2.0, total_chars / 20.0)  # 20字符/秒

	var tw2 := create_tween()
	tw2.tween_property(_body_label, "visible_characters", total_chars, type_time)
	tw2.tween_interval(0.5)

	# 等待用户按键或自动超时
	if duration > 0:
		tw2.tween_callback(_play_next_step)
	else:
		# 等待用户按确认键
		tw2.tween_callback(func(): _waiting_for_advance = true)

var _waiting_for_advance: bool = false

func _process(_delta: float) -> void:
	if not is_playing:
		return
	if _waiting_for_advance:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("interact"):
			_waiting_for_advance = false
			_play_next_step()

## 区域名演出：类似八方旅人的区域名渐入
func _play_area_title(step: Dictionary) -> void:
	_overlay.modulate.a = 1.0
	_body_label.modulate.a = 0.0

	var title: String = step.get("title", "")
	var subtitle: String = step.get("subtitle", "")
	var hold_time: float = step.get("hold", 2.5)

	_title_label.text = title
	_subtitle_label.text = subtitle

	# 标题淡入
	var tw := create_tween()
	_title_label.modulate.a = 0.0
	_subtitle_label.modulate.a = 0.0
	tw.tween_property(_title_label, "modulate:a", 1.0, 1.2)
	tw.tween_property(_subtitle_label, "modulate:a", 1.0, 0.8)
	tw.tween_interval(hold_time)
	tw.tween_property(_title_label, "modulate:a", 0.0, 0.8)
	tw.tween_property(_subtitle_label, "modulate.a", 0.0, 0.6)
	tw.tween_callback(_play_next_step)

## 对话演出：启动 DialogueManager
func _play_dialogue(step: Dictionary) -> void:
	var file: String = step.get("file", "")
	var start_id: String = step.get("start_id", "start")

	if file != "":
		var dialogue_data = DialogueManager.load_dialogue_from_file(file)
		DialogueManager.dialogue_finished.connect(_on_dialogue_done, CONNECT_ONE_SHOT)
		DialogueManager.start_dialogue(dialogue_data, start_id)
	else:
		_play_next_step()

func _on_dialogue_done() -> void:
	_play_next_step()

## 屏幕淡出到黑
func _play_fade_out(step: Dictionary) -> void:
	var duration: float = step.get("duration", 1.0)
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate:a", 1.0, duration)
	tw.tween_callback(_play_next_step)

## 屏幕淡入到透明
func _play_fade_in(step: Dictionary) -> void:
	var duration: float = step.get("duration", 1.0)
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate.a", 0.0, duration)
	tw.tween_callback(_play_next_step)

## 等待一段时间
func _play_wait(step: Dictionary) -> void:
	var duration: float = step.get("duration", 1.0)
	var tw := create_tween()
	tw.tween_interval(duration)
	tw.tween_callback(_play_next_step)

## 演出完成
func _on_cutscene_done() -> void:
	is_playing = false
	_waiting_for_advance = false
	# 确保遮罩透明
	var tw := create_tween()
	tw.tween_property(_overlay, "modulate.a", 0.0, 0.5)
	tw.tween_callback(func():
		get_tree().paused = false
		cutscene_finished.emit()
	)
