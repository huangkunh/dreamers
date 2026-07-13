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

var enemy_data = load("res://scripts/data/enemy_data.gd")
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

# 正在防御的单位fight_id列表 (减半受到的伤害, 下回合开始时清除)
var _defending_units: Array = []

# 玩家技能选择模式 (按下技能键后进入, 选择目标后释放技能)
var _skill_select_mode: bool = false

# 待使用的技能索引
var _pending_skill_index: int = 0

# 玩家道具选择模式 (按下道具键后进入, 选择目标后使用道具)
var _item_select_mode: bool = false

# 待使用的道具索引
var _pending_item_index: int = 0

# 战车战模式标志 (true=战车战, false=步行战)
var _in_tank_battle: bool = false

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
        
        # 检查战车战模式 (战车或步行)
        _in_tank_battle = GameData.game_flags.get("battle_in_tank", false)

        #生成玩家
        for i in range(fight_player_init_data.size()):
                var fight_player_data = fight_player_init_data[i]
                var fight_id = fight_player_data.player_name + "_" + str(i)
                fight_player_data.fight_id = fight_id
                # 战车战模式 — 使用战车数据覆盖玩家属性
                if _in_tank_battle:
                        _apply_tank_battle_data(fight_player_data)
                fighting_unit_map[fight_id] = fight_player_data
                
        var player_scene = fight_player_manager.generation_fight_palyer(fight_player_init_data)
        for player in player_scene:
                player_scene_map[player.fight_id] = player
        
        #生成玩家信息(右上角)
        for i in range(fight_player_init_data.values().size()):
                player_info_container.init_player_info(fight_player_init_data[i])
        
        # 生成战斗进度
        fight_speed_path.init_fight_speed_Path(fighting_unit_map.values())
        
        # 播放战斗BGM
        BgmManager.play_battle_bgm()

        # 移动摄像头
        fight_camera_3d.move_horizontally(0.2, 2.0)
        pass # Replace with function body


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
        pass


## 处理战斗快捷键输入 (防御/逃跑/技能)
## 仅在玩家回合且菜单可见时响应
func _unhandled_key_input(event: InputEvent) -> void:
        # 菜单不可见时不处理 (非玩家回合或目标选择中)
        if fight_menu == null or not fight_menu.visible:
                return
        # 防御
        if Input.is_action_just_pressed("battle_defend"):
                player_defend()
                get_viewport().set_input_as_handled()
        # 逃跑
        elif Input.is_action_just_pressed("battle_escape"):
                player_flee()
                get_viewport().set_input_as_handled()
        # 技能
        elif Input.is_action_just_pressed("battle_skill"):
                _start_skill_selection()
                get_viewport().set_input_as_handled()
        # 道具
        elif Input.is_action_just_pressed("battle_item"):
                _start_item_selection()
                get_viewport().set_input_as_handled()


## 战斗
func _on_fight_speed_path_uint_fighting(fight_id) -> void:
        fighting_id = fight_id
        var fighting_unit = fighting_unit_map[fight_id]
        
        # 检查是否可以行动 (麻痹/眩晕)
        if not StatusEffectSystem.can_act(fighting_unit):
                var unit_name = fighting_unit.get("local_player_name", fighting_unit.get("player_name", fight_id))
                fight_hud.action_name_animation(unit_name + " 无法行动！")
                var skip_tween = create_tween()
                skip_tween.tween_interval(1.0)
                skip_tween.tween_callback(_process_unit_turn_end.bind(fight_id))
                return
        
        # 是玩家
        if fighting_unit.confirm_player:
                # 清除该单位的防御状态 (新一轮行动开始)
                _defending_units.erase(fight_id)
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
                # 负值强度或自身目标 → 自我治疗
                if skill.skill_strength < 0 or skill.attack_target == attack_data.Attack_Target.SELF_ONE:
                        enemy_self_heal(skill)
                elif skill.attack_type == attack_data.Attack_Type.MELEE:
                        if skill.attack_target == attack_data.Attack_Target.FOE_ONE:
                                enemy_melee_foe_one(skill)
                        elif skill.attack_target == attack_data.Attack_Target.FOE_ALL:
                                enemy_melee_foe_all(skill)
                        else:
                                enemy_melee_foe_one(skill)
                elif skill.attack_type == attack_data.Attack_Type.REMOTE:
                        if skill.attack_target == attack_data.Attack_Target.FOE_ONE:
                                enemy_remote_foe_one(skill)
                        elif skill.attack_target == attack_data.Attack_Target.FOE_ALL:
                                enemy_remote_foe_all(skill)
                        else:
                                enemy_remote_foe_one(skill)
                else:
                        enemy_melee_foe_one(skill)


## 敌人近战单体攻击
## skill 技能     
func enemy_melee_foe_one(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        SfxManager.play_sfx("attack_melee")
        
        # 攻击玩家
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var fighting_unit = fighting_unit_map[fighting_id]
        
        # 被攻击的玩家
        var player_scene_index = randi_range(0, player_scene_map.size() - 1)
        var player_scene: CharacterBody3D = player_scene_map.values()[player_scene_index]
        
        # C装置迎击检查
        if _check_c_device_intercept(skill, fighting_unit):
                var intercept_tween = create_tween()
                fight_hud.action_name_animation("C装置迎击!")
                intercept_tween.tween_interval(1.0)
                intercept_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)                                
        player_scene.under_fire(tween)
        
        # 计算伤害 (考虑防御状态)
        var skill_hurt = (skill.skill_strength * fighting_unit.battle_lv) as int
        skill_hurt = _apply_defend_reduction(player_scene.fight_id, skill_hurt)
        # 战车战模式 — 战车装甲减免伤害
        skill_hurt = _apply_tank_battle_damage(skill_hurt)
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

        # 施加状态效果
        _apply_skill_status(skill, fighting_unit_palyer)

        # 判断玩家是否存活
        if check_all_player_death():
                tween.parallel().tween_callback(self.all_player_death)
                return
        
        # 单位战斗结束 (处理状态效果)
        tween.parallel().tween_callback(_process_unit_turn_end.bind(fighting_id))
        
        
## 敌人远程单体攻击
## skill 技能
func enemy_remote_foe_one(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        SfxManager.play_sfx("attack_ranged")
        
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var fighting_unit = fighting_unit_map[fighting_id]
        
        # 被攻击的玩家
        var player_scene_index = randi_range(0, player_scene_map.size() - 1)
        var player_scene: CharacterBody3D = player_scene_map.values()[player_scene_index]
        
        # C装置迎击检查 (远程攻击可被迎击)
        if _check_c_device_intercept(skill, fighting_unit):
                var intercept_tween = create_tween()
                fight_hud.action_name_animation("C装置迎击!")
                intercept_tween.tween_interval(1.0)
                intercept_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 远程攻击动画 (敌人闪烁, 与近战时序略有差异)
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)
        player_scene.under_fire(tween)
        
        # 计算伤害 (考虑防御状态)
        var skill_hurt = (skill.skill_strength * fighting_unit.battle_lv) as int
        skill_hurt = _apply_defend_reduction(player_scene.fight_id, skill_hurt)
        # 战车战模式 — 战车装甲减免伤害
        skill_hurt = _apply_tank_battle_damage(skill_hurt)
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

        # 施加状态效果
        _apply_skill_status(skill, fighting_unit_palyer)

        # 判断玩家是否存活
        if check_all_player_death():
                tween.parallel().tween_callback(self.all_player_death)
                return
        
        # 单位战斗结束 (处理状态效果)
        tween.parallel().tween_callback(_process_unit_turn_end.bind(fighting_id))


## 敌人近战全体攻击
## skill 技能
func enemy_melee_foe_all(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var fighting_unit = fighting_unit_map[fighting_id]
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)
        
        # 摄像机运动
        if player_scene_map.size() > 0:
                fight_camera_3d.look_at_target(player_scene_map.values()[0].global_position, 0.1)
        
        # 对所有玩家造成伤害
        var total_hurt = 0
        for player_scene in player_scene_map.values():
                var skill_hurt = (skill.skill_strength * fighting_unit.battle_lv) as int
                skill_hurt = _apply_defend_reduction(player_scene.fight_id, skill_hurt)
                # 战车战模式 — 战车装甲减免伤害
                skill_hurt = _apply_tank_battle_damage(skill_hurt)
                total_hurt += skill_hurt
                player_scene.under_fire(tween)
                player_scene.under_fire_label(skill_hurt, tween)
                
                var fighting_unit_palyer = fighting_unit_map[player_scene.fight_id]
                fighting_unit_palyer.current_health -= skill_hurt
                if fighting_unit_palyer.current_health <= 0:
                        fighting_unit_palyer.current_health = 0
                tween.parallel().tween_callback(player_scene.set_fight_player_data.bind(fighting_unit_palyer))
                # 施加状态效果
                _apply_skill_status(skill, fighting_unit_palyer)
        
        # 更新玩家信息 (以第一个玩家为代表)
        if player_scene_map.size() > 0:
                var first_player = player_scene_map.values()[0]
                var first_unit = fighting_unit_map[first_player.fight_id]
                var health_info = player_info_container.find_child("HealthInfo")
                var health_label = "HP: " + str(first_unit.current_health) + " / " + str(first_unit.max_health)
                tween.parallel().tween_callback(health_bar.health_update.bind( - total_hurt))
                tween.parallel().tween_callback(health_info.set_text.bind(health_label))
        
        # 判断玩家是否存活
        if check_all_player_death():
                tween.parallel().tween_callback(self.all_player_death)
                return
        
        # 单位战斗结束 (处理状态效果)
        tween.parallel().tween_callback(_process_unit_turn_end.bind(fighting_id))


## 敌人远程全体攻击
## skill 技能
func enemy_remote_foe_all(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var fighting_unit = fighting_unit_map[fighting_id]
        
        # C装置迎击检查 (远程攻击可被迎击)
        if _check_c_device_intercept(skill, fighting_unit):
                var intercept_tween = create_tween()
                fight_hud.action_name_animation("C装置迎击!")
                intercept_tween.tween_interval(1.0)
                intercept_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)
        
        # 摄像机运动
        if player_scene_map.size() > 0:
                fight_camera_3d.look_at_target(player_scene_map.values()[0].global_position, 0.1)
        
        # 对所有玩家造成伤害
        var total_hurt = 0
        for player_scene in player_scene_map.values():
                var skill_hurt = (skill.skill_strength * fighting_unit.battle_lv) as int
                skill_hurt = _apply_defend_reduction(player_scene.fight_id, skill_hurt)
                # 战车战模式 — 战车装甲减免伤害
                skill_hurt = _apply_tank_battle_damage(skill_hurt)
                total_hurt += skill_hurt
                player_scene.under_fire(tween)
                player_scene.under_fire_label(skill_hurt, tween)
                
                var fighting_unit_palyer = fighting_unit_map[player_scene.fight_id]
                fighting_unit_palyer.current_health -= skill_hurt
                if fighting_unit_palyer.current_health <= 0:
                        fighting_unit_palyer.current_health = 0
                tween.parallel().tween_callback(player_scene.set_fight_player_data.bind(fighting_unit_palyer))
                # 施加状态效果
                _apply_skill_status(skill, fighting_unit_palyer)
        
        # 更新玩家信息 (以第一个玩家为代表)
        if player_scene_map.size() > 0:
                var first_player = player_scene_map.values()[0]
                var first_unit = fighting_unit_map[first_player.fight_id]
                var health_info = player_info_container.find_child("HealthInfo")
                var health_label = "HP: " + str(first_unit.current_health) + " / " + str(first_unit.max_health)
                tween.parallel().tween_callback(health_bar.health_update.bind( - total_hurt))
                tween.parallel().tween_callback(health_info.set_text.bind(health_label))
        
        # 判断玩家是否存活
        if check_all_player_death():
                tween.parallel().tween_callback(self.all_player_death)
                return
        
        # 单位战斗结束 (处理状态效果)
        tween.parallel().tween_callback(_process_unit_turn_end.bind(fighting_id))


## 敌人自我治疗
## skill 技能 (skill_strength为负值表示治疗量倍率)
func enemy_self_heal(skill):
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        
        var enemy_scene: CharacterBody3D = enemy_scene_map[fighting_id]
        var fighting_unit = fighting_unit_map[fighting_id]
        
        # 治疗量 = |skill_strength| * battle_lv
        var heal_amount = (abs(skill.skill_strength) * fighting_unit.battle_lv) as int
        fighting_unit.current_health = min(fighting_unit.max_health, fighting_unit.current_health + heal_amount)
        enemy_scene.fight_enemy_data = fighting_unit
        
        # 治疗动画 (复用敌人攻击动画)
        var tween = enemy_scene.create_tween()
        enemy_scene.attack_player(tween)
        
        # 摄像机运动
        fight_camera_3d.look_at_target(enemy_scene.global_position, 0.1)
        
        # 单位战斗结束 (处理状态效果)
        tween.parallel().tween_callback(_process_unit_turn_end.bind(fighting_id))


## C装置迎击检查
## skill 技能
## fighting_unit 攻击单位数据
## 返回true表示攻击被迎击 (跳过伤害)
func _check_c_device_intercept(skill, fighting_unit) -> bool:
        var active_tank = TankSystem.get_active_tank()
        if active_tank == null or active_tank.c_device.is_empty():
                return false
        var tank_data = {"c_device": active_tank.c_device, "speed": active_tank.speed}
        var attacker_power = int(skill.skill_strength * fighting_unit.battle_lv)
        return CDeviceSystem.try_intercept(tank_data, attacker_power)


## 防御减伤
## fight_id 目标单位id
## damage 原始伤害
## 返回减伤后的伤害 (防御状态减半)
func _apply_defend_reduction(fight_id, damage: int) -> int:
        if _defending_units.has(fight_id):
                return int(damage * 0.5)
        return damage


## 应用战车战数据到玩家单位 (在 _ready 中调用)
## fight_player_data 玩家单位数据 (会被修改)
func _apply_tank_battle_data(fight_player_data: Dictionary) -> void:
        var tank = TankSystem.get_active_tank()
        if tank == null:
                # 没有战车 — 退回步行模式
                _in_tank_battle = false
                GameData.game_flags["battle_in_tank"] = false
                return
        # 使用战车属性覆盖玩家单位
        fight_player_data["current_health"] = tank.current_hp
        fight_player_data["max_health"] = tank.max_hp
        fight_player_data["battle_lv"] = tank.attack
        fight_player_data["strength"] = tank.defense
        # 战车武器 (主炮单体远程)
        fight_player_data["weapons"] = {
                "attack_type": AttackData.Attack_Type.REMOTE,
                "attack_target": AttackData.Attack_Target.FOE_ONE,
                "battle_lv": int(tank.main_cannon.get("attack", tank.attack)),
        }
        # 战车专用技能 (主炮射击/机枪扫射/修理包)
        fight_player_data["skills"] = [AttackData.tank_cannon, AttackData.tank_machine_gun, AttackData.repair_kit]
        # 战车纹理 (如有配置)
        if not tank.sprite_path.is_empty():
                fight_player_data["albedo_texture_path"] = tank.sprite_path


## 检查战车战模式下的伤害处理
## damage 原始伤害
## 返回战车装甲减免后的实际伤害
## 注: 战车HP在 TankSystem.damage_tank 中扣减, 玩家单位HP由调用方扣减 (两者起始值相同, 保持同步)
func _apply_tank_battle_damage(damage: int) -> int:
        if not _in_tank_battle:
                return damage
        var tank = TankSystem.get_active_tank()
        if tank == null:
                return damage
        # 战车装甲减免伤害
        var actual_damage = max(1, damage - tank.defense / 2)
        TankSystem.damage_tank(tank.id, actual_damage)
        # 检查战车大破
        if tank.current_hp <= 0:
                _on_tank_destroyed()
        return actual_damage


## 战车大破处理
func _on_tank_destroyed() -> void:
        _in_tank_battle = false
        GameData.game_flags["battle_in_tank"] = false
        TankSystem.exit_tank()
        fight_hud.action_name_animation("战车大破!")
        # TODO: 战斗中切换为步行模式 (目前仅通知)


## 施加技能/武器状态效果
## source 技能或武器数据
## target_unit 目标单位数据
func _apply_skill_status(source, target_unit: Dictionary) -> void:
        if not source.has("status_effect"):
                return
        var status_name = source.get("status_effect", "")
        if status_name == null or status_name.is_empty():
                return
        var chance = float(source.get("status_chance", 1.0))
        if randf() > chance:
                return
        var effect_type = _get_status_effect_type(status_name)
        var duration = int(source.get("status_duration", 1))
        StatusEffectSystem.apply_status(target_unit, effect_type, duration, 1.0, fighting_id)


## 处理单位回合结束 (状态效果结算)
## fight_id 单位ID
func _process_unit_turn_end(fight_id: String) -> void:
        var unit = fighting_unit_map.get(fight_id)
        if unit == null:
                fight_speed_path.unit_fight_end(fight_id)
                fight_camera_3d.reset_camera_status()
                return
        
        var prev_health = unit.current_health
        StatusEffectSystem.process_turn_end(unit)
        var damage = prev_health - unit.current_health
        
        # 更新UI和检查死亡
        if unit.confirm_player:
                _update_player_health_ui(unit, -damage)
                var player_scene = player_scene_map.get(fight_id)
                if player_scene != null:
                        player_scene.set_fight_player_data(unit)
                        if damage > 0:
                                player_scene.under_fire_label(damage, create_tween())
                # 战车战模式 — 同步战车HP
                if _in_tank_battle:
                        var tank = TankSystem.get_active_tank()
                        if tank != null:
                                tank.current_hp = unit.current_health
                if check_all_player_death():
                        all_player_death()
                        return
        else:
                var enemy_scene = enemy_scene_map.get(fight_id)
                if enemy_scene != null:
                        enemy_scene.fight_enemy_data = unit
                        if damage > 0:
                                var hurt_label: Label3D = enemy_scene.hurt_label
                                hurt_label.text = str(damage)
                                var hurt_tween = create_tween()
                                hurt_tween.tween_property(hurt_label, "visible", true, 0.3)
                                hurt_tween.parallel().tween_property(hurt_label, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
                                hurt_tween.tween_property(hurt_label, "scale", Vector3.ONE, 0.1)
                                hurt_tween.tween_callback(hurt_label.set_visible.bind(false))
                if unit.current_health <= 0:
                        if enemy_scene != null:
                                enemy_scene.enemy_death(create_tween())
                        clear_fight_data(fight_id)
                        if check_all_enemy_death():
                                all_enemy_death()
                                return
        
        fight_speed_path.unit_fight_end(fight_id)
        fight_camera_3d.reset_camera_status()


## 状态效果名称转枚举值 (与StatusEffectSystem内部编号一致)
func _get_status_effect_type(status_name: String) -> int:
        match status_name:
                "POISON": return 0
                "PARALYZE": return 1
                "STUN": return 2
                "DEFENSE_UP": return 3
                "ATTACK_UP": return 4
                "SPEED_UP": return 5
                "BLEED": return 6
                _: return 0


## 玩家攻击
## attack_pointer_index 攻击的光标索引
func player_attck(attack_pointer_index):        
        var fight = self
        var fighting_id = fight.fighting_id
        var fight_unit = fight.fighting_unit_map[fighting_id]
        
        # 技能选择模式 → 使用技能
        if _skill_select_mode:
                _skill_select_mode = false
                fight.player_use_skill(_pending_skill_index, attack_pointer_index)
                return
        
        # 道具选择模式 → 使用道具
        if _item_select_mode:
                _item_select_mode = false
                fight.player_use_item(_pending_item_index, attack_pointer_index)
                return
        
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

        # 战车战模式 — 主炮射击 (消耗弹药)
        if _in_tank_battle:
                _player_tank_main_cannon_attack(attack_pointer_index, player_scene)
                SfxManager.play_sfx("tank_cannon")
                return

        # 白刃战模式
        SfxManager.play_sfx("attack_melee")

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

        # 施加武器状态效果
        if not enemy_death:
                _apply_skill_status(weapons, enemy_fight_unit)

        # 怪物死亡
        if enemy_death:
                enemy_scene.enemy_death(weapons_tween)
                weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                # 校验所有敌人死亡
                if check_all_enemy_death():
                        weapons_tween.tween_callback(self.all_enemy_death)
                        return
                
        # 玩家归位后处理回合结束 (状态效果结算)
        weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
        weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))


## 战车主炮攻击 (战车战模式, 消耗弹药)
## attack_pointer_index 敌人索引
## player_scene 玩家场景
func _player_tank_main_cannon_attack(attack_pointer_index: int, player_scene: CharacterBody3D) -> void:
        var tank = TankSystem.get_active_tank()
        if tank == null:
                # 战车丢失 — 切换回步行模式
                _in_tank_battle = false
                _end_player_turn(player_scene)
                return
        # 弹药检查
        if tank.current_ammo <= 0:
                fight_hud.action_name_animation("弹药耗尽!")
                var ammo_tween = create_tween()
                ammo_tween.tween_interval(1.0)
                ammo_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                ammo_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        # 消耗弹药
        tank.current_ammo -= 1

        var enemy_scene: CharacterBody3D = enemy_scene_map.values()[attack_pointer_index]
        var enemy_fight_id = enemy_scene.fight_id
        var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
        var weapons_tween = player_scene.create_tween()
        player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
        fight_camera_3d.look_at_target(enemy_scene.global_position, 0.1)

        # 战车战伤害 = tank.attack + weapon_battle_lv - enemy.defense
        var fight_unit = fighting_unit_map[fighting_id]
        var weapon_battle_lv = int(fight_unit.weapons.get("battle_lv", 0))
        var enemy_defense = int(enemy_fight_unit.get("defense", enemy_fight_unit.get("strength", 0)))
        var damage = max(1, tank.attack + weapon_battle_lv - enemy_defense)
        var enemy_death = _damage_enemy(enemy_scene, enemy_fight_unit, damage, weapons_tween)

        # 施加武器状态效果
        if not enemy_death:
                _apply_skill_status(fight_unit.weapons, enemy_fight_unit)

        # 怪物死亡
        if enemy_death:
                enemy_scene.enemy_death(weapons_tween)
                weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                if check_all_enemy_death():
                        weapons_tween.tween_callback(self.all_enemy_death)
                        return

        # 玩家归位后处理回合结束 (状态效果结算)
        weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
        weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))


## 进入技能选择模式 (循环切换技能, 跳过普通攻击)
func _start_skill_selection() -> void:
        var fight_unit = fighting_unit_map[fighting_id]
        var skills = fight_unit.skills
        if skills.is_empty():
                return
        if enemy_scene_map.is_empty():
                return
        # 循环切换到下一个技能 (跳过索引0的普通攻击)
        _pending_skill_index += 1
        if _pending_skill_index >= skills.size():
                _pending_skill_index = 1
        if _pending_skill_index >= skills.size():
                _pending_skill_index = 0
        var skill = skills[_pending_skill_index]
        # 显示技能名字
        fight_hud.action_name_animation("技能: " + skill.skill_name)
        # 进入目标选择 (复用攻击目标选择流程)
        _skill_select_mode = true
        fight_menu.visible = false
        if fight_hud.pointer != null:
                fight_hud.pointer.visible = false
        var enemy_scene = enemy_scene_map.values()[0]
        fight_hud.attack_pointer.global_position = enemy_scene.global_position
        fight_hud.attack_pointer.global_position.z += 0.05
        fight_hud.attack_pointer.visible = true
        fight_hud.attack_pointer_index = 0


## 进入道具选择模式 (循环切换消耗品)
func _start_item_selection() -> void:
        # 获取所有消耗品
        var consumables: Array = []
        for item in GameData.inventory:
                if item.type == GameData.Item.ItemType.CONSUMABLE:
                        consumables.append(item)
        if consumables.is_empty():
                fight_hud.action_name_animation("没有可用道具!")
                return
        # 循环切换到下一个消耗品
        _pending_item_index += 1
        if _pending_item_index >= consumables.size():
                _pending_item_index = 0
        var item = consumables[_pending_item_index]
        # 显示道具名字
        fight_hud.action_name_animation("道具: " + item.name)
        # 进入目标选择 (复用攻击目标选择流程)
        _item_select_mode = true
        fight_menu.visible = false
        if fight_hud.pointer != null:
                fight_hud.pointer.visible = false
        # 根据道具类型选择初始目标
        var is_attack_item = item.has("damage")
        if is_attack_item:
                # 攻击类道具 → 选敌人
                if enemy_scene_map.is_empty():
                        _item_select_mode = false
                        fight_menu.visible = true
                        return
                var enemy_scene = enemy_scene_map.values()[0]
                fight_hud.attack_pointer.global_position = enemy_scene.global_position
                fight_hud.attack_pointer.global_position.z += 0.05
                fight_hud.attack_pointer.visible = true
                fight_hud.attack_pointer_index = 0
        else:
                # 治疗类道具 → 选自己 (不显示攻击光标, 直接使用)
                # 这里暂时也用攻击光标指向玩家, 简化实现
                var player_scene: CharacterBody3D = player_scene_map[fighting_id]
                fight_hud.attack_pointer.global_position = player_scene.global_position
                fight_hud.attack_pointer.global_position.z += 0.05
                fight_hud.attack_pointer.visible = true
                fight_hud.attack_pointer_index = 0


## 玩家使用技能
## skill_index 技能索引
## target_index 目标索引
func player_use_skill(skill_index: int, target_index: int) -> void:
        var fight_unit = fighting_unit_map[fighting_id]
        if skill_index < 0 or skill_index >= fight_unit.skills.size():
                return
        var skill = fight_unit.skills[skill_index]
        
        # 技能名字动画
        fight_hud.action_name_animation(skill.skill_name)
        
        var player_scene: CharacterBody3D = player_scene_map[fighting_id]
        
        # 防御技能
        if skill.has("defense_boost"):
                if not _defending_units.has(fighting_id):
                        _defending_units.append(fighting_id)
                _end_player_turn(player_scene)
                return
        
        # 治疗/辅助 (负值skill_strength 或 自身目标)
        if skill.skill_strength < 0 or skill.attack_target == attack_data.Attack_Target.SELF_ONE:
                var heal_amount = (abs(skill.skill_strength) * fight_unit.battle_lv) as int
                fight_unit.current_health = min(fight_unit.max_health, fight_unit.current_health + heal_amount)
                # 战车战模式 — 同步战车HP (修理包等)
                if _in_tank_battle:
                        var heal_tank = TankSystem.get_active_tank()
                        if heal_tank != null:
                                heal_tank.current_hp = min(heal_tank.max_hp, heal_tank.current_hp + heal_amount)
                _update_player_health_ui(fight_unit, heal_amount)
                var heal_tween = create_tween()
                heal_tween.tween_callback(player_scene.set_fight_player_data.bind(fight_unit))
                heal_tween.tween_interval(0.5)
                # 玩家归位后处理回合结束 (状态效果结算)
                heal_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                heal_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 攻击单体敌人
        if skill.attack_target == attack_data.Attack_Target.FOE_ONE:
                if enemy_scene_map.is_empty():
                        _end_player_turn(player_scene)
                        return
                # 战车战模式 — 主炮技能消耗弹药
                if _in_tank_battle and skill.get("skill_name", "") == AttackData.tank_cannon.skill_name:
                        var tank = TankSystem.get_active_tank()
                        if tank == null or tank.current_ammo <= 0:
                                fight_hud.action_name_animation("弹药耗尽!")
                                _end_player_turn(player_scene)
                                return
                        tank.current_ammo -= 1
                var target_idx = clamp(target_index, 0, enemy_scene_map.size() - 1)
                var enemy_scene: CharacterBody3D = enemy_scene_map.values()[target_idx]
                var enemy_fight_id = enemy_scene.fight_id
                var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
                var weapons_tween = player_scene.create_tween()
                player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
                fight_camera_3d.look_at_target(enemy_scene.global_position, 0.1)
                
                # 技能伤害 = skill_strength * battle_lv - 目标强度
                var skill_hurt = (skill.skill_strength * fight_unit.battle_lv) as int
                skill_hurt = max(1, skill_hurt - int(enemy_fight_unit.get("strength", 0)))
                var enemy_death = _damage_enemy(enemy_scene, enemy_fight_unit, skill_hurt, weapons_tween)
                
                # 施加状态效果
                if not enemy_death:
                        _apply_skill_status(skill, enemy_fight_unit)
                
                # 怪物死亡
                if enemy_death:
                        enemy_scene.enemy_death(weapons_tween)
                        weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                        if check_all_enemy_death():
                                weapons_tween.tween_callback(self.all_enemy_death)
                                return
                
                # 玩家归位后处理回合结束 (状态效果结算)
                weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 攻击全体敌人
        if skill.attack_target == attack_data.Attack_Target.FOE_ALL:
                var weapons_tween = player_scene.create_tween()
                var death_list: Array = []
                for enemy_scene in enemy_scene_map.values():
                        var enemy_fight_id = enemy_scene.fight_id
                        var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
                        player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
                        var skill_hurt = (skill.skill_strength * fight_unit.battle_lv) as int
                        skill_hurt = max(1, skill_hurt - int(enemy_fight_unit.get("strength", 0)))
                        var died = _damage_enemy(enemy_scene, enemy_fight_unit, skill_hurt, weapons_tween)
                        if not died:
                                _apply_skill_status(skill, enemy_fight_unit)
                        else:
                                death_list.append(enemy_scene)
                # 处理死亡的敌人
                for enemy_scene in death_list:
                        var enemy_fight_id = enemy_scene.fight_id
                        enemy_scene.enemy_death(weapons_tween)
                        weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                if check_all_enemy_death():
                        weapons_tween.tween_callback(self.all_enemy_death)
                        return
                # 玩家归位后处理回合结束 (状态效果结算)
                weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 其他目标类型 (队友单体/全体) — 简化为结束回合
        _end_player_turn(player_scene)


## 玩家使用道具
## item_index 消耗品索引 (在消耗品列表中的索引)
## target_index 目标索引
func player_use_item(item_index: int, target_index: int) -> void:
        # 获取所有消耗品
        var consumables: Array = []
        for item in GameData.inventory:
                if item.type == GameData.Item.ItemType.CONSUMABLE:
                        consumables.append(item)
        if item_index < 0 or item_index >= consumables.size():
                return
        var item = consumables[item_index]
        if item.count <= 0:
                fight_hud.action_name_animation("道具不足!")
                var player_scene: CharacterBody3D = player_scene_map[fighting_id]
                _end_player_turn(player_scene)
                return
        
        # 道具名字动画
        fight_hud.action_name_animation(item.name)
        
        var fight_unit = fighting_unit_map[fighting_id]
        var player_scene: CharacterBody3D = player_scene_map[fighting_id]
        
        # 治疗类道具 (有 heal_hp 属性)
        if item.has("heal_hp"):
                var heal_amount: int
                if item.heal_hp == -1:
                        # 完全恢复
                        heal_amount = fight_unit.max_health - fight_unit.current_health
                else:
                        heal_amount = item.heal_hp
                fight_unit.current_health = min(fight_unit.max_health, fight_unit.current_health + heal_amount)
                # 战车战模式 — 同步战车HP
                if _in_tank_battle:
                        var heal_tank = TankSystem.get_active_tank()
                        if heal_tank != null:
                                if item.heal_hp == -1:
                                        heal_tank.current_hp = heal_tank.max_hp
                                else:
                                        heal_tank.current_hp = min(heal_tank.max_hp, heal_tank.current_hp + heal_amount)
                _update_player_health_ui(fight_unit, heal_amount)
                var heal_tween = create_tween()
                heal_tween.tween_callback(player_scene.set_fight_player_data.bind(fight_unit))
                heal_tween.tween_interval(0.5)
                # 消耗道具
                _consume_item(item)
                # 玩家归位后处理回合结束 (状态效果结算)
                heal_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                heal_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 攻击类道具 - 单体 (有 damage 属性且 target 为 FOE_ONE)
        if item.has("damage") and item.get("target", "FOE_ONE") == "FOE_ONE":
                if enemy_scene_map.is_empty():
                        _end_player_turn(player_scene)
                        return
                var target_idx = clamp(target_index, 0, enemy_scene_map.size() - 1)
                var enemy_scene: CharacterBody3D = enemy_scene_map.values()[target_idx]
                var enemy_fight_id = enemy_scene.fight_id
                var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
                var weapons_tween = player_scene.create_tween()
                player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
                fight_camera_3d.look_at_target(enemy_scene.global_position, 0.1)
                
                # 道具伤害 = damage - 目标强度
                var item_damage = max(1, item.damage - int(enemy_fight_unit.get("strength", 0)))
                var enemy_death = _damage_enemy(enemy_scene, enemy_fight_unit, item_damage, weapons_tween)
                
                # 怪物死亡
                if enemy_death:
                        enemy_scene.enemy_death(weapons_tween)
                        weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                        if check_all_enemy_death():
                                _consume_item(item)
                                weapons_tween.tween_callback(self.all_enemy_death)
                                return
                
                # 消耗道具
                _consume_item(item)
                # 玩家归位后处理回合结束 (状态效果结算)
                weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 攻击类道具 - 全体 (有 damage 属性且 target 为 FOE_ALL)
        if item.has("damage") and item.get("target", "FOE_ONE") == "FOE_ALL":
                var weapons_tween = player_scene.create_tween()
                var death_list: Array = []
                for enemy_scene in enemy_scene_map.values():
                        var enemy_fight_id = enemy_scene.fight_id
                        var enemy_fight_unit = fighting_unit_map[enemy_fight_id]
                        player_scene.attack_enemy(enemy_scene, enemy_fight_unit, weapons_tween)
                        var item_damage = max(1, item.damage - int(enemy_fight_unit.get("strength", 0)))
                        var died = _damage_enemy(enemy_scene, enemy_fight_unit, item_damage, weapons_tween)
                        if died:
                                death_list.append(enemy_scene)
                # 处理死亡的敌人
                for enemy_scene in death_list:
                        var enemy_fight_id = enemy_scene.fight_id
                        enemy_scene.enemy_death(weapons_tween)
                        weapons_tween.tween_callback(clear_fight_data.bind(enemy_fight_id))
                if check_all_enemy_death():
                        _consume_item(item)
                        weapons_tween.tween_callback(self.all_enemy_death)
                        return
                # 消耗道具
                _consume_item(item)
                # 玩家归位后处理回合结束 (状态效果结算)
                weapons_tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                weapons_tween.tween_callback(_process_unit_turn_end.bind(fighting_id))
                return
        
        # 其他类型道具 — 简化为结束回合
        _consume_item(item)
        _end_player_turn(player_scene)


## 消耗一个道具
## item 要消耗的道具对象
func _consume_item(item) -> void:
        item.count -= 1
        if item.count <= 0:
                GameData.inventory.erase(item)
        GameData.inventory_changed.emit()


## 对敌人造成伤害并播放伤害动画
## enemy_scene 敌人场景
## enemy_fight_unit 敌人单位数据
## damage 伤害值
## tween 补间动画对象
## 返回是否死亡
func _damage_enemy(enemy_scene, enemy_fight_unit: Dictionary, damage: int, tween) -> bool:
        enemy_fight_unit.current_health -= damage
        if enemy_fight_unit.current_health <= 0:
                enemy_fight_unit.current_health = 0
        enemy_scene.fight_enemy_data = enemy_fight_unit
        
        # 伤害数字动画
        var hurt_label: Label3D = enemy_scene.hurt_label
        var enemy_global_position = enemy_scene.global_position
        hurt_label.global_position = enemy_global_position
        var hurt_label_position = hurt_label.position
        hurt_label.text = str(damage)
        var hurt_label_position_tween = Vector3(hurt_label_position)
        hurt_label_position_tween.x -= 0.05
        hurt_label_position_tween.y += 0.05
        tween.tween_property(hurt_label, "visible", true, 0.5)
        tween.parallel().tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
        tween.parallel().tween_property(hurt_label, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
        hurt_label_position_tween.x -= 0.05
        hurt_label_position_tween.y -= 0.05
        tween.tween_property(hurt_label, "position", hurt_label_position_tween, 0.5)
        tween.parallel().tween_property(hurt_label, "scale", Vector3.ONE, 0.1)
        tween.tween_callback(hurt_label.set_visible.bind(false))
        return enemy_fight_unit.current_health <= 0


## 更新玩家HP信息UI
## fight_unit 玩家单位数据
## delta HP变化 (负值为伤害, 正值为治疗)
func _update_player_health_ui(fight_unit: Dictionary, delta: int) -> void:
        var current_health = str(fight_unit.current_health)
        var max_health = str(fight_unit.max_health)
        var health_info = player_info_container.find_child("HealthInfo")
        var health_label = "HP: " + current_health + " / " + max_health
        health_bar.health_update(delta)
        if health_info != null:
                health_info.text = health_label


## 结束玩家回合 (无动画的备用流程)
## player_scene 玩家场景
func _end_player_turn(player_scene: CharacterBody3D) -> void:
        var tween = create_tween()
        tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
        tween.tween_callback(_process_unit_turn_end.bind(fighting_id))


## 玩家防御 (减半下回合受到的伤害)
func player_defend() -> void:
        fight_hud.action_name_animation("防御")
        if not _defending_units.has(fighting_id):
                _defending_units.append(fighting_id)
        # 隐藏菜单
        fight_menu.visible = false
        if fight_hud.pointer != null:
                fight_hud.pointer.visible = false
        var player_scene: CharacterBody3D = player_scene_map[fighting_id]
        var tween = create_tween()
        tween.tween_interval(0.5)
        # 玩家归位后处理回合结束 (状态效果结算)
        tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
        tween.tween_callback(_process_unit_turn_end.bind(fighting_id))


## 玩家逃跑 (70%成功率)
func player_flee() -> void:
        fight_hud.action_name_animation("逃跑")
        # 隐藏菜单
        fight_menu.visible = false
        if fight_hud.pointer != null:
                fight_hud.pointer.visible = false
        var player_scene: CharacterBody3D = player_scene_map[fighting_id]
        var tween = create_tween()
        tween.tween_interval(0.5)
        if randf() <= 0.7:
                # 逃跑成功
                tween.tween_callback(self._flee_battle)
        else:
                # 逃跑失败
                fight_hud.action_name_animation("逃跑失败!")
                tween.tween_property(player_scene, "position", player_scene.fight_originally_position, 0.3)
                tween.tween_callback(_process_unit_turn_end.bind(fighting_id))


## 逃离战斗 (返回之前的区域)
func _flee_battle() -> void:
        audio_stream_player.stream = load("res://music/sound_effect/select.wav")
        audio_stream_player.play()
        fight_hud.visible = false
        fight_speed_path.fight_stop()
        # 重置随机遇敌计数
        _reset_encounter_counter()
        # 返回之前的区域
        await get_tree().create_timer(1.0).timeout
        GameFlow.enter_city()


## 清除战斗数据
func clear_fight_data(fight_id):
        fighting_unit_map.erase(fight_id)
        enemy_scene_map.erase(fight_id)
        player_scene_map.erase(fight_id)
        fight_speed_path.unit_fight_death(fight_id)

## 重置随机遇敌计数
func _reset_encounter_counter() -> void:
        # 在场景树中查找 RandomEncounter 节点并重置
        var root = get_tree().root
        for i in range(root.get_child_count()):
                var child = root.get_child(i)
                _find_and_reset_encounter(child)

func _find_and_reset_encounter(node: Node) -> void:
        if node.has_method("reset_encounter_counter"):
                node.reset_encounter_counter()
                print("[Fight] 随机遇敌计数已重置")
                return
        for i in range(node.get_child_count()):
                _find_and_reset_encounter(node.get_child(i))

                
## 检测所有敌人死亡
func check_all_enemy_death()-> bool:
        return enemy_scene_map.values().all(func(value):
                        return value.fight_enemy_data.current_health <= 0)
        
        
## 所有敌人死亡
func all_enemy_death():
        # 清除所有单位的状态效果
        for unit in fighting_unit_map.values():
                StatusEffectSystem.clear_all_statuses(unit)

        # 播放战斗胜利音效
        BgmManager.play_victory_bgm()
        SfxManager.play_sfx("victory")

        # 暂停战斗进度
        fight_hud.visible = false
        fight_speed_path.fight_stop()

        # 获得经验 金钱 — 使用 LevelUpSystem 计算
        var enemy_level_sum = 0
        var enemy_count = 0
        var has_bounty = false
        var defeated_bounty_id = ""
        var defeated_bounty_name = ""
        var bounty_reward = 0
        
        for unit in fighting_unit_map.values():
                if not unit.confirm_player:
                        enemy_level_sum += int(unit.get("battle_lv", 5))
                        enemy_count += 1
                        # 检查敌人是否是赏金首
                        if unit.get("is_bounty", false):
                                has_bounty = true
                                defeated_bounty_id = unit.get("bounty_id", "")
                                bounty_reward = unit.get("bounty_reward", 0)
                                if BountySystem.bounties.has(defeated_bounty_id):
                                        defeated_bounty_name = BountySystem.bounties[defeated_bounty_id].name
        
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
        
        # 处理赏金首击败
        if has_bounty and not defeated_bounty_id.is_empty():
                # 调用 BountySystem.defeat_bounty 更新状态
                BountySystem.defeat_bounty(defeated_bounty_id)
                # 额外发放赏金奖励金币
                var bounty = BountySystem.bounties.get(defeated_bounty_id, null)
                if bounty != null:
                        earn_exp += bounty.min_level * 20
                        earn_coins += bounty.reward
                        print("[Fight] 击败赏金首: " + bounty.name + " 获得赏金: " + str(bounty.reward) + "G")
                else:
                        earn_coins += bounty_reward
                        print("[Fight] 击败赏金首，获得赏金: " + str(bounty_reward) + "G")
        elif not boss_id.is_empty():
                # 兼容旧的 BOSS战标记方式
                if BountySystem.bounties.has(boss_id):
                        BountySystem.defeat_bounty(boss_id)
                        var bounty = BountySystem.bounties[boss_id]
                        earn_exp += bounty.min_level * 20
                        earn_coins += bounty.reward
                        print("[Fight] 击败赏金首: " + bounty.name + " 获得赏金: " + str(bounty.reward))
                        defeated_bounty_id = boss_id
                        defeated_bounty_name = bounty.name
                        has_bounty = true
        
        # 清除BOSS战标记
        if GameData.game_flags.has("boss_battle"):
                GameData.game_flags.erase("boss_battle")

        # 给玩家队伍添加金币和经验
        GameData.coins += earn_coins
        for member in GameData.party:
                LevelUpSystem.add_exp(member, earn_exp)

        # 更新任务进度
        QuestSystem.update_objective("defeat_enemies", "any", enemy_count)
        if has_bounty and not defeated_bounty_id.is_empty():
                QuestSystem.update_objective("defeat_bounty", defeated_bounty_id, 1)

        # 记录战斗胜利
        GameData.encounter_count += 1
        GameData.defeat_count += fighting_unit_map.values().filter(func(u): return not u.confirm_player).size()
        GameData.game_flags["battles_won"] = int(GameData.game_flags.get("battles_won", 0)) + 1

        # 检查成就
        AchievementSystem.check_battle_achievements()
        AchievementSystem.check_coins_achievements(GameData.coins)

        # 显示战斗结算
        var settlement_data: Dictionary = {}
        settlement_data["earn_exp"] = earn_exp
        settlement_data["earn_coins"] = earn_coins
        settlement_data["players_data"] = fighting_unit_map.values()
        settlement_data["is_bounty_battle"] = has_bounty
        settlement_data["bounty_name"] = defeated_bounty_name
        for fighting_unit in fighting_unit_map.values():
                fighting_unit["earn_exp"] = earn_exp
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
        # 清除所有单位的状态效果
        for unit in fighting_unit_map.values():
                StatusEffectSystem.clear_all_statuses(unit)

        BgmManager.stop_bgm()
        BgmManager.play_defeat_bgm()
        SfxManager.play_sfx("defeat")

        # 暂停战斗进度
        fight_hud.visible = false
        fight_speed_path.fight_stop()

        # 等待2秒让玩家看到失败画面
        await get_tree().create_timer(2.0).timeout

        # 应用死亡惩罚：丢失30%金币（至少保留100G），队伍和战车半血复活
        var lost_coins := GameData.apply_death_penalty()
        GameData.respawn_party()
        GameData.respawn_tanks()

        # 打印死亡惩罚信息
        print("[Fight] 战斗失败！损失 %d G，队伍和战车已半血复活" % lost_coins)

        # 等待1秒显示惩罚信息
        await get_tree().create_timer(1.0).timeout

        # 重置随机遇敌计数
        _reset_encounter_counter()

        # 停止失败BGM，返回奥多市
        BgmManager.stop_bgm()
        BgmManager.play_area_bgm("aoduo")
        SceneTransitionManager.return_to_nearest_city()
