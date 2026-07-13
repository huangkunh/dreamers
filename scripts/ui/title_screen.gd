extends Control
## 标题画面 (TitleScreen)
## HD-2D 风格的标题画面，带有渐变背景、粒子效果和菜单

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var menu_container: VBoxContainer = $VBoxContainer/MenuContainer
@onready var new_game_btn: Button = $VBoxContainer/MenuContainer/NewGameButton
@onready var continue_btn: Button = $VBoxContainer/MenuContainer/ContinueButton
@onready var options_btn: Button = $VBoxContainer/MenuContainer/OptionsButton
@onready var help_btn: Button = $VBoxContainer/MenuContainer/HelpButton
@onready var exit_btn: Button = $VBoxContainer/MenuContainer/ExitButton
@onready var version_label: Label = $VersionLabel
@onready var bg_color_rect: ColorRect = $BackgroundColorRect
@onready var particles: CPUParticles2D = $CPUParticles2D

## 菜单按钮索引
var _menu_index: int = 0
var _menu_buttons: Array[Button] = []
## 是否正在处理操作
var _is_processing: bool = false
## 按钮功能映射
var _button_actions: Dictionary = {}

func _ready() -> void:
	# 设置版本号
	version_label.text = "v0.10"
	_is_processing = false

	# 收集菜单按钮
	_menu_buttons = [new_game_btn, continue_btn, options_btn, help_btn, exit_btn]

	# 检查存档
	if SaveSystem and SaveSystem.has_save_data():
		continue_btn.disabled = false
	else:
		continue_btn.disabled = true

	# 设置按钮功能映射
	_button_actions = {
		0: _on_new_game,
		1: _on_continue,
		2: _on_options,
		3: _on_help,
		4: _on_exit
	}

	# 连接按钮信号 (使用call_deferred确保节点已准备好)
	_call_deferred_connect_buttons()

	# 初始高亮第一个按钮
	_update_menu_highlight()

	# 设置粒子效果 - 模拟废土中的沙尘
	particles.amount = 60
	particles.lifetime = 4.0
	particles.direction = Vector2(1, 0.2)
	particles.spread = 15
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 60.0
	particles.gravity = Vector2(0, 5)
	particles.color = Color(0.7, 0.6, 0.4, 0.3)

	# 标题动画 - 缓慢呼吸效果
	var tw := create_tween()
	tw.set_loops()
	tw.tween_property(title_label, "modulate:a", 0.85, 2.0)
	tw.tween_property(title_label, "modulate:a", 1.0, 2.0)

	# 入场动画
	_play_entrance_animation()

## 延迟连接按钮信号
func _call_deferred_connect_buttons() -> void:
	new_game_btn.pressed.connect(_on_new_game)
	continue_btn.pressed.connect(_on_continue)
	options_btn.pressed.connect(_on_options)
	help_btn.pressed.connect(_on_help)
	exit_btn.pressed.connect(_on_exit)

func _play_entrance_animation() -> void:
	# 初始隐藏所有元素
	title_label.modulate.a = 0.0
	subtitle_label.modulate.a = 0.0
	for btn in _menu_buttons:
		btn.modulate.a = 0.0

	# 标题淡入
	var tw := create_tween()
	tw.tween_property(title_label, "modulate:a", 1.0, 1.5)
	tw.tween_property(subtitle_label, "modulate:a", 1.0, 1.0)
	# 菜单逐个淡入
	for btn in _menu_buttons:
		tw.tween_property(btn, "modulate:a", 1.0, 0.3)

func _input(event: InputEvent) -> void:
	if _is_processing:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP, KEY_W:
				_menu_index = (_menu_index - 1 + _menu_buttons.size()) % _menu_buttons.size()
				_update_menu_highlight()
				get_viewport().set_input_as_handled()
			KEY_DOWN, KEY_S:
				_menu_index = (_menu_index + 1) % _menu_buttons.size()
				_update_menu_highlight()
				get_viewport().set_input_as_handled()
			KEY_ENTER, KEY_SPACE:
				_activate_current_button()
				get_viewport().set_input_as_handled()
			KEY_ESCAPE:
				_on_exit()
				get_viewport().set_input_as_handled()

## 激活当前选中的按钮
func _activate_current_button() -> void:
	if _menu_index < 0 or _menu_index >= _menu_buttons.size():
		return
	
	var btn: Button = _menu_buttons[_menu_index]
	if btn.disabled:
		return
	
	# 直接调用对应的功能函数
	if _button_actions.has(_menu_index):
		var action: Callable = _button_actions[_menu_index]
		action.call()

func _update_menu_highlight() -> void:
	for i in range(_menu_buttons.size()):
		var btn: Button = _menu_buttons[i]
		if i == _menu_index:
			btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
			btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))
			btn.grab_focus()
		else:
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_color_override("font_hover_color")

func _on_new_game() -> void:
	if _is_processing:
		return
	_is_processing = true
	print("[TitleScreen] 开始新游戏")
	GameManager.start_new_game()
	GameData.game_flags["play_opening"] = true
	# 新游戏直接进入奥多市 (触发开场剧情演出)
	GameFlow.current_state = GameFlow.GameState.CITY
	GameFlow.change_scene("city")

func _on_continue() -> void:
	if _is_processing:
		return
	_is_processing = true
	
	if SaveSystem and SaveSystem.has_save_data():
		print("[TitleScreen] 加载存档")
		GameManager.init_game_data()
		SaveSystem.load_game()
		GameFlow.current_state = GameFlow.GameState.WORLD_MAP
		GameFlow.change_scene("world_map")
	else:
		print("[TitleScreen] 无存档可加载")
		_is_processing = false

func _on_options() -> void:
	if _is_processing:
		return
	_is_processing = true
	print("[TitleScreen] 打开选项设置")
	
	var options_scene := load("res://scenes/ui/options_screen.tscn")
	if options_scene:
		var options: Control = options_scene.instantiate()
		add_child(options)
		options.open()
	else:
		push_error("[TitleScreen] 无法加载选项界面")
	
	_is_processing = false

func _on_help() -> void:
	if _is_processing:
		return
	_is_processing = true
	print("[TitleScreen] 打开帮助说明")
	
	var help_scene := load("res://scenes/ui/help_screen.tscn")
	if help_scene:
		var help: Control = help_scene.instantiate()
		add_child(help)
		help.open()
	else:
		push_error("[TitleScreen] 无法加载帮助界面")
	
	_is_processing = false

func _on_exit() -> void:
	if _is_processing:
		return
	_is_processing = true
	print("[TitleScreen] 退出游戏")
	get_tree().quit()
