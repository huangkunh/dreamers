extends Node
## 对话管理器 (DialogueManager)
## 管理NPC对话、剧情对话的显示和推进
## 作为 Autoload 单例运行

## 对话数据结构
class DialogueLine:
        var speaker: String = ""       ## 说话者名字
        var text: String = ""           ## 对话文本
        var portrait: String = ""       ## 头像路径 (可选)
        var emotion: String = "normal"  ## 表情
        var choices: Array = []         ## 选项 (可选, 空则无选项)
        var next_id: String = ""        ## 下一句对话ID (空则结束)
        var event: String = ""          ## 触发的事件名 (可选)

## 对话框节点引用
var _dialogue_box: Control = null
## 当前对话数据
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
## 打字机字符索引
var _type_index: int = 0

## 信号
signal dialogue_started
signal dialogue_finished
signal choice_made(choice_index: int)

func _ready() -> void:
        pass

func _process(delta: float) -> void:
        if _is_typing and _is_active:
                _update_typewriter(delta)

## 设置对话框节点引用
func set_dialogue_box(box: Control) -> void:
        _dialogue_box = box

## 开始对话
func start_dialogue(dialogue_data: Dictionary, start_id: String = "start") -> void:
        if _is_active:
                return
        if not _dialogue_box:
                push_error("DialogueManager: 对话框未设置!")
                return
        _dialogue = dialogue_data
        _current_id = start_id
        _is_active = true
        dialogue_started.emit()
        _show_line(_current_id)

## 显示指定ID的对话行
func _show_line(line_id: String) -> void:
        if not _dialogue.has(line_id):
                _end_dialogue()
                return
        _current_id = line_id
        var line = _dialogue[line_id]
        _dialogue_box.set_speaker(line.speaker)
        _dialogue_box.set_text("")
        _dialogue_box.set_choices(line.choices)
        _dialogue_box.visible = true
        _displayed_text = line.text
        _is_typing = true
        _type_index = 0
        _type_timer = 0.0

## 更新打字机效果
func _update_typewriter(delta: float) -> void:
        _type_timer += delta
        while _type_timer >= 1.0 / _type_speed and _type_index < _displayed_text.length():
                _type_index += 1
                _type_timer -= 1.0 / _type_speed
                _dialogue_box.set_text(_displayed_text.substr(0, _type_index))
        if _type_index >= _displayed_text.length():
                _is_typing = false

## 处理对话推进输入
func handle_input(event: InputEvent) -> void:
        if not _is_active:
                return
        if event.is_action_pressed("ui_accept"):
                advance()

## 推进对话 (供外部调用)
func advance() -> void:
        if not _is_active:
                return
        if _is_typing:
                # 跳过打字机效果
                _is_typing = false
                _type_index = _displayed_text.length()
                _dialogue_box.set_text(_displayed_text)
        else:
                var line = _dialogue.get(_current_id, null)
                if line and line.choices.size() > 0:
                        return
                if line and line.event != "":
                        print("[DialogueManager] 触发事件: ", line.event)
                if line and line.next_id != "":
                        _show_line(line.next_id)
                else:
                        _end_dialogue()

## 选择选项
func select_choice(index: int) -> void:
        if not _is_active:
                return
        var line = _dialogue.get(_current_id, null)
        if not line or index < 0 or index >= line.choices.size():
                return
        choice_made.emit(index)
        var choice = line.choices[index]
        if choice.has("next_id") and choice.next_id != "":
                _show_line(choice.next_id)
        else:
                _end_dialogue()

## 结束对话
func _end_dialogue() -> void:
        _is_active = false
        _is_typing = false
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
