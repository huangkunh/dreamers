extends VBoxContainer
@onready var exp_lv_label: Label = $PlayerExpLv/ExpLvLabel
@onready var experience_label: Label = $HBoxContainer2/ExperienceLabel
@onready var experience_bar: PanelContainer = $ExperienceBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 初始化玩家获得经验
## data 数据
func init_earn_experience(data):
	var current_exp = data.current_exp + data.earn_exp
	var max_exp = data.max_exp
	experience_label.text = str(current_exp) + " / " + str(max_exp)
	exp_lv_label.text = "LV " + str(data.exp_lv)
	experience_bar._ready()
	experience_bar.exp_update(data.earn_exp)
	pass
