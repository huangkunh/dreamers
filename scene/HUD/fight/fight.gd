extends Node3D

@onready var enenies_manager: Node3D = $EnemiesManager
@onready var fight_player_manager: Node3D = $FightPlayerManager
@onready var player_info_container: VBoxContainer = $FightHUD/PlayerInfo/PlayerInfoContainer
@onready var fight_speed_path: Path2D = $FightHUD/FightSpeedPath
@onready var skill_name_label: RichTextLabel = $FightHUD/SkillName
@onready var health_bar: PanelContainer = $FightHUD/PlayerInfo/PlayerInfoContainer/HealthBar
@onready var fight_menu: VBoxContainer = $FightHUD/FightMenu
@onready var fighting_player_marker: Marker3D = $FightPlayerManager/FightingPlayerMarker
@onready var fight_hud: Control = $FightHUD
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var fight_settlement: Control = $FightSettlement
@onready var fight_camera_3d: Camera3D = $fight_camera_3d

var enemy_data = load("res://resource/data/enemy_data.gd")
var enemies_init_data = enemy_data.new().enemies_init_data
var attack_data = AttackData
var fight_player_init_data = PlayerData.fight_player_init_data

# 正在战斗的单位
var fighting_unit_map: Dictionary = {}

# 敌人场景
var enemy_scene_map = {}

# 玩家场景
var player_scene_map = {}

# 正在战斗的id
var fighting_id

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
        fight_hud.determine_attack_target_signal.connect(player_attck)
        
        # 生成怪物 — 根据当前区域筛选
        var battle_area = GameData.game_flags.get("battle_area", "aoduo")
        var area_enemies = enemy_data.new().get_enemies_by_area(battle_area)
        var boss_id = GameData.game_flags.get("boss_battle", "")
        
        var enemies_data_list = []
        if not boss_id.is_empty():
                # BOSS战 — 只生成赏金首
                var boss_data = enemy_data.new().get_enemy_by_id(boss_id)
                if not boss_data.is_empty():
                        var enemy = boss_data.duplicate(true)
                        enemy.fight_id = boss_id + "_0"
                        fighting_unit_map[enemy.fight_id] = enemy
                        enemies_data_list.append(enemy)
                        print("[Fight] BOSS战: " + str(boss_data.get("local_player_name", boss_id)))
        else:
                # 普通遇敌 — 从区域敌人池随机生成1-4只
                var generation_num = randi_range(1, 4)
                for i in generation_num:
                        if area_enemies.is_empty():
                                break
                        var index = randi() % area_enemies.size()
                        var enemy = area_enemies[index].duplicate(true)
                        # 重置HP
                        enemy["current_health"] = enemy.get("max_health", 100)
                        var fight_id = enemy.player_name + "_" + str(i)
                        enemy.fight_id = fight_id
                        fighting_unit_map[fight_id] = enemy
                        enemies_data_list.append(enemy)
        
        var enemy_scene: Array = enenies_manager.generation_enemy(enemies_data_list)
        for enemy in enemy_scene:
                enemy_scene_map[enemy.fight_id] = enemy
        
        #生成玩家
        for i in range(fight_player_init_data.size()):
                var fight_player_data = fight_player_init_data[i]
                var fight_id = fight_player_data.player_name + "_" + str(i)
                fight_player_data.fight_id = fight_id
                fighting_unit_map[fight_id] = fight_player_data
                
        var player_scene = fight_player_manager.generation_fight_palyer(fight_player_init_data)
        for player in player_scene:
                player_scene_map[player.fight_id] = player
        
        #生成玩家信息(右上角)
        for i in range(fight_player_init_data.values().size()):
                player_info_container.init_player_info(fight_player_init_data[i])
        
        # 生成战斗进度
        fight_speed_path.init_fight_speed_Path(fighting_unit_map.values())
        
        # 移动摄像头
        fight_camera_3d.move_horizontally(0.2, 2.0)
        pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
        pass


## 战斗
func _on_fight_speed_path_uint_fighting(fight_id) -> void:
        fighting_id = fight_id
        var fighting_unit = fighting_unit_map[fight_id]
        # 是玩家
        if fighting_unit.confirm_player:
                var player_scene: CharacterBody3D = player_scene_map[fight_id]
                player_scene.fight_originally_position = player_scene.position
                fighting_player_marker.position.y = player_scene.position.y
                var tween = player_scene.create_tween()
                tween.tween_property(player_scene, "position", fighting_player_marker.position, 0.3)
                tween.tween_callback(fight_menu.set_visible.bind(true))
                tween.tween_callback(fight_hud.pointer.set_visible.bind(true))
                
                pass
        else: #是怪物
                var skill_index = randi_range(0, fighting_unit.skills.size() - 1)
                var skill = fighting_unit.skills[skill_index]
                if skill.attack_type == attack_data.Attack_Type.MELEE:
                        if skill.attack_type == attack_data.Attack_Target.FOE_ONE:
                                enemy_melee_foe_one(skill)


## 敌人近战单体攻击
## skill 技能     
func enemy_melee_foe_one(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        
        # 攻击玩家
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)                                
        
        # 被攻击的玩家
        var player_scene_index = randi_range(0, player_scene_map.size() - 1)
        var player_scene: CharacterBody3D = player_scene_map.values()[player_scene_index]
        player_scene.under_fire(tween)
        
        # 受到伤害数值动画
        var fighting_unit = fighting_unit_map[fighting_id]
        var skill_hurt = (skill.skill_strength * fighting_unit.battle_lv) as int
        player_scene.under_fire_label(skill_hurt, tween)
        
        # 摄像机运动
        fight_camera_3d.look_at_target(player_scene.global_position, 0.1)
        
        # 玩家信息
        var fighting_unit_palyer = fighting_unit_map[player_scene.fight_id]
        fighting_unit_palyer.current_health -= skill_hurt
        if fighting_unit_palyer.current_health <= 0:
                fighting_unit_palyer.current_health = 0
        var current_health = str(fighting_unit_palyer.current_health)
        var max_health = str(fighting_unit_palyer.max_health)
        var health_info = player_info_container.find_child("HealthInfo")
        var health_label = "HP: " + current_health + " / " + max_health
        tween.parallel().tween_callback(health_bar.health_update.bind( - skill_hurt))
        tween.parallel().tween_callback(health_info.set_text.bind(health_label))
        tween.tween_callback(player_scene.set_fight_player_data.bind(fighting_unit_palyer))

        # 判断玩家是否存活
        if check_all_player_death():
                tween.parallel().tween_callback(self.all_player_death)
                return
        
        # 单位战斗结束
        tween.parallel().tween_callback(fight_speed_path.unit_fight_end.bind(fighting_id))
        tween.parallel().tween_callback(fight_camera_3d.reset_camera_status)
        
        
## 玩家攻击
## attack_pointer_index 攻击的光标索引
func player_attck(attack_pointer_index):        
        var fight = self
        var fighting_id = fight.fighting_id
        var fight_unit = fight.fighting_unit_map[fighting_id]
        var weapons = fight_unit.weapons
        if AttackData.Attack_Type.REMOTE == weapons.attack_type:
                if AttackData.Attack_Target.FOE_ONE == weapons.attack_target:
                        fight.player_remote_foe_one(attack_pointer_index)                       
                        pass
                        
        
## 玩家远程单体攻击
## attack_pointer_index 敌人索引
func player_remote_foe_one(attack_pointer_index):
        
        # 武器攻击动画
        var player_scene: CharacterBody3D = player_scene_map[fighting_id]
        var enemy_scene:CharacterBody3D = enemy_scene_map.values()[attack_pointer_index]
        var enemy_fight_id = enemy_scene.fight_id
        var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
        var weapons_tween = player_scene.create_tween()
        player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
        
        # 摄像机运动
        fight_camera_3d.look_at_target(enemy_scene.global_position, 0.1)
        
        # 造成伤害 = 武器白刃战LV + 人物白刃战LV - 目标强度
        var fight_unit = fighting_unit_map[fighting_id]
        var enemy_death = enemy_scene.under_fire(fight_unit, enemy_fight_unit, weapons_tween)
        
        # 怪物死亡
        if enemy_death:
                enemy_scene.enemy_death(weapons_tween)
                weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                # 校验所有敌人死亡
                if check_all_enemy_death():
                        weapons_tween.tween_callback(self.all_enemy_death)                      
                        return
                
        # 单位战斗结束
        weapons_tween.parallel().tween_callback(fight_speed_path.unit_fight_end.bind(fighting_id))
        weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
        weapons_tween.parallel().tween_callback(fight_camera_3d.reset_camera_status)


## 清除战斗数据
func clear_fight_data(fight_id):
        fighting_unit_map.erase(fight_id)
        enemy_scene_map.erase(fight_id)
        player_scene_map.erase(fight_id)
        fight_speed_path.unit_fight_death(fight_id)

                
## 检测所有敌人死亡
func check_all_enemy_death()-> bool:
        return enemy_scene_map.values().all(func(value):
                        return value.fight_enemy_data.current_health <= 0)
        
        
## 所有敌人死亡
func all_enemy_death():
        # 播放战斗胜利音乐
        audio_stream_player.stream = load("res://music/sound_effect/battle_victory_normal.wav")
        audio_stream_player.play()

        # 暂停战斗进度
        fight_hud.visible = false
        fight_speed_path.fight_stop()

        # 获得经验 金钱 — 使用 LevelUpSystem 计算
        var enemy_level_sum = 0
        var enemy_count = 0
        for unit in fighting_unit_map.values():
                if not unit.confirm_player:
                        enemy_level_sum += int(unit.get("battle_lv", 5))
                        enemy_count += 1
        
        var earn_exp: int
        var earn_coins: int
        if enemy_count > 0:
                earn_exp = LevelUpSystem.calculate_battle_exp(enemy_level_sum / enemy_count, enemy_count)
                earn_coins = LevelUpSystem.calculate_battle_coins(enemy_level_sum / enemy_count, enemy_count)
        else:
                earn_exp = 10
                earn_coins = 10

        # 检查是否是BOSS战 (赏金首)
        var boss_id = GameData.game_flags.get("boss_battle", "")
        if not boss_id.is_empty():
                # BOSS战胜利 — 更新赏金首状态
                if BountySystem.bounties.has(boss_id):
                        var bounty = BountySystem.bounties[boss_id]
                        bounty.status = BountySystem.BountyStatus.DEFEATED
                        # 额外奖励
                        earn_exp += bounty.min_level * 20
                        earn_coins += bounty.reward
                        print("[Fight] 击败赏金首: " + bounty.name + " 获得赏金: " + str(bounty.reward))
                        BountySystem.bounty_defeated.emit(boss_id)
                # 清除BOSS战标记
                GameData.game_flags.erase("boss_battle")

        # 给玩家队伍添加金币和经验
        GameData.coins += earn_coins
        for member in GameData.party:
                LevelUpSystem.add_exp(member, earn_exp)

        # 更新任务进度
        QuestSystem.update_objective("defeat_enemies", "any", enemy_count)
        if not boss_id.is_empty():
                QuestSystem.update_objective("defeat_bounty", boss_id, 1)

        # 记录战斗胜利
        GameData.encounter_count += 1
        GameData.defeat_count += fighting_unit_map.values().filter(func(u): return not u.confirm_player).size()
        GameData.game_flags["battles_won"] = int(GameData.game_flags.get("battles_won", 0)) + 1

        # 显示战斗结算
        var settlement_data: Dictionary = {}
        settlement_data.earn_exp = earn_exp
        settlement_data.earn_coins = earn_coins
        settlement_data.players_data = fighting_unit_map.values()
        for i in fighting_unit_map.values().size():
                var fighting_unit = fighting_unit_map.values()[i]
                fighting_unit.earn_exp = earn_exp
        fight_settlement.init_fight_settlement(settlement_data)

        fight_settlement.visible = true
        fight_camera_3d.fight_end()


## 检测玩家死亡                       
func check_all_player_death()-> bool:
        var all_death = player_scene_map.values().all(func(value): 
                        return value.fight_player_data.current_health <= 0)
        return all_death


## 全部玩家死亡
func all_player_death():
        audio_stream_player.stream = load("res://music/background_music/defeat.ogg")
        audio_stream_player.play()

        # 显示游戏结束画面
        var game_over_scene := load("res://scenes/ui/game_over_screen.tscn")
        var game_over: Control = game_over_scene.instantiate()
        add_child(game_over)
        # 延迟显示，让失败音乐先播放
        await get_tree().create_timer(2.0).timeout
        game_over.show_game_over()
