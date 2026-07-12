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
        # 使用SceneTransitionManager返回
        SceneTransitionManager.return_from_battle()
