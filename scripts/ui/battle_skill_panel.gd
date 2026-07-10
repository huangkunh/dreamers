extends Control
## 战斗技能选择面板 (BattleSkillPanel)
## 战斗中玩家回合时弹出，可选择技能
## 替代原有的固定菜单，支持动态技能列表

signal skill_selected(skill_id: String)
signal panel_cancelled

@onready var title_label: Label = $Panel/TitleLabel
@onready var skill_list: VBoxContainer = $Panel/ScrollContainer/SkillList
@onready var desc_label: RichTextLabel = $Panel/DescLabel
@onready var mp_label: Label = $Panel/MPLabel

## 当前可用技能列表
var _available_skills: Array = []
## 技能按钮列表
var _skill_buttons: Array[Button] = []
## 当前选中索引
var _current_index: int = 0
## 当前角色MP
var _current_mp: int = 999

func _ready() -> void:
	visible = false

## 显示技能面板
## skills: 可用技能ID列表
## mp: 当前MP
func show_panel(skills: Array, mp: int = 999) -> void:
	_available_skills = skills
	_current_mp = mp
	_refresh_skill_list()
	visible = true
	_current_index = 0
	_update_selection()

## 隐藏面板
func hide_panel() -> void:
	visible = false

## 刷新技能列表
func _refresh_skill_list() -> void:
	# 清除旧按钮
	for child in skill_list.get_children():
		child.queue_free()
	_skill_buttons.clear()

	# 创建技能按钮
	for skill_id in _available_skills:
		var skill = SkillData.get_skill(skill_id)
		if not skill:
			continue

		var btn := Button.new()
		var mp_text := " (MP:%d)" % skill.mp_cost if skill.mp_cost > 0 else ""
		btn.text = skill.name + mp_text
		btn.custom_minimum_size = Vector2(280, 36)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		btn.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.3))
		btn.focus_mode = Control.FOCUS_NONE

		# MP不足时禁用
		if skill.mp_cost > _current_mp:
			btn.disabled = true
			btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))

		_skill_buttons.append(btn)
		skill_list.add_child(btn)

	_update_mp_display()

## 更新MP显示
func _update_mp_display() -> void:
	mp_label.text = "MP: %d" % _current_mp

func _process(_delta: float) -> void:
	if not visible:
		return

	# 键盘导航
	if Input.is_action_just_pressed("move_up"):
		_navigate(-1)
	elif Input.is_action_just_pressed("move_down"):
		_navigate(1)
	elif Input.is_action_just_pressed("ui_accept"):
		_confirm()
	elif Input.is_action_just_pressed("ui_cancel"):
		_cancel()

## 导航
func _navigate(direction: int) -> void:
	# 跳过禁用的按钮
	var size = _skill_buttons.size()
	for i in range(size):
		_current_index = wrapi(_current_index + direction, 0, size)
		if not _skill_buttons[_current_index].disabled:
			break
	_update_selection()

## 更新选择高亮
func _update_selection() -> void:
	for i in range(_skill_buttons.size()):
		var btn = _skill_buttons[i]
		if i == _current_index:
			btn.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		else:
			if not btn.disabled:
				btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))

	# 更新描述
	if _current_index < _available_skills.size():
		var skill = SkillData.get_skill(_available_skills[_current_index])
		if skill:
			desc_label.text = "[color=#ffcc44]%s[/color]\n%s" % [skill.name, skill.description]

## 确认选择
func _confirm() -> void:
	if _current_index < _available_skills.size():
		var skill_id = _available_skills[_current_index]
		var skill = SkillData.get_skill(skill_id)
		if skill and skill.mp_cost <= _current_mp:
			skill_selected.emit(skill_id)
			hide_panel()

## 取消
func _cancel() -> void:
	panel_cancelled.emit()
	hide_panel()
