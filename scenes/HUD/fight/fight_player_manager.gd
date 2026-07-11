extends Node3D

@export var fight_player_screne: PackedScene


## 位置信息
@onready var fight_player_marker = {
	1: $"FightPlayerMarker1",
	2: $"FightPlayerMarker2",
	3: $"FightPlayerMarker3",
	4: $"FightPlayerMarker4",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## 生成玩家
## 参数 fight_player_init_datas 玩家数据
func generation_fight_palyer(fight_player_init_datas):
	var fight_palyer_num = fight_player_init_datas.size()
	
	var fight_player_marker_p :Node3D =  fight_player_marker[fight_palyer_num]
	var fight_player_list = []
	for i in range(fight_player_marker_p.get_children().size()):
		var marker3D = fight_player_marker_p.get_children()[i]
		var fight_player = generation_fight_palyer_position(marker3D.position, fight_player_init_datas[i])
		fight_player_list.append(fight_player)
	
	return fight_player_list


## 根据位置信息生成玩家
## 参数 marker_position 位置信息
## 参数 fight_player_init_datas 玩家数据
func generation_fight_palyer_position(marker_position, fight_player_init_datas):
	fight_player_init_datas.fight_palyer_position = marker_position
			
	var fight_palyer :CharacterBody3D = fight_player_screne.instantiate()
	fight_palyer._ready()
	fight_palyer.init_fight_palyer(fight_player_init_datas)
	add_child(fight_palyer)
	return fight_palyer
