extends Control
## 战斗结算画面 (FightSettlement)
## 显示战斗获得的经验/金钱，确认后返回城市

@export var player_earn_experience_scene: PackedScene

@onready var coins_label: Label = $FightResult/EarnCoins/CoinsLabel
@onready var experience_label: Label = $FightResult/EarnExperience/ExperienceLabel
@onready var confirm_label: Label = $ConfirmLabel

var _settlement_shown: bool = false

func _ready() -> void:
        visible = false
        if confirm_label:
                confirm_label.modulate.a = 0.0

func _process(_delta: float) -> void:
        # 如果结算画面已显示，等待玩家确认
        if _settlement_shown and Input.is_action_just_pressed("ui_accept"):
                _return_to_city()

## 初始化战斗结果
func init_fight_settlement(data: Dictionary):
        experience_label.text = str(data.get("earn_exp", 0))
        coins_label.text = str(data.get("earn_coins", 0))

        var players_data: Array = data.get("players_data", [])
        for i in players_data.size():
                var player_earn_experience = player_earn_experience_scene.instantiate()
                var player_data = players_data[i]
                player_earn_experience._ready()
                player_earn_experience.init_earn_experience(player_data)
                get_node("FightResult").add_child(player_earn_experience)

        # 显示掉落物品
        var drops: Array = data.get("drops", [])
        if drops.size() > 0:
                var drop_text = "\n[color=#ffcc44]掉落物品:[/color]\n"
                for drop in drops:
                        drop_text += "  %s x%d\n" % [drop.name, drop.count]
                var drop_label = get_node_or_null("FightResult/DropLabel")
                if drop_label == null:
                        drop_label = Label.new()
                        drop_label.name = "DropLabel"
                        drop_label.position = Vector2(0, 200)
                        get_node("FightResult").add_child(drop_label)
                drop_label.text = drop_text

        # BOSS战特殊提示
        if data.get("is_bounty_battle", false):
                var bounty_name = data.get("bounty_name", "")
                var bounty_label = get_node_or_null("FightResult/BountyLabel")
                if bounty_label == null:
                        bounty_label = Label.new()
                        bounty_label.name = "BountyLabel"
                        bounty_label.position = Vector2(0, 280)
                        get_node("FightResult").add_child(bounty_label)
                bounty_label.text = "[color=#ff4444]☠ 赏金首 %s 已被击败![/color]" % bounty_name

        # 显示确认提示
        if confirm_label:
                var tw := create_tween()
                tw.tween_interval(1.0)
                tw.tween_property(confirm_label, "modulate:a", 1.0, 0.5)
                # 呼吸动画
                var tw2 := create_tween()
                tw2.set_loops()
                tw2.tween_property(confirm_label, "modulate:a", 0.4, 0.8)
                tw2.tween_property(confirm_label, "modulate:a", 1.0, 0.8)

        _settlement_shown = true

## 返回之前的区域
func _return_to_city() -> void:
        _settlement_shown = false
        print("[FightSettlement] 战斗结束，返回之前区域")
        # 重置随机遇敌计数，避免返回后立即遇敌
        _reset_encounter_counter()
        # 使用SceneTransitionManager返回
        SceneTransitionManager.return_from_battle()

## 重置随机遇敌计数
func _reset_encounter_counter() -> void:
        # 在场景树中查找 RandomEncounter 节点并重置
        var root = get_tree().root
        for i in range(root.get_child_count()):
                var child = root.get_child(i)
                _find_and_reset_encounter(child)

func _find_and_reset_encounter(node: Node) -> void:
        if node.has_method("reset_encounter_counter"):
                node.reset_encounter_counter()
                print("[FightSettlement] 随机遇敌计数已重置")
                return
        for i in range(node.get_child_count()):
                _find_and_reset_encounter(node.get_child(i))
