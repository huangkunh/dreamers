extends Control

@export var player_earn_experience_scene: PackedScene

@onready var coins_label: Label = $FightResult/EarnCoins/CoinsLabel
@onready var experience_label: Label = $FightResult/EarnExperience/ExperienceLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 初始化战斗结果
## data 数据
func init_fight_settlement(data):
	experience_label.text = str(data.earn_exp)
	coins_label.text = str(data.earn_coins)
	
	for i in (data.players_data.size()):
		var player_earn_experience = player_earn_experience_scene.instantiate()
		var player_data = data.players_data[i]
		player_earn_experience._ready()
		player_earn_experience.init_earn_experience(player_data)
		get_node("FightResult").add_child(player_earn_experience)
