extends Control
## 战斗掉落物品显示 (BattleDropDisplay)
## 战斗胜利后显示获得的物品列表

@onready var title_label: Label = $Panel/TitleLabel
@onready var item_container: VBoxContainer = $Panel/ScrollContainer/ItemContainer
@onready var continue_button: Button = $Panel/ContinueButton

func _ready() -> void:
        visible = false
        continue_button.pressed.connect(_on_continue)

## 显示掉落物品
## drops: 掉落物品数组 [{id, name, type, count}]
func show_drops(drops: Array) -> void:
        # 清除旧内容
        for child in item_container.get_children():
                child.queue_free()

        if drops.is_empty():
                var empty_label := Label.new()
                empty_label.text = "没有获得物品"
                empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
                empty_label.add_theme_font_size_override("font_size", 16)
                empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                item_container.add_child(empty_label)
        else:
                for drop in drops:
                        var row := HBoxContainer.new()
                        row.add_theme_constant_override("separation", 10)

                        # 物品图标 (用文字代替)
                        var icon_label := Label.new()
                        match drop.type:
                                0: icon_label.text = "🧪"  # 消耗品
                                1: icon_label.text = "⚔"  # 武器
                                2: icon_label.text = "🛡"  # 防具
                                3: icon_label.text = "💍"  # 饰品
                                4: icon_label.text = "📦"  # 材料
                                _: icon_label.text = "❓"
                        icon_label.custom_minimum_size = Vector2(30, 0)
                        icon_label.add_theme_font_size_override("font_size", 18)
                        row.add_child(icon_label)

                        # 物品名称
                        var name_label := Label.new()
                        name_label.text = drop.name
                        name_label.custom_minimum_size = Vector2(200, 0)
                        name_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
                        name_label.add_theme_font_size_override("font_size", 16)
                        row.add_child(name_label)

                        # 数量
                        var count_label := Label.new()
                        count_label.text = "x%d" % drop.count
                        count_label.custom_minimum_size = Vector2(60, 0)
                        count_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
                        count_label.add_theme_font_size_override("font_size", 16)
                        count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
                        row.add_child(count_label)

                        item_container.add_child(row)

        visible = true

        # 入场动画
        modulate.a = 0.0
        var tw := create_tween()
        tw.tween_property(self, "modulate:a", 1.0, 0.3)

## 继续按钮
func _on_continue() -> void:
        visible = false

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_accept"):
                _on_continue()
