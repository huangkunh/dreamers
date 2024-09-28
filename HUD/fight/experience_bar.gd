extends PanelContainer

@export var change_exp_value: int = 100:
	set(value):
		exp_update(value)

@onready var exp_bar_cure: TextureProgressBar = $ExpBarCure
@onready var exp_bar_base: TextureProgressBar = $ExpBarBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 初始化经验条
## 参数 exp_data 经验值数据
func init_all_exp_bar(exp_data):
	exp_bar_cure.min_value = 0
	#exp_bar_decrease.min_value = 0
	exp_bar_base.min_value = 0
	
	exp_bar_cure.max_value = exp_data.max_exp
	#exp_bar_decrease.max_value = exp_data.max_exp
	exp_bar_base.max_value = exp_data.max_exp
	
	
	var current_exp = exp_data.current_exp
	exp_bar_cure.value = current_exp
	#exp_bar_decrease.value = 0
	exp_bar_base.value = 0
	if current_exp > 0:
		var tween = exp_bar_base.create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(exp_bar_base, "value", current_exp, 0.5)
		#tween.tween_callback(exp_bar_decrease.set_value.bind(current_exp))
			
## 更新经验值
## 参数 change_exp 改变的经验值 可能为负数
func exp_update(change_exp):
	if change_exp == 0 || exp_bar_base == null:
		return
		
	var current_exp = exp_bar_base.value
	if change_exp < 0:
		current_exp += change_exp
		exp_bar_base.value = current_exp
		exp_bar_cure.value = current_exp
		
		#var tween = exp_bar_decrease.create_tween()
		#tween.set_trans(Tween.TRANS_SINE)
		#tween.tween_property(exp_bar_decrease, "value", current_exp, 0.5)
	else:
		current_exp += change_exp
		exp_bar_cure.value = current_exp
		
		var tween = exp_bar_base.create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(exp_bar_base, "value", current_exp, 0.5)
		#tween.tween_callback(exp_bar_decrease.set_value.bind(current_exp))
	
