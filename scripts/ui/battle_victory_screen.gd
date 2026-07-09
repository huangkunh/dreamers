extends Control
## 战斗胜利画面 (BattleVictoryScreen)
## 战斗胜利后显示获得的经验值/金币/升级信息
## 替代原有的简单结算画面

@onready var title_label: Label = $Panel/TitleLabel
@onready var exp_label: Label = $Panel/InfoContainer/ExpLabel
@onready var coins_label: Label = $Panel/InfoContainer/CoinsLabel
@onready var level_up_container: VBoxContainer = $Panel/LevelUpContainer
@onready var continue_button: Button = $Panel/ContinueButton

## 战斗数据
var _exp_gained: int = 0
var _coins_gained: int = 0
var _level_ups: Array = []

func _ready() -> void:
        visible = false
        continue_button.pressed.connect(_on_continue)

## 显示战斗胜利画面
## exp: 获得经验值
## coins: 获得金币
## level_up_info: 升级信息数组 [{name, old_level, new_level, stat_changes}]
func show_victory(exp: int, coins: int, level_up_info: Array = []) -> void:
        _exp_gained = exp
        _coins_gained = coins
        _level_ups = level_up_info

        # 更新显示
        exp_label.text = "✦ 经验值 +%d" % exp
        coins_label.text = "💰 金币 +%d" % coins

        # 清除旧的升级信息
        for child in level_up_container.get_children():
                child.queue_free()

        # 显示升级信息
        for info in level_up_info:
                var label := Label.new()
                label.text = "⬆ %s 升级! Lv.%d → Lv.%d" % [info.get("name", ""), info.get("old_level", 0), info.get("new_level", 0)]
                label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
                label.add_theme_font_size_override("font_size", 18)
                label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                level_up_container.add_child(label)

        # 如果没有升级，隐藏容器
        level_up_container.visible = level_up_info.size() > 0

        visible = true

        # 入场动画
        modulate.a = 0.0
        var tw := create_tween()
        tw.tween_property(self, "modulate:a", 1.0, 0.3)

        # 标题弹跳动画
        title_label.scale = Vector2(0.5, 0.5)
        var tw2 := create_tween()
        tw2.tween_property(title_label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK)
        tw2.tween_property(title_label, "scale", Vector2(1.0, 1.0), 0.1)

## 继续按钮
func _on_continue() -> void:
        visible = false
        # 返回之前的场景
        GameFlow.change_scene("city")

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_accept"):
                _on_continue()
