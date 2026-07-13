extends Control
## 通缉令界面 (WantedPoster)
## Metal Max原作特色: 在酒馆查看赏金首通缉令
## 显示赏金首的详细信息: 外观/悬赏金/危险等级/出没地点

@onready var bounty_list: ItemList = $Panel/HBoxContainer/LeftPanel/BountyList
@onready var name_label: Label = $Panel/HBoxContainer/RightPanel/InfoContainer/NameLabel
@onready var reward_label: Label = $Panel/HBoxContainer/RightPanel/InfoContainer/RewardLabel
@onready var difficulty_label: Label = $Panel/HBoxContainer/RightPanel/InfoContainer/DifficultyLabel
@onready var location_label: Label = $Panel/HBoxContainer/RightPanel/InfoContainer/LocationLabel
@onready var desc_label: RichTextLabel = $Panel/HBoxContainer/RightPanel/DescLabel
@onready var status_label: Label = $Panel/HBoxContainer/RightPanel/InfoContainer/StatusLabel
@onready var close_button: Button = $Panel/CloseButton

func _ready() -> void:
	visible = false
	close_button.pressed.connect(close)
	bounty_list.item_selected.connect(_on_bounty_selected)

## 打开通缉令
func open() -> void:
	_refresh_bounty_list()
	visible = true

## 刷新赏金首列表
func _refresh_bounty_list() -> void:
	bounty_list.clear()

	for bounty_id in BountySystem.bounties.keys():
		var bounty = BountySystem.bounties[bounty_id]
		var status_text = ""
		match bounty.status:
			BountySystem.BountyStatus.AVAILABLE: status_text = "悬赏中"
			BountySystem.BountyStatus.DEFEATED: status_text = "已击败"
			BountySystem.BountyStatus.CLAIMED: status_text = "已领赏"
			BountySystem.BountyStatus.LOCKED: status_text = "未解锁"

		var item_text = "%s (%dG) [%s]" % [bounty.name, bounty.reward, status_text]
		bounty_list.add_item(item_text)

	# 默认选中第一个
	if bounty_list.item_count > 0:
		bounty_list.select(0)
		_on_bounty_selected(0)

## 选择赏金首
func _on_bounty_selected(index: int) -> void:
	if index < 0 or index >= BountySystem.bounties.size():
		return

	var bounty_ids = BountySystem.bounties.keys()
	var bounty = BountySystem.bounties[bounty_ids[index]]

	name_label.text = "🎯 " + bounty.name
	reward_label.text = "💰 悬赏金: %d G" % bounty.reward
	difficulty_label.text = "⚔ 危险等级: %d/5" % bounty.difficulty
	location_label.text = "📍 出没地点: " + bounty.location
	desc_label.text = bounty.description

	# 状态显示
	match bounty.status:
		BountySystem.BountyStatus.AVAILABLE:
			status_label.text = "状态: 悬赏中"
			status_label.add_theme_color_override("font_color", Color(1, 0.85, 0.3))
		BountySystem.BountyStatus.DEFEATED:
			status_label.text = "状态: 已击败 (可领赏)"
			status_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5))
		BountySystem.BountyStatus.CLAIMED:
			status_label.text = "状态: 已领赏"
			status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		BountySystem.BountyStatus.LOCKED:
			status_label.text = "状态: 未解锁"
			status_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

## 关闭
func close() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
