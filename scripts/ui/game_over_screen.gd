extends Control
## 游戏结束画面 (GameOverScreen)
## 玩家全员阵亡时显示
## 提供读档/返回标题选项

@onready var title_label: Label = $Panel/TitleLabel
@onready var subtitle_label: Label = $Panel/SubtitleLabel
@onready var load_button: Button = $Panel/VBoxContainer/LoadButton
@onready var title_button: Button = $Panel/VBoxContainer/TitleButton
@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
        visible = false
        process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        load_button.pressed.connect(_on_load)
        title_button.pressed.connect(_on_title)

        # 设置粒子效果 (灰烬飘落)
        particles.amount = 40
        particles.lifetime = 5.0
        particles.direction = Vector2(0, 1)
        particles.spread = 30
        particles.initial_velocity_min = 10.0
        particles.initial_velocity_max = 30.0
        particles.gravity = Vector2(0, 5)
        particles.color = Color(0.3, 0.2, 0.15, 0.6)
        particles.scale_amount_min = 2.0
        particles.scale_amount_max = 5.0

## 显示游戏结束画面
func show_game_over() -> void:
        visible = true
        get_tree().paused = true

        # 入场动画
        title_label.modulate.a = 0.0
        subtitle_label.modulate.a = 0.0
        load_button.modulate.a = 0.0
        title_button.modulate.a = 0.0

        var tw := create_tween()
        tw.tween_property(title_label, "modulate:a", 1.0, 1.0)
        tw.tween_property(subtitle_label, "modulate:a", 1.0, 0.5)
        tw.tween_property(load_button, "modulate:a", 1.0, 0.3)
        tw.tween_property(title_button, "modulate:a", 1.0, 0.3)

        # 检查是否有存档
        if not SaveSystem.has_save_data():
                load_button.disabled = true

## 读档
func _on_load() -> void:
        get_tree().paused = false
        visible = false
        if SaveSystem.has_save_data():
                SaveSystem.load_game()

## 返回标题
func _on_title() -> void:
        get_tree().paused = false
        visible = false
        GameFlow.return_to_title()

func _input(event: InputEvent) -> void:
        if not visible:
                return
        if event.is_action_pressed("ui_accept"):
                if not load_button.disabled:
                        _on_load()
        elif event.is_action_pressed("ui_cancel"):
                _on_title()
