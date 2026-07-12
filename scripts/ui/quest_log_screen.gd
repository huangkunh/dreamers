extends Control
## 任务日志界面 (QuestLogScreen)
## 显示当前任务和已完成任务

@onready var active_container: VBoxContainer = $Panel/ScrollContainer/VBoxContainer/ActiveContainer
@onready var completed_container: VBoxContainer = $Panel/ScrollContainer/VBoxContainer/CompletedContainer
@onready var active_title: Label = $Panel/ScrollContainer/VBoxContainer/ActiveContainer/ActiveTitle
@onready var completed_title: Label = $Panel/ScrollContainer/VBoxContainer/CompletedContainer/CompletedTitle
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
        visible = false
        close_button.pressed.connect(close)

## 打开任务日志
func open() -> void:
        _refresh_quests()
        visible = true

## 刷新任务列表
func _refresh_quests() -> void:
        # 清除旧内容 (保留标题)
        for i in range(active_container.get_child_count() - 1, 0, -1):
                active_container.get_child(i).queue_free()
        for i in range(completed_container.get_child_count() - 1, 0, -1):
                completed_container.get_child(i).queue_free()

        # 显示进行中任务
        var active_quests = QuestSystem.get_active_quests()
        if active_quests.is_empty():
                var empty_label := Label.new()
                empty_label.text = "暂无进行中的任务"
                empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
                empty_label.add_theme_font_size_override("font_size", 15)
                active_container.add_child(empty_label)
        else:
                for quest in active_quests:
                        var quest_item := _create_quest_item(quest)
                        active_container.add_child(quest_item)

        # 显示已完成未领奖任务
        var completed_quests = QuestSystem.get_completed_quests()
        if completed_quests.is_empty():
                var empty_label := Label.new()
                empty_label.text = "暂无已完成任务"
                empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
                empty_label.add_theme_font_size_override("font_size", 15)
                completed_container.add_child(empty_label)
        else:
                for quest in completed_quests:
                        var quest_item := _create_quest_item(quest, true)
                        completed_container.add_child(quest_item)

## 创建任务条目
func _create_quest_item(quest, is_completed: bool = false) -> Control:
        var panel := Panel.new()
        panel.custom_minimum_size = Vector2(0, 80)

        var vbox := VBoxContainer.new()
        vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
        vbox.offset_left = 10
        vbox.offset_top = 5
        vbox.offset_right = -10
        vbox.offset_bottom = -5
        panel.add_child(vbox)

        # 任务标题
        var title_label := Label.new()
        var status_text := " ✓ 可领奖" if is_completed else ""
        title_label.text = quest.title + status_text
        title_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3) if is_completed else Color(0.9, 0.85, 0.7))
        title_label.add_theme_font_size_override("font_size", 17)
        vbox.add_child(title_label)

        # 任务描述
        var desc_label := Label.new()
        desc_label.text = quest.description
        desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
        desc_label.add_theme_font_size_override("font_size", 14)
        desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        vbox.add_child(desc_label)

        # 任务进度
        var progress_label := Label.new()
        var progress_text := ""
        for obj in quest.objectives:
                progress_text += "%d/%d  " % [obj.current, obj.count]
        progress_label.text = "进度: " + progress_text
        progress_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1))
        progress_label.add_theme_font_size_override("font_size", 14)
        vbox.add_child(progress_label)

        # 奖励信息
        var reward_label := Label.new()
        var reward_text := "奖励: "
        if quest.rewards.has("coins"):
                reward_text += "%dG " % quest.rewards["coins"]
        if quest.rewards.has("exp"):
                reward_text += "+%dEXP" % quest.rewards["exp"]
        reward_label.text = reward_text
        reward_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
        reward_label.add_theme_font_size_override("font_size", 13)
        vbox.add_child(reward_label)

        return panel

## 关闭
func close() -> void:
        visible = false
        queue_free()

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close()
