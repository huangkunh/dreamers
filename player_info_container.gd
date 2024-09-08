extends VBoxContainer

@onready var health_bar : PanelContainer = $HealthBar
@onready var player_name : Label = $PlayerName
@onready var health_info : Label = $HealthInfo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func init_player_info(player_info):
	health_bar.init_all_health_bar(player_info)
	player_name.text = player_info.player_name
	var current_health = str(player_info.current_health)
	var max_health = str(player_info.max_health)
	health_info.text = "HP : " + current_health + " / " + max_health
	
