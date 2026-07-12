extends Node3D
## 蚂蚁巢穴 (AntNest)
## 第二个迷宫关卡，包含:
## - 地下蚁穴环境
## - 蚁群随机遇敌 (高频率)
## - BOSS战 (蚁后 - 赏金首b03)
## - 战斗后奖励

const NPC_SCENE := preload("res://scenes/characters/npc/npc.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")
const TREASURE_CHEST_SCRIPT := preload("res://scripts/components/treasure_chest.gd")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

## 随机遇敌系统
var _encounter_system: Node
## 是否已击败BOSS
var _boss_defeated: bool = false
## 入口NPC (探险者)
var _entry_npc: CharacterBody3D
## BOSS触发器
var _boss_trigger: Area3D
## 游戏内HUD
var _game_hud: Control

func _ready() -> void:
        # 设置游戏状态
        GameFlow.current_state = GameFlow.GameState.CITY
        GameData.game_flags["current_area"] = "ant_nest"

        # 播放区域BGM
        BgmManager.play_area_bgm("ant_nest")

        # 将玩家加入player组
        if player:
                player.add_to_group("player")

        # 添加随机遇敌系统 (蚁穴遇敌率更高)
        if player:
                _encounter_system = load("res://scripts/system/random_encounter.gd").new()
                _encounter_system.encounter_rate = 0.025  # 2.5% 每步
                _encounter_system.min_steps_between_encounters = 4
                _encounter_system.area_id = "ant_nest"
                _encounter_system.encounter_triggered.connect(_on_encounter)
                player.add_child(_encounter_system)

        # 创建入口NPC
        _create_entry_npc()

        # 创建BOSS触发区域
        _create_boss_trigger()

        # 创建宝箱
        _create_chests()

        # 实例化游戏内HUD
        _game_hud = GAME_HUD_SCENE.instantiate()
        add_child(_game_hud)
        _game_hud.show_hud()
        _game_hud.set_area_name("蚂蚁巢穴")

        # 检查BOSS是否已被击败
        if BountySystem.bounties.has("b03_ant_queen"):
                var bounty = BountySystem.bounties["b03_ant_queen"]
                if bounty.status == BountySystem.BountyStatus.CLAIMED:
                        _boss_defeated = true
                        print("[AntNest] BOSS已被击败")

func _input(event: InputEvent) -> void:
        if event is InputEventKey and event.pressed:
                match event.keycode:
                        KEY_ESCAPE:
                                GameFlow.change_scene("world_map")

## 创建入口NPC (受伤的探险者)
func _create_entry_npc() -> void:
        _entry_npc = NPC_SCENE.instantiate()
        _entry_npc.npc_id = "injured_explorer"
        _entry_npc.npc_area = "ant_nest"
        _entry_npc.display_name = "受伤的探险者"
        _entry_npc.position = Vector3(0, 0, 5)
        add_child(_entry_npc)

## 创建BOSS触发区域
func _create_boss_trigger() -> void:
        if _boss_defeated:
                return

        _boss_trigger = Area3D.new()
        _boss_trigger.position = Vector3(0, 0, -25)

        var collision := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = Vector3(3, 3, 3)
        collision.shape = box
        _boss_trigger.add_child(collision)

        # 可视化标记 (紫色 - 蚁后)
        var mesh := BoxMesh.new()
        mesh.size = Vector3(3, 3, 3)
        var mi := MeshInstance3D.new()
        mi.mesh = mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color(0.6, 0.2, 0.8, 0.3)
        mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
        mi.material_override = mat
        _boss_trigger.add_child(mi)

        _boss_trigger.body_entered.connect(_on_boss_trigger_entered)
        add_child(_boss_trigger)

## 创建宝箱
func _create_chests() -> void:
        # 宝箱1: 金币
        var chest1 := Area3D.new()
        chest1.set_script(TREASURE_CHEST_SCRIPT)
        chest1.chest_id = "antnest_chest_1"
        chest1.reward_type = 0  # COINS
        chest1.reward_value = "200"
        chest1.display_name = "蚁穴宝箱"
        chest1.position = Vector3(-10, 0, -12)
        add_child(chest1)

        # 宝箱2: 全恢复
        var chest2 := Area3D.new()
        chest2.set_script(TREASURE_CHEST_SCRIPT)
        chest2.chest_id = "antnest_chest_2"
        chest2.reward_type = 4  # HEAL
        chest2.display_name = "蚁后补给"
        chest2.position = Vector3(10, 0, -20)
        add_child(chest2)

## BOSS触发
func _on_boss_trigger_entered(body: Node) -> void:
        if body.is_in_group("player") and not _boss_defeated:
                print("[AntNest] 触发蚁后BOSS战!")
                GameData.game_flags["boss_battle"] = "b03_ant_queen"
                GameData.game_flags["battle_area"] = "ant_nest"
                GameFlow.enter_battle()

## 遇敌回调
func _on_encounter() -> void:
        print("[AntNest] 蚂蚁袭击!")
        BgmManager.stop_bgm()
        GameData.game_flags["battle_area"] = "ant_nest"
        GameFlow.enter_battle()
