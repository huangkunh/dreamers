extends Control
## 通知系统 (NotificationSystem)
## 显示游戏中的各种通知: 区域解锁/任务更新/物品获得等

@onready var notification_container: VBoxContainer = $NotificationContainer

## 通知类型配置
const NOTIFICATION_STYLES := {
	"info": {"color": Color(0.7, 0.85, 1), "icon": "ℹ", "duration": 3.0},
	"success": {"color": Color(0.5, 0.9, 0.5), "icon": "✓", "duration": 3.0},
	"warning": {"color": Color(1, 0.85, 0.3), "icon": "⚠", "duration": 4.0},
	"error": {"color": Color(1, 0.4, 0.4), "icon": "✗", "duration": 4.0},
	"quest": {"color": Color(1, 0.85, 0.3), "icon": "📋", "duration": 4.0},
	"area_unlock": {"color": Color(0.6, 0.9, 1), "icon": "🗺", "duration": 4.0},
	"item": {"color": Color(0.9, 0.8, 0.5), "icon": "📦", "duration": 3.0},
	"level_up": {"color": Color(1, 0.85, 0.3), "icon": "⬆", "duration": 3.0},
}

func _ready() -> void:
	# 连接全局信号
	QuestSystem.quest_started.connect(_on_quest_started)
	QuestSystem.quest_completed.connect(_on_quest_completed)

## 显示通知
## text: 通知文本
## type: 通知类型 (info/success/warning/error/quest/area_unlock/item/level_up)
func show_notification(text: String, type: String = "info") -> void:
	var style = NOTIFICATION_STYLES.get(type, NOTIFICATION_STYLES["info"])

	# 创建通知面板
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(350, 50)
	panel.modulate.a = 0.0

	# 创建标签
	var label := Label.new()
	label.text = style.icon + " " + text
	label.add_theme_color_override("font_color", style.color)
	label.add_theme_font_size_override("font_size", 16)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(label)

	notification_container.add_child(panel)

	# 入场动画
	var tw_in := create_tween()
	tw_in.tween_property(panel, "modulate:a", 1.0, 0.3)
	tw_in.parallel().tween_property(panel, "position:x", 0, 0.3).from(-400)

	# 等待显示时间
	await get_tree().create_timer(style.duration).timeout

	# 退场动画
	var tw_out := create_tween()
	tw_out.tween_property(panel, "modulate:a", 0.0, 0.5)
	tw_out.parallel().tween_property(panel, "position:x", 400, 0.5)
	tw_out.tween_callback(panel.queue_free)

## 任务开始通知
func _on_quest_started(quest_id: String) -> void:
	var quest = QuestSystem.quests.get(quest_id, null)
	if quest:
		show_notification("新任务: " + quest.title, "quest")

## 任务完成通知
func _on_quest_completed(quest_id: String) -> void:
	var quest = QuestSystem.quests.get(quest_id, null)
	if quest:
		show_notification("任务完成: " + quest.title, "success")

## 显示区域解锁通知
func notify_area_unlocked(area_name: String) -> void:
	show_notification("解锁新区域: " + area_name, "area_unlock")

## 显示物品获得通知
func notify_item_obtained(item_name: String, count: int = 1) -> void:
	var text = "获得 " + item_name
	if count > 1:
		text += " x" + str(count)
	show_notification(text, "item")

## 显示升级通知
func notify_level_up(member_name: String, new_level: int) -> void:
	show_notification(member_name + " 升级到 Lv." + str(new_level) + "!", "level_up")

## 显示警告
func notify_warning(text: String) -> void:
	show_notification(text, "warning")

## 显示错误
func notify_error(text: String) -> void:
	show_notification(text, "error")
