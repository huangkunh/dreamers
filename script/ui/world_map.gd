extends Control
## 世界地图 (WorldMap)
## HD-2D 风格的区域选择画面
## 玩家可以在此选择要前往的地点

@onready var area_container: VBoxContainer = $MarginContainer/VBoxContainer/AreaContainer
@onready var area_info_label: RichTextLabel = $MarginContainer/VBoxContainer/AreaInfoLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/BottomBar/BackButton
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel

## 区域数据
var AREAS := [
        {
                "id": "aoduo",
                "name": "奥多市",
                "description": "荒野中幸存的小镇，冒险的起点。\n这里有酒吧、机械师和赏金猎人公会。\n[color=#88ff88]推荐等级: Lv.1-5[/color]",
                "scene": "city",
                "locked": false,
                "area_id": "aoduo",
        },
        {
                "id": "wasteland",
                "name": "荒野",
                "description": "充满变异生物的危险地带。\n适合新手猎人练级，但小心流浪暴走族。\n[color=#ffaa44]推荐等级: Lv.5-10[/color]",
                "scene": "city",
                "locked": false,
                "area_id": "wasteland",
        },
        {
                "id": "factory_ruins",
                "name": "废弃工厂",
                "description": "旧文明的工业遗迹。\n据说深处有台失控的自动战斗坦克...赏金1500G。\n[color=#ff4444]推荐等级: Lv.15+[/color]",
                "scene": "factory",
                "locked": true,
                "area_id": "factory_ruins",
                "unlock_condition": "wasteland_cleared",
        },
        {
                "id": "ant_nest",
                "name": "蚂蚁巢穴",
                "description": "巨大的地下蚁穴，蚁后盘踞其中。\n消灭蚁后可获得1000G赏金。\n[color=#ff4444]推荐等级: Lv.12+[/color]",
                "scene": "city",
                "locked": true,
                "area_id": "ant_nest",
                "unlock_condition": "defeat_5_enemies",
        },
        {
                "id": "ancient_ruins",
                "name": "古代遗迹",
                "description": "旧文明的地下研究所。\n据说保存着失落的科技和强大的武器蓝图。\n[color=#ff0000]推荐等级: Lv.20+[/color]",
                "scene": "city",
                "locked": true,
                "area_id": "ancient_ruins",
                "unlock_condition": "bounty_2_claimed",
        },
]

var _area_buttons: Array[Button] = []
var _current_index: int = 0

func _ready() -> void:
        _build_area_buttons()
        _update_selection()

        # 连接返回按钮
        if back_button:
                back_button.pressed.connect(_on_back)

func _build_area_buttons() -> void:
        for child in area_container.get_children():
                child.queue_free()

        for i in range(AREAS.size()):
                var area = AREAS[i]
                var btn := Button.new()
                btn.text = ("  " if not area.locked else "  🔒 ") + area.name
                btn.custom_minimum_size = Vector2(300, 50)
                btn.add_theme_font_size_override("font_size", 20)

                # 检查解锁条件
                if area.locked:
                        var unlock_cond = area.get("unlock_condition", "")
                        if not unlock_cond.is_empty() and GameData.game_flags.has(unlock_cond) and GameData.game_flags[unlock_cond]:
                                area = area.duplicate()
                                area.locked = false
                                AREAS[i] = area
                                btn.text = "  " + area.name

                if area.locked:
                        btn.disabled = true
                        btn.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
                        btn.add_theme_color_override("font_disabled_color", Color(0.4, 0.4, 0.4))

                btn.pressed.connect(_on_area_pressed.bind(area))
                area_container.add_child(btn)
                _area_buttons.append(btn)

func _input(event: InputEvent) -> void:
        if event is InputEventKey and event.pressed:
                match event.keycode:
                        KEY_UP, KEY_W:
                                _navigate(-1)
                        KEY_DOWN, KEY_S:
                                _navigate(1)
                        KEY_ENTER, KEY_SPACE:
                                if not AREAS[_current_index].locked:
                                        _on_area_pressed(AREAS[_current_index])
                        KEY_ESCAPE:
                                _on_back()

func _navigate(direction: int) -> void:
        _current_index = wrapi(_current_index + direction, 0, AREAS.size())
        # 跳过锁定区域
        while AREAS[_current_index].locked:
                _current_index = wrapi(_current_index + direction, 0, AREAS.size())
                if _current_index == 0 and AREAS[0].locked:
                        break
        _update_selection()

func _update_selection() -> void:
        for i in range(_area_buttons.size()):
                var btn := _area_buttons[i]
                if i == _current_index:
                        btn.grab_focus()
        # 更新信息面板
        var area = AREAS[_current_index]
        area_info_label.text = "[center][b][color=#ffcc44]%s[/color][/b]\n\n%s[/center]" % [area.name, area.description]

func _on_area_pressed(area: Dictionary) -> void:
        if area.locked:
                print("[WorldMap] 区域已锁定: " + area.name)
                return
        print("[WorldMap] 进入区域: " + area.name)
        # 设置当前区域ID
        GameData.game_flags["current_area"] = area.id
        # 根据区域场景切换
        var scene_name: String = area.get("scene", "city")
        GameFlow.change_scene(scene_name)

func _on_back() -> void:
        GameFlow.return_to_title()
