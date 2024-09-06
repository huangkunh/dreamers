extends PanelContainer

@export var change_health_value : int = 100:
	set(value):
		health_update(value)

@onready var health_bar_cure : TextureProgressBar = $HealthBarCure
@onready var health_bar_decrease : TextureProgressBar = $HealthBarDecrease
@onready var health_bar_base : TextureProgressBar = $HealthBarBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init_all_health_bar(health_data):
	health_bar_cure.min_value = 0
	health_bar_decrease.min_value = 0
	health_bar_base.min_value = 0
	
	health_bar_cure.max_value = health_data.max_health
	health_bar_decrease.max_value = health_data.max_health
	health_bar_base.max_value = health_data.max_health
	
	health_bar_cure.value = health_data.curren_health
	health_bar_decrease.value = health_data.curren_health
	health_bar_base.value = health_data.curren_health
	

func health_update(change_health):
	if change_health == 0 || health_bar_base == null:
		return
		
	var current_health = health_bar_base.value
	if change_health < 0:
		current_health += change_health
		health_bar_base.value = current_health
		health_bar_cure.value = current_health
		
		var tween = health_bar_decrease.create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(health_bar_decrease, "value", current_health, 0.5)
	else:
		current_health += change_health
		health_bar_cure.value = current_health
		
		var tween = health_bar_base.create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(health_bar_base, "value", current_health, 0.5)
		tween.tween_callback(health_bar_decrease.set_value.bind(current_health))
	
