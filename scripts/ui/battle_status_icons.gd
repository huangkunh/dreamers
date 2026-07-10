extends Control
## 战斗状态图标显示 (BattleStatusIcons)
## 在战斗单位头上显示状态效果图标
## 显示: 中毒/麻痹/眩晕/增益/减益等

## 状态图标配置
const STATUS_ICONS := {
	0: {"name": "中毒", "color": Color(0.5, 0.8, 0.3), "symbol": "毒"},
	1: {"name": "麻痹", "color": Color(0.8, 0.8, 0.3), "symbol": "痹"},
	2: {"name": "眩晕", "color": Color(0.9, 0.9, 0.5), "symbol": "晕"},
	3: {"name": "防御提升", "color": Color(0.3, 0.5, 0.9), "symbol": "防"},
	4: {"name": "攻击提升", "color": Color(0.9, 0.4, 0.3), "symbol": "攻"},
	5: {"name": "速度提升", "color": Color(0.3, 0.9, 0.9), "symbol": "速"},
	6: {"name": "流血", "color": Color(0.8, 0.2, 0.2), "symbol": "血"},
}

## 状态图标容器 (3D空间中的Label3D)
var _status_labels: Dictionary = {}  ## unit_id -> Label3D

## 显示单位的状态图标
## unit: 战斗单位
## unit_node: 3D节点 (用于定位)
func show_status_icons(unit: Dictionary, unit_node: Node3D) -> void:
	var unit_id = unit.get("fight_id", unit.get("player_name", ""))
	if unit_id.is_empty():
		return

	var statuses = unit.get("status_effects", [])
	if statuses.is_empty():
		hide_status_icons(unit_id)
		return

	# 创建或获取Label3D
	var label: Label3D = _status_labels.get(unit_id)
	if not label:
		label = Label3D.new()
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.font_size = 24
		label.outline_modulate = Color.BLACK
		label.outline_size = 6
		unit_node.add_child(label)
		label.position = Vector3(0, 1.5, 0)
		_status_labels[unit_id] = label

	# 构建状态文本
	var text := ""
	for status in statuses:
		var icon = STATUS_ICONS.get(status.effect_type, null)
		if icon:
			text += icon.symbol + str(status.duration) + " "

	label.text = text
	label.visible = not text.is_empty()

	# 设置颜色 (使用第一个状态的颜色)
	if statuses.size() > 0:
		var icon = STATUS_ICONS.get(statuses[0].effect_type, null)
		if icon:
			label.modulate = icon.color

## 隐藏单位的状态图标
func hide_status_icons(unit_id: String) -> void:
	var label = _status_labels.get(unit_id)
	if label:
		label.visible = false

## 清除所有状态图标
func clear_all() -> void:
	for label in _status_labels.values():
		if is_instance_valid(label):
			label.queue_free()
	_status_labels.clear()

## 获取状态名称
func get_status_name(effect_type: int) -> String:
	var icon = STATUS_ICONS.get(effect_type, null)
	return icon.name if icon else "未知"

## 获取状态颜色
func get_status_color(effect_type: int) -> Color:
	var icon = STATUS_ICONS.get(effect_type, null)
	return icon.color if icon else Color.WHITE
