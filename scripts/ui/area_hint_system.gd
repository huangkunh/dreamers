extends Control
## 区域提示系统 (AreaHintSystem)
## 玩家进入新区域时显示区域名称和提示
## 自动淡入淡出

@onready var area_name_label: Label = $Panel/AreaNameLabel
@onready var area_desc_label: Label = $Panel/AreaDescLabel
@onready var hint_label: Label = $Panel/HintLabel

## 区域信息
const AREA_INFO := {
	"aoduo": {"name": "奥多市", "desc": "荒野中的安全小镇", "hint": "按M打开菜单，按E与NPC交互"},
	"wasteland": {"name": "荒野", "desc": "危险的变异生物出没地", "hint": "注意HP，随时准备战斗"},
	"factory": {"name": "废弃工厂", "desc": "旧文明的工业遗迹", "hint": "深处有失控坦克，小心BOSS"},
	"ant_nest": {"name": "蚂蚁巢穴", "desc": "地下蚁穴，蚁后盘踞", "hint": "带好解毒药，蚁后有酸液攻击"},
	"ancient_ruins": {"name": "古代遗迹", "desc": "旧文明研究所遗址", "hint": "不定形生命体弱火，准备火焰武器"},
}

func _ready() -> void:
	visible = false
	modulate.a = 0.0

## 显示区域提示
## area_id: 区域ID
func show_area_hint(area_id: String) -> void:
	var info = AREA_INFO.get(area_id, null)
	if not info:
		return

	area_name_label.text = "📍 " + info.name
	area_desc_label.text = info.desc
	hint_label.text = "💡 " + info.hint

	visible = true

	# 淡入
	var tw_in := create_tween()
	tw_in.tween_property(self, "modulate:a", 1.0, 0.5)

	# 等待3秒
	await get_tree().create_timer(3.0).timeout

	# 淡出
	var tw_out := create_tween()
	tw_out.tween_property(self, "modulate:a", 0.0, 1.0)
	tw_out.tween_callback(func(): visible = false)

## 显示自定义提示
func show_custom_hint(title: String, desc: String, hint: String = "") -> void:
	area_name_label.text = title
	area_desc_label.text = desc
	hint_label.text = hint

	visible = true

	var tw_in := create_tween()
	tw_in.tween_property(self, "modulate:a", 1.0, 0.5)

	await get_tree().create_timer(3.0).timeout

	var tw_out := create_tween()
	tw_out.tween_property(self, "modulate:a", 0.0, 1.0)
	tw_out.tween_callback(func(): visible = false)
