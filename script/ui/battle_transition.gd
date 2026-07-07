extends Control
## 战斗过渡效果 (BattleTransition)
## HD-2D 风格的战斗进入/退出过渡动画
## 参考: 八方旅人的屏幕闪烁 + 缩放效果

signal transition_in_complete
signal transition_out_complete

@onready var flash_rect: ColorRect = $FlashRect
@onready var wipe_rect: ColorRect = $WipeRect
@onready var label: Label = $Label

## 播放进入战斗的过渡
func play_transition_in() -> void:
	# 1. 白色闪光
	flash_rect.color = Color.WHITE
	flash_rect.modulate.a = 0.0
	var tw1 := create_tween()
	tw1.tween_property(flash_rect, "modulate:a", 1.0, 0.15)
	tw1.tween_property(flash_rect, "modulate:a", 0.0, 0.3)

	# 2. 黑色遮罩从两侧合拢
	wipe_rect.color = Color.BLACK
	wipe_rect.modulate.a = 0.0
	var tw2 := create_tween()
	tw2.tween_interval(0.15)
	tw2.tween_property(wipe_rect, "modulate:a", 1.0, 0.2)

	# 3. 显示"战斗!"文字
	label.text = "⚔ 战 斗 ⚔"
	label.modulate.a = 0.0
	label.scale = Vector2(0.5, 0.5)
	var tw3 := create_tween()
	tw3.tween_interval(0.4)
	tw3.tween_property(label, "modulate:a", 1.0, 0.2)
	tw3.parallel().tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tw3.tween_interval(0.3)
	tw3.tween_property(label, "modulate:a", 0.0, 0.2)
	tw3.parallel().tween_property(label, "scale", Vector2(2.0, 2.0), 0.2)

	# 4. 黑色遮罩淡出
	var tw4 := create_tween()
	tw4.tween_interval(1.0)
	tw4.tween_property(wipe_rect, "modulate:a", 0.0, 0.3)
	tw4.tween_callback(func(): transition_in_complete.emit())

## 播放退出战斗的过渡
func play_transition_out() -> void:
	wipe_rect.color = Color.BLACK
	wipe_rect.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(wipe_rect, "modulate:a", 1.0, 0.3)
	tw.tween_interval(0.2)
	tw.tween_property(wipe_rect, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func(): transition_out_complete.emit())
