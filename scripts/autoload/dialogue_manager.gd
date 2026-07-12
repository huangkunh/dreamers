extends Node
## 对话管理器 (DialogueManager)
## 管理NPC对话、剧情对话的显示和推进
## 作为 Autoload 单例运行

signal dialogue_finished()
signal event_triggered(event_name: String)

## 对话数据结构
class DialogueLine:
	var speaker: String = ""
	var text: String = ""
	var portrait: String = ""
	var emotion: String = "normal"
	var choices: Array = []
	var next_id: String = ""
	var event: String = ""

## 对话框节点引用
var _dialogue_box: Control = null
## 当前对话数据 (ID -> DialogueLine)
var _dialogue: Dictionary = {}
## 当前对话行ID
var _current_id: String = ""
## 是否正在显示对话
var _is_active: bool = false
## 是否正在打字机效果中
var _is_typing: bool = false
## 当前显示的文本
var _displayed_text: String = ""
## 打字机速度 (字符/秒)
var _type_speed: float = 30.0
## 打字机计时器
var _type_timer: float = 0.0
## 对话队列 (简单队列模式)
var _dialogue_queue: Array = []
## 是否在队列模式
var _is_queue_mode: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if _is_active and _is_typing and _dialogue_box:
		_type_timer += delta
		var chars_to_show: int = int(_type_timer * _type_speed)
		if chars_to_show >= _displayed_text.length():
			_is_typing = false
			_dialogue_box.text_label.visible_characters = -1
			_dialogue_box.show_continue_hint()
		else:
			_dialogue_box.text_label.visible_characters = chars_to_show

## 设置对话框引用
func set_dialogue_box(box: Control) -> void:
	_dialogue_box = box

## 检查是否处于活动状态
func is_active() -> bool:
	return _is_active

## 设置当前对话ID (供dialogue_box调用)
func set_current_id(id: String) -> void:
	_current_id = id

## 显示当前对话行 (供dialogue_box调用)
func show_current_line() -> void:
	_show_current_line()

## 结束对话 (供dialogue_box调用)
func end_dialogue() -> void:
	_end_dialogue()

## 开始对话 (从字典数据)
func start_dialogue(data: Dictionary, start_id: String = "start") -> void:
	_dialogue = data
	_current_id = start_id
	_is_queue_mode = false
	_show_current_line()

## 开始对话队列 (简单模式: [{"speaker":"", "text":""}, ...])
func start_dialogue_queue(queue: Array) -> void:
	_dialogue_queue = queue.duplicate()
	_is_queue_mode = true
	_current_id = ""
	_show_next_in_queue()

## 显示队列中的下一段
func _show_next_in_queue() -> void:
	if _dialogue_queue.is_empty():
		_end_dialogue()
		return
	var line_data: Dictionary = _dialogue_queue.pop_front()
	_displayed_text = line_data.get("text", "")
	if _dialogue_box:
		_dialogue_box.visible = true
		_dialogue_box.reset_input_state()
		_dialogue_box.speaker_label.text = line_data.get("speaker", "")
		_dialogue_box.text_label.text = _displayed_text
		_dialogue_box.text_label.visible_characters = 0
		_dialogue_box.hide_continue_hint()
		if _dialogue_box.choices_container:
			_dialogue_box.choices_container.visible = false
	_is_active = true
	_is_typing = true
	_type_timer = 0.0

## 显示当前对话行
func _show_current_line() -> void:
	if not _dialogue.has(_current_id):
		_end_dialogue()
		return
	
	var line: DialogueLine = _dialogue[_current_id]
	_displayed_text = line.text
	
	if _dialogue_box:
		_dialogue_box.visible = true
		_dialogue_box.reset_input_state()
		_dialogue_box.speaker_label.text = line.speaker
		_dialogue_box.text_label.text = _displayed_text
		_dialogue_box.text_label.visible_characters = 0
		_dialogue_box.hide_continue_hint()
		
		# 显示选项
		if line.choices.size() > 0:
			_dialogue_box.show_choices(line.choices)
		else:
			if _dialogue_box.choices_container:
				_dialogue_box.choices_container.visible = false
	
	_is_active = true
	_is_typing = true
	_type_timer = 0.0

## 推进对话
func advance() -> void:
	if not _is_active:
		return
	
	# 如果正在打字，直接显示全部
	if _is_typing:
		_is_typing = false
		if _dialogue_box:
			_dialogue_box.text_label.visible_characters = -1
			_dialogue_box.show_continue_hint()
		return
	
	# 如果有选项，不自动推进
	if _dialogue_box and _dialogue_box._has_choices:
		return
	
	# 队列模式
	if _is_queue_mode:
		_show_next_in_queue()
		return
	
	# 普通模式，跳转到下一段
	if _dialogue.has(_current_id):
		var line: DialogueLine = _dialogue[_current_id]
		if not line.event.is_empty():
			event_triggered.emit(line.event)
		if not line.next_id.is_empty():
			_current_id = line.next_id
			_show_current_line()
		else:
			_end_dialogue()
	else:
		_end_dialogue()

## 结束对话
func _end_dialogue() -> void:
	_is_active = false
	_is_typing = false
	_is_queue_mode = false
	if _dialogue_box:
		_dialogue_box.visible = false
		_dialogue_box.reset_input_state()
	dialogue_finished.emit()

## 从JSON文件加载对话
func load_dialogue_from_file(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		push_error("对话文件不存在: " + file_path)
		return {}
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return {}
	
	var json_text := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	if json.parse(json_text) != OK:
		push_error("对话文件解析失败: " + file_path)
		return {}
	
	return load_dialogue_from_dict(json.data)

## 从字典数据构建对话
func load_dialogue_from_dict(data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for id in data.keys():
		var line_data: Dictionary = data[id]
		var line := DialogueLine.new()
		line.speaker = line_data.get("speaker", "")
		line.text = line_data.get("text", "")
		line.portrait = line_data.get("portrait", "")
		line.emotion = line_data.get("emotion", "normal")
		line.choices = line_data.get("choices", [])
		line.next_id = line_data.get("next_id", "")
		line.event = line_data.get("event", "")
		result[id] = line
	return result
