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
## data 数据 (Dictionary 或 Object)
func init_earn_experience(data):
        var current_exp: int = data.get("current_exp", 0) if data is Dictionary else data.current_exp
        var earn_exp: int = data.get("earn_exp", 0) if data is Dictionary else data.earn_exp
        var max_exp: int = data.get("max_exp", 100) if data is Dictionary else data.max_exp
        var exp_lv: int = data.get("exp_lv", data.get("level", 1)) if data is Dictionary else data.exp_lv

        experience_label.text = str(current_exp + earn_exp) + " / " + str(max_exp)
        exp_lv_label.text = "LV " + str(exp_lv)
        experience_bar._ready()
        experience_bar.exp_update(earn_exp)
