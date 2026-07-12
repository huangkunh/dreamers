extends Control
## 赏金猎人公会 (BountyGuild)
## 查看赏金首列表、领取赏金
## 使用方式: 从 NPC 交互触发

@onready var guild_panel: PanelContainer = $GuildPanel
@onready var bounty_list: ItemList = $GuildPanel/MarginContainer/VBoxContainer/HBoxContainer/BountyList
@onready var info_label: RichTextLabel = $GuildPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/InfoLabel
@onready var claim_button: Button = $GuildPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ButtonContainer/ClaimButton
@onready var close_button: Button = $GuildPanel/MarginContainer/VBoxContainer/HBoxContainer/InfoPanel/ButtonContainer/CloseButton
@onready var coins_label: Label = $GuildPanel/MarginContainer/VBoxContainer/TitleBar/CoinsLabel

var _current_index: int = 0

func _ready() -> void:
        visible = false
        process_mode = Node.PROCESS_MODE_WHEN_PAUSED
        claim_button.pressed.connect(_on_claim)
        close_button.pressed.connect(close_guild)
        bounty_list.item_selected.connect(_on_bounty_selected)

func open_guild() -> void:
        visible = true
        get_tree().paused = true
        coins_label.text = "💰 " + str(GameData.coins)
        _refresh_bounty_list()

func close_guild() -> void:
        visible = false
        get_tree().paused = false
        queue_free()

func _refresh_bounty_list() -> void:
        bounty_list.clear()
        var all_bounties = BountySystem.bounties.values()
        for bounty in all_bounties:
                var status_text = _get_status_text(bounty.status)
                var difficulty_stars = "★".repeat(bounty.difficulty)
                bounty_list.add_item("%s %s [%sG]" % [bounty.name, status_text, bounty.reward])
        if all_bounties.size() > 0:
                bounty_list.select(0)
                _on_bounty_selected(0)

func _on_bounty_selected(index: int) -> void:
        _current_index = index
        var all_bounties = BountySystem.bounties.values()
        if index < 0 or index >= all_bounties.size():
                return
        var bounty = all_bounties[index]
        var text := "[b][color=#ffcc44]%s[/color][/b]\n\n" % bounty.name
        text += "[color=#aaaaaa]难度: %s[/color]\n" % "★".repeat(bounty.difficulty)
        text += "[color=#aaaaaa]出没地: %s[/color]\n" % bounty.location
        text += "[color=#aaaaaa]建议等级: Lv.%d+[/color]\n\n" % bounty.min_level
        text += "%s\n\n" % bounty.description
        text += "[color=#ffcc44]赏金: %dG[/color]\n" % bounty.reward
        text += "[color=#aaaaaa]状态: %s[/color]\n" % _get_status_text(bounty.status)
        info_label.text = text
        # 只有已击败未领赏的才能领
        claim_button.disabled = bounty.status != BountySystem.BountyStatus.DEFEATED
        claim_button.text = "领取赏金" if bounty.status == BountySystem.BountyStatus.DEFEATED else "领取赏金"

func _on_claim() -> void:
        var all_bounties = BountySystem.bounties.values()
        if _current_index < 0 or _current_index >= all_bounties.size():
                return
        var bounty = all_bounties[_current_index]
        if bounty.status == BountySystem.BountyStatus.DEFEATED:
                var reward = BountySystem.claim_bounty(bounty.id)
                coins_label.text = "💰 " + str(GameData.coins)
                info_label.text = "[color=#44ff44]领取成功！+%dG[/color]" % reward
                _refresh_bounty_list()

func _get_status_text(status: int) -> String:
        match status:
                BountySystem.BountyStatus.AVAILABLE: return "⚪ 可接取"
                BountySystem.BountyStatus.DEFEATED: return "✅ 已击败"
                BountySystem.BountyStatus.CLAIMED: return "💰 已领赏"
                BountySystem.BountyStatus.LOCKED: return "🔒 未解锁"
                _: return "???"

func _unhandled_input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close_guild()
                get_viewport().set_input_as_handled()
