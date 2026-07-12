extends Control
## 快速旅行界面 (FastTravelScreen)
## 在已解锁的区域间快速移动
## 需要先访问过该区域才能快速旅行

@onready var area_container: VBoxContainer = $Panel/ScrollContainer/AreaContainer
@onready var back_button: Button = $Panel/BackButton
@onready var title_label: Label = $Panel/TitleLabel

## 可快速旅行的区域
const TRAVEL_AREAS := [
        {"id": "aoduo", "name": "奥多市", "area_id": "aoduo", "desc": "安全区域，有商店和NPC"},
        {"id": "wasteland", "name": "荒野", "area_id": "wasteland", "desc": "危险的野外区域，适合练级"},
        {"id": "factory", "name": "废弃工厂", "area_id": "factory", "desc": "BOSS: 失控坦克 (1500G)"},
        {"id": "ant_nest", "name": "蚂蚁巢穴", "area_id": "ant_nest", "desc": "BOSS: 蚁后 (800G)"},
        {"id": "ancient_ruins", "name": "古代遗迹", "area_id": "ancient_ruins", "desc": "BOSS: 不定形 (3000G)"},
]

var _area_buttons: Array[Button] = []
var _current_index: int = 0

func _ready() -> void:
        visible = false
        back_button.pressed.connect(close)
        _build_area_list()

## 构建区域列表
func _build_area_list() -> void:
        for child in area_container.get_children():
                child.queue_free()
        _area_buttons.clear()

        for area in TRAVEL_AREAS:
                # 检查是否已访问过 (使用与 city_explorer 一致的标志名)
                var visited_flag = area.area_id + "_visited"
                if area.area_id == "aoduo":
                        visited_flag = "aoduo_visited" # 奥多市默认已访问
                var visited = GameData.game_flags.get(visited_flag, area.area_id == "aoduo")
                if not visited:
                        continue

                var btn := Button.new()
                btn.text = "📍 " + area.name
                btn.custom_minimum_size = Vector2(400, 40)
                btn.add_theme_font_size_override("font_size", 18)
                btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
                btn.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.3))
                btn.pressed.connect(_on_area_selected.bind(area))
                area_container.add_child(btn)
                _area_buttons.append(btn)

        # 如果没有可旅行的区域
        if _area_buttons.is_empty():
                var label := Label.new()
                label.text = "暂无可快速旅行的区域\n请先探索更多区域"
                label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
                label.add_theme_font_size_override("font_size", 16)
                label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
                area_container.add_child(label)

## 选择区域
func _on_area_selected(area: Dictionary) -> void:
        print("[FastTravel] 快速旅行到: " + area.name)
        # 设置当前区域ID
        GameData.game_flags["current_area"] = area.area_id
        # 使用 enter_city 统一入口
        GameFlow.enter_city()

## 打开快速旅行
func open() -> void:
        _build_area_list()
        visible = true

## 关闭
func close() -> void:
        visible = false
        queue_free()

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close()
