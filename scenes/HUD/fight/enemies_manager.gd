extends Node3D

@export var enemy_scene: PackedScene

## 位置信息
@onready var enemies_marker = {
        1: $"EnemiesMarker1",
        2: $"EnemiesMarker2",
        3: $"EnemiesMarker3",
        4: $"EnemiesMarker4",
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
        #generation_enemy_position(Vector3(-0.106442, 0.839271, 2.57322))
        #generation_enemy()
        pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
        pass

## 生成怪物
## 参数 enemies_init_datas 怪物数据
## 返回 生成怪物数据列表
func generation_enemy(enemies_init_datas):
        var enemy_num = enemies_init_datas.size()

        if enemy_num == 0:
                return []

        # 限制敌人数不超过4 (marker数量)
        enemy_num = min(enemy_num, 4)

        var enemies_marker_p: Node3D = enemies_marker[enemy_num]
        var enemy_list = []
        for i in range(enemy_num):
                var marker3D = enemies_marker_p.get_children()[i]
                var enemies_init_data = enemies_init_datas[i]
                var enemy_data = generation_enemy_position(marker3D.position, enemies_init_data)
                enemy_list.append(enemy_data)

        return enemy_list

## 根据位置信息生成怪物
## 参数 marker_position 位置信息
## 参数 enemies_init_data 怪物数据
## 返回 生成怪物的数据
func generation_enemy_position(marker_position, enemies_init_data):
        enemies_init_data.enemy_position = marker_position

        var enemy: CharacterBody3D = enemy_scene.instantiate()
        enemy.init_enemy(enemies_init_data)
        add_child(enemy)

        return enemy
        
