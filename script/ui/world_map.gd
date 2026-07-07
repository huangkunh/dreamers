extends Control
## 世界地图 (WorldMap)
## HD-2D 风格的区域选择画面
## 玩家可以在此选择要前往的地点

@onready var area_container: VBoxContainer = $MarginContainer/VBoxContainer/AreaContainer
@onready var area_info_label: RichTextLabel = $MarginContainer/VBoxContainer/AreaInfoLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/BottomBar/BackButton
@onready var title_label: Label = $MarginContainer/VBoxContainer/TitleLabel

## 区域数据
const AREAS := [
	{
		"id": "aoduo",
		"name": "奥多市",
		"description": "荒野中幸存的小镇，冒险的起点。\n这里有酒吧、机械师和赏金猎人公会。",
		"scene": "city",
		"locked": false,
	},
	{
		"id": "wasteland",
		"name": "荒野",
		"description": "充满变异生物的危险地带。\n适合新手猎人练级，但小心流浪坦克。",
		"scene": "city",
		"locked": false,
	},
	{
		"id": "ruins",
		"name": "旧文明遗迹",
		"description": "战前文明的废墟，藏有古代科技。\n需要战车才能深入探索。",
		"scene": "city",
		"locked": true,
	},
	{
		"id": "bounty",
		"name": "赏金首情报",
		"description": "查看当前已知的悬赏目标。\n击败它们可获得高额赏金。",
		"scene": "city",
		"locked": true,
	},
]

var _current_index: int = 0
var _area_buttons: Array[Button] = []

func _ready() -> void:
	title_label.text = "世界地图 - 选择目的地"
	back_button.pressed.connect(_on_back)

	# 生成区域按钮
	for area in AREAS:
		var btn := Button.new()
		var prefix := "🔒 " if area.locked else "▶ "
		btn.text = prefix + area.name
		btn.custom_minimum_size = Vector2(300, 40)
		btn.add_theme_font_size_override("font_size", 20)
		btn.add_theme_color_override("font_color", Color(0.9, 0.85, 0.7))
		btn.add_theme_color_override("font_hover_color", Color(1, 0.85, 0.3))
		btn.pressed.connect(_on_area_pressed.bind(area))
		area_container.add_child(btn)
		_area_buttons.append(btn)

	# 默认选中第一个
	_update_selection()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP, KEY_W:
				_current_index = (_current_index - 1 + AREAS.size()) % AREAS.size()
				_update_selection()
			KEY_DOWN, KEY_S:
				_current_index = (_current_index + 1) % AREAS.size()
				_update_selection()
			KEY_ENTER, KEY_SPACE:
				var area = AREAS[_current_index]
				_on_area_pressed(area)
			KEY_ESCAPE:
				_on_back()

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
		# 播放锁定提示音
		return
	print("[WorldMap] 进入区域: " + area.name)
	GameFlow.enter_city()

func _on_back() -> void:
	GameFlow.return_to_title()
