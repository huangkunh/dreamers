extends CanvasLayer
## 场景淡入淡出过渡 (SceneFadeTransition)
## 提供场景切换时的淡入淡出效果
## 作为 Autoload 单例运行

@onready var _color_rect: ColorRect = $FadeRect

func _ready() -> void:
	# 初始完全透明
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# 始终处理，即使游戏暂停
	process_mode = Node.PROCESS_MODE_ALWAYS
	# 默认隐藏
	visible = false

## 淡入（屏幕变黑）
## duration: 淡入时长（秒）
## on_complete: 淡入完成回调
func fade_in(duration: float = 0.5, on_complete: Callable = Callable()) -> void:
	visible = true
	_color_rect.color = Color(0, 0, 0, 0)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 1.0, duration)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

## 淡出（屏幕变亮）
## duration: 淡出时长（秒）
## on_complete: 淡出完成回调
func fade_out(duration: float = 0.5, on_complete: Callable = Callable()) -> void:
	_color_rect.color = Color(0, 0, 0, 1.0)
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween := create_tween()
	tween.tween_property(_color_rect, "color:a", 0.0, duration)
	tween.tween_callback(func():
		visible = false
		_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
	if on_complete.is_valid():
		tween.tween_callback(on_complete)

## 切换场景（淡入→切换→淡出）
## scene_path: 场景文件路径
## fade_duration: 淡入淡出时长（秒）
func transition_to_scene(scene_path: String, fade_duration: float = 0.5) -> void:
	fade_in(fade_duration, func():
		# 场景切换
		var err := get_tree().change_scene_to_file(scene_path)
		if err != OK:
			push_error("[SceneFadeTransition] 场景切换失败: " + scene_path)
		# 短暂延迟后开始淡出
		get_tree().create_timer(0.1).timeout.connect(func():
			fade_out(fade_duration)
		)
	)

## 立即设置透明度（无动画）
func set_alpha(alpha: float) -> void:
	if alpha >= 0.01:
		visible = true
	_color_rect.color.a = alpha
	if alpha <= 0.01:
		visible = false

## 是否正在淡入淡出中
func is_transitioning() -> bool:
	return _color_rect.color.a > 0.01
