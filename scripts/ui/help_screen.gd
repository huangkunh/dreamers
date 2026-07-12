extends Control
## 帮助/教程画面 (HelpScreen)
## 显示游戏操作说明和玩法提示

@onready var back_button: Button = $Panel/BackButton
@onready var tab_container: TabContainer = $Panel/TabContainer

func _ready() -> void:
        visible = false
        back_button.pressed.connect(close)
        _build_controls_tab()
        _build_gameplay_tab()
        _build_tips_tab()

## 构建操作说明标签页
func _build_controls_tab() -> void:
        var tab: VBoxContainer = $Panel/TabContainer/ControlsTab
        # 清除占位内容
        for child in tab.get_children():
                child.queue_free()

        var title := Label.new()
        title.text = "🎮 操作说明"
        title.add_theme_font_size_override("font_size", 22)
        title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
        tab.add_child(title)

        var controls := [
                ["WASD / 方向键", "移动角色 (8方向)"],
                ["Enter / Space", "确认 / 对话推进"],
                ["ESC", "返回 / 取消"],
                ["E", "与NPC交互 / 开宝箱"],
                ["M", "打开暂停菜单"],
                ["T", "上/下战车"],
                ["↑↓", "菜单导航"],
                ["Enter", "确认选择"],
        ]

        for control in controls:
                var row := HBoxContainer.new()
                var key_label := Label.new()
                key_label.text = control[0]
                key_label.custom_minimum_size = Vector2(180, 0)
                key_label.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
                key_label.add_theme_font_size_override("font_size", 16)
                row.add_child(key_label)

                var desc_label := Label.new()
                desc_label.text = control[1]
                desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
                desc_label.add_theme_font_size_override("font_size", 16)
                row.add_child(desc_label)

                tab.add_child(row)

## 构建玩法说明标签页
func _build_gameplay_tab() -> void:
        var tab: VBoxContainer = $Panel/TabContainer/GameplayTab
        for child in tab.get_children():
                child.queue_free()

        var title := Label.new()
        title.text = "⚔ 玩法说明"
        title.add_theme_font_size_override("font_size", 22)
        title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
        tab.add_child(title)

        var sections := [
                ["🗺 探索", "在城镇和迷宫中移动探索，按E键与NPC对话、开宝箱。"],
                ["⚔ 战斗", "战斗采用回合制，根据速度决定行动顺序。选择攻击/技能/道具/防御。"],
                ["💰 赏金首", "击败赏金首可获得高额赏金。去赏金猎人公会领赏。"],
                ["🚗 战车", "按T键上下战车。战车有装甲/燃料/弹药，需在城镇补给。"],
                ["📦 宝箱", "迷宫中有宝箱，包含金币/道具/装备。已开启的宝箱不会重置。"],
                ["💾 存档", "按M键打开菜单，可保存进度。标题画面可读取存档继续游戏。"],
                ["📈 升级", "战斗获得经验值，升级后HP/攻击/防御/速度提升。"],
        ]

        for section in sections:
                var section_label := Label.new()
                section_label.text = section[0]
                section_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
                section_label.add_theme_font_size_override("font_size", 18)
                tab.add_child(section_label)

                var desc_label := Label.new()
                desc_label.text = section[1]
                desc_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
                desc_label.add_theme_font_size_override("font_size", 15)
                desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                desc_label.custom_minimum_size = Vector2(500, 0)
                tab.add_child(desc_label)

                var spacer := Control.new()
                spacer.custom_minimum_size = Vector2(0, 8)
                tab.add_child(spacer)

## 构建提示标签页
func _build_tips_tab() -> void:
        var tab: VBoxContainer = $Panel/TabContainer/TipsTab
        for child in tab.get_children():
                child.queue_free()

        var title := Label.new()
        title.text = "💡 冒险提示"
        title.add_theme_font_size_override("font_size", 22)
        title.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
        tab.add_child(title)

        var tips := [
                "⚠ 等级不够时不要挑战BOSS，先在低级区域练级。",
                "💊 战斗前准备好恢复药品，尤其是打BOSS前。",
                "🚗 战车模式下探索更安全，但燃料有限，注意补给。",
                "🗺 解锁新区域需要满足条件，如击败一定数量的敌人。",
                "💰 赏金首奖励丰厚，但难度很高，建议组队挑战。",
                "📦 迷宫中的宝箱不要错过，可能有稀有装备。",
                "⚔ 毒刃技能可以持续伤害敌人，对付高HP敌人很有效。",
                "🛡 防御技能可以减少受到的伤害，危急时使用。",
                "📈 升级后HP回满，可以利用这一点节省药品。",
        ]

        for tip in tips:
                var label := Label.new()
                label.text = tip
                label.add_theme_color_override("font_color", Color(0.85, 0.85, 0.7))
                label.add_theme_font_size_override("font_size", 15)
                label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
                label.custom_minimum_size = Vector2(500, 0)
                tab.add_child(label)

                var spacer := Control.new()
                spacer.custom_minimum_size = Vector2(0, 6)
                tab.add_child(spacer)

## 打开帮助
func open() -> void:
        visible = true

## 关闭帮助
func close() -> void:
        visible = false
        queue_free()

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close()
