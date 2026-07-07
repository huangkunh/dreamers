extends Label3D
## 伤害数字弹出 (DamagePopup)
## 在 3D 空间中显示伤害/治疗数字，带浮动动画

## 数字类型
enum PopupType {
	DAMAGE,    ## 伤害 (红色)
	CRITICAL,  ## 暴击 (黄色，更大)
	HEAL,      ## 治疗 (绿色)
	MISS,      ## 未命中 (灰色)
}

@export var popup_type: PopupType = PopupType.DAMAGE

## 浮动距离
var _float_distance: float = 2.0
## 动画持续时间
var _duration: float = 1.0
## 起始位置
var _start_pos: Vector3

func _ready() -> void:
	# 根据类型设置样式
	match popup_type:
		PopupType.DAMAGE:
			modulate = Color(1, 0.3, 0.2)
			font_size = 48
		PopupType.CRITICAL:
			modulate = Color(1, 0.85, 0.1)
			font_size = 64
		PopupType.HEAL:
			modulate = Color(0.3, 1, 0.4)
			font_size = 48
		PopupType.MISS:
			modulate = Color(0.7, 0.7, 0.7)
			font_size = 36
			text = "MISS"

	# 设置标签属性
	outline_modulate = Color.BLACK
	outline_size = 8
	billboard = BaseMaterial3D.BILLBOARD_ENABLED
	no_depth_test = true
	shaded = false

	_start_pos = position

	# 播放浮动动画
	_play_animation()

## 播放浮动+淡出动画
func _play_animation() -> void:
	var tw := create_tween()
	# 向上浮动
	tw.tween_property(self, "position:y", _start_pos.y + _float_distance, _duration * 0.6)
	tw.parallel().tween_property(self, "modulate:a", 1.0, 0.1)
	# 短暂停留
	tw.tween_interval(0.2)
	# 淡出并继续上浮
	tw.tween_property(self, "position:y", _start_pos.y + _float_distance * 1.5, _duration * 0.4)
	tw.parallel().tween_property(self, "modulate:a", 0.0, _duration * 0.4)
	# 删除自己
	tw.tween_callback(queue_free)

## 显示伤害数字
static func show_damage(parent: Node, pos: Vector3, amount: int, is_critical: bool = false) -> void:
	var popup := Label3D.new()
	popup.set_script(load("res://script/ui/damage_popup.gd"))
	popup.popup_type = PopupType.CRITICAL if is_critical else PopupType.DAMAGE
	popup.position = pos
	popup.text = str(amount)
	parent.add_child(popup)

## 显示治疗数字
static func show_heal(parent: Node, pos: Vector3, amount: int) -> void:
	var popup := Label3D.new()
	popup.set_script(load("res://script/ui/damage_popup.gd"))
	popup.popup_type = PopupType.HEAL
	popup.position = pos
	popup.text = "+" + str(amount)
	parent.add_child(popup)

## 显示未命中
static func show_miss(parent: Node, pos: Vector3) -> void:
	var popup := Label3D.new()
	popup.set_script(load("res://script/ui/damage_popup.gd"))
	popup.popup_type = PopupType.MISS
	popup.position = pos
	parent.add_child(popup)
