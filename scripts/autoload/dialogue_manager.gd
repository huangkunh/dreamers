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
                var chars_to_show := int(_type_timer * _type_speed)
                if chars_to_show >= _displayed_text.length():
                        _displayed_text = _displayed_text  # 已经全部显示
                        _is_typing = false
                        _dialogue_box.text_label.visible_characters = -1
                        _dialogue_box.continue_hint.visible = true
                else:
                        _dialogue_box.text_label.visible_characters = chars_to_show

## 设置对话框引用
func set_dialogue_box(box: Control) -> void:
        _dialogue_box = box

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
        var line_data = _dialogue_queue.pop_front()
        _displayed_text = line_data.get("text", "")
        if _dialogue_box:
                _dialogue_box.visible = true
                _dialogue_box.speaker_label.text = line_data.get("speaker", "")
                _dialogue_box.text_label.text = _displayed_text
                _dialogue_box.text_label.visible_characters = 0
                _dialogue_box.continue_hint.visible = false
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
        var line = _dialogue[_current_id]
        _displayed_text = line.text
        if _dialogue_box:
                _dialogue_box.visible = true
                _dialogue_box.speaker_label.text = line.speaker
                _dialogue_box.text_label.text = line.text
                _dialogue_box.text_label.visible_characters = 0
                _dialogue_box.continue_hint.visible = false
                # 隐藏选项
                if _dialogue_box.choices_container:
                        _dialogue_box.choices_container.visible = false
        _is_active = true
        _is_typing = true
        _type_timer = 0.0

## 推进对话 (玩家按确认键时调用)
func advance() -> void:
        if not _is_active:
                return
        # 如果正在打字，直接显示全文
        if _is_typing:
                _is_typing = false
                if _dialogue_box:
                        _dialogue_box.text_label.visible_characters = -1
                        _dialogue_box.continue_hint.visible = true
                # 如果有选项，立即显示
                var cur_line = _dialogue.get(_current_id, null)
                if cur_line and cur_line.choices.size() > 0:
                        _dialogue_box.show_choices(cur_line.choices)
                        _dialogue_box.continue_hint.visible = false
                return

        if _is_queue_mode:
                _show_next_in_queue()
                return

        # 检查是否有选项
        var line = _dialogue.get(_current_id, null)
        if line and line.choices.size() > 0:
                # 已经显示选项，等待选择
                return

        # 触发事件
        if line and not line.event.is_empty():
                event_triggered.emit(line.event)

        # 前进到下一句
        if line and not line.next_id.is_empty():
                _current_id = line.next_id
                _show_current_line()
        else:
                _end_dialogue()

## 结束对话
func _end_dialogue() -> void:
        _is_active = false
        _is_typing = false
        _is_queue_mode = false
        if _dialogue_box:
                _dialogue_box.visible = false
        dialogue_finished.emit()

## 是否正在对话
func is_active() -> bool:
        return _is_active

## 从字典加载对话数据
func load_dialogue_from_dict(data: Dictionary) -> Dictionary:
        var result := {}
        for key in data.keys():
                var line_data = data[key]
                var line := DialogueLine.new()
                line.speaker = line_data.get("speaker", "")
                line.text = line_data.get("text", "")
                line.portrait = line_data.get("portrait", "")
                line.emotion = line_data.get("emotion", "normal")
                line.choices = line_data.get("choices", [])
                line.next_id = line_data.get("next_id", "")
                line.event = line_data.get("event", "")
                result[key] = line
        return result

## 从JSON文件加载对话
func load_dialogue_from_file(path: String) -> Dictionary:
        if not FileAccess.file_exists(path):
                push_error("[DialogueManager] 对话文件不存在: " + path)
                return {}
        var file = FileAccess.open(path, FileAccess.READ)
        if file == null:
                push_error("[DialogueManager] 无法读取: " + path)
                return {}
        var json_text = file.get_as_text()
        file.close()
        var json = JSON.new()
        if json.parse(json_text) != OK:
                push_error("[DialogueManager] JSON解析失败: " + path)
                return {}
        return load_dialogue_from_dict(json.data)
