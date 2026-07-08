extends Control
## 标题画面 (TitleScreen)
## HD-2D 风格的标题画面，带有渐变背景、粒子效果和菜单

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $VBoxContainer/SubtitleLabel
@onready var menu_container: VBoxContainer = $VBoxContainer/MenuContainer
@onready var new_game_btn: Button = $VBoxContainer/MenuContainer/NewGameButton
@onready var continue_btn: Button = $VBoxContainer/MenuContainer/ContinueButton
@onready var options_btn: Button = $VBoxContainer/MenuContainer/OptionsButton
@onready var exit_btn: Button = $VBoxContainer/MenuContainer/ExitButton
@onready var version_label: Label = $VersionLabel
@onready var bg_color_rect: ColorRect = $BackgroundColorRect
@onready var particles: CPUParticles2D = $CPUParticles2D

## 菜单按钮索引
var _menu_index: int = 0
var _menu_buttons: Array[Button] = []

func _ready() -> void:
        # 设置版本号
        version_label.text = "v0.05 - Phase 5"

        # 收集菜单按钮
        _menu_buttons = [new_game_btn, continue_btn, options_btn, exit_btn]

        # 检查存档
        if SaveSystem and SaveSystem.has_save_data():
                continue_btn.disabled = false
        else:
                continue_btn.disabled = true

        # 连接按钮信号
        new_game_btn.pressed.connect(_on_new_game)
        continue_btn.pressed.connect(_on_continue)
        options_btn.pressed.connect(_on_options)
        exit_btn.pressed.connect(_on_exit)

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
        if event is InputEventKey and event.pressed:
                match event.keycode:
                        KEY_UP, KEY_W:
                                _menu_index = (_menu_index - 1 + _menu_buttons.size()) % _menu_buttons.size()
                                _update_menu_highlight()
                        KEY_DOWN, KEY_S:
                                _menu_index = (_menu_index + 1) % _menu_buttons.size()
                                _update_menu_highlight()
                        KEY_ENTER, KEY_SPACE:
                                _menu_buttons[_menu_index].emit_signal("pressed")
                        KEY_ESCAPE:
                                _on_exit()

func _update_menu_highlight() -> void:
        for i in range(_menu_buttons.size()):
                var btn := _menu_buttons[i]
                if i == _menu_index:
                        btn.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
                        btn.add_theme_color_override("font_hover_color", Color(1.0, 0.85, 0.3))
                        btn.grab_focus()
                else:
                        btn.remove_theme_color_override("font_color")
                        btn.remove_theme_color_override("font_hover_color")

func _on_new_game() -> void:
        print("[TitleScreen] 开始新游戏")
        GameManager.start_new_game()

func _on_continue() -> void:
        if SaveSystem and SaveSystem.has_save_data():
                print("[TitleScreen] 加载存档")
                SaveSystem.load_game()
                GameFlow.current_state = GameFlow.GameState.WORLD_MAP
                GameFlow.change_scene("world_map")
        else:
                print("[TitleScreen] 无存档可加载")

func _on_options() -> void:
        print("[TitleScreen] 选项（暂未实现）")
        # TODO: 选项菜单

func _on_exit() -> void:
        get_tree().quit()
