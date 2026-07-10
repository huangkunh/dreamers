extends Control
## 战斗日志 (BattleLog)
## 记录战斗中的事件，显示在屏幕侧边
## 支持滚动查看历史记录

@onready var log_container: VBoxContainer = $Panel/ScrollContainer/LogContainer
@onready var toggle_button: Button = $Panel/ToggleButton

## 最大日志条数
const MAX_ENTRIES := 50
## 当前日志条目
var _entries: Array[Label] = []
## 是否展开
var _expanded: bool = false

func _ready() -> void:
	visible = false
	toggle_button.pressed.connect(_toggle)

## 添加日志条目
## text: 日志文本
## color: 文本颜色
func add_entry(text: String, color: Color = Color(0.9, 0.9, 0.9)) -> void:
	var label := Label.new()
	label.text = "› " + text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 13)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(280, 0)
	log_container.add_child(label)
	_entries.append(label)

	# 限制最大条数
	if _entries.size() > MAX_ENTRIES:
		var old = _entries.pop_front()
		if is_instance_valid(old):
			old.queue_free()

	# 滚动到底部
	await get_tree().process_frame
	var scroll = $Panel/ScrollContainer
	scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value

## 切换展开/折叠
func _toggle() -> void:
	_expanded = not _expanded
	$Panel/ScrollContainer.visible = _expanded
	if _expanded:
		toggle_button.text = "▼"
		custom_minimum_size = Vector2(320, 200)
	else:
		toggle_button.text = "▲"
		custom_minimum_size = Vector2(40, 30)

## 清除日志
func clear() -> void:
	for entry in _entries:
		if is_instance_valid(entry):
			entry.queue_free()
	_entries.clear()

## 记录战斗开始
func log_battle_start(enemy_count: int) -> void:
	add_entry("战斗开始! 敌人 x" + str(enemy_count), Color(1, 0.85, 0.3))

## 记录攻击
func log_attack(attacker: String, target: String, damage: int, skill_name: String = "普通攻击") -> void:
	add_entry("%s 使用 %s 攻击 %s (%d伤害)" % [attacker, skill_name, target, damage], Color(0.9, 0.7, 0.5))

## 记录治疗
func log_heal(target: String, amount: int) -> void:
	add_entry("%s 恢复 %d HP" % [target, amount], Color(0.5, 0.9, 0.5))

## 记录状态效果
func log_status(target: String, status_name: String, duration: int) -> void:
	add_entry("%s 进入%s状态 (%d回合)" % [target, status_name, duration], Color(0.7, 0.7, 0.9))

## 记录击败
func log_defeat(target: String) -> void:
	add_entry("%s 被击败!" % target, Color(0.9, 0.3, 0.3))

## 记录战斗结束
func log_battle_end(victory: bool) -> void:
	if victory:
		add_entry("战斗胜利!", Color(1, 0.85, 0.3))
	else:
		add_entry("战斗失败...", Color(0.9, 0.3, 0.3))

## 记录等级提升
func log_level_up(member: String, new_level: int) -> void:
	add_entry("%s 升级到 Lv.%d!" % [member, new_level], Color(1, 0.85, 0.3))

## 记录物品获得
func log_item_drop(item_name: String, count: int = 1) -> void:
	add_entry("获得 %s x%d" % [item_name, count], Color(0.9, 0.8, 0.5))
