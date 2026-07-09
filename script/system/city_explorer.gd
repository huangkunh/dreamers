extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市探索模式：随机遇敌、暂停菜单、战车切换、NPC交互、商店、对话

const PAUSE_MENU_SCENE := preload("res://scene/ui/pause_menu.tscn")
const TANK_HUD_SCENE := preload("res://scene/ui/tank_hud.tscn")
const DIALOG_SCENE := preload("res://scene/ui/dialog_system.tscn")
const SHOP_SCENE := preload("res://scene/ui/shop_system.tscn")
const DIALOGUE_BOX_SCENE := preload("res://scenes/ui/dialogue_box.tscn")
const GAME_HUD_SCENE := preload("res://scenes/ui/game_hud.tscn")

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var player: CharacterBody3D = $Player

var _encounter_system: Node
var _pause_menu: Control
var _tank_hud: Control
var _dialog_system: Control
var _shop_system: Control
## DialogueManager 对话框 (新系统)
var _dialogue_box: Control
## 游戏内HUD
var _game_hud: Control
var _in_tank: bool = false
var _nearby_npc: Node3D = null
var area_id: String = "aoduo"

func _ready() -> void:
        # 确保背景音乐播放
        if audio_stream_player and not audio_stream_player.playing:
                audio_stream_player.play()

        # 设置游戏状态
        GameFlow.current_state = GameFlow.GameState.CITY

        # 设置区域ID
        area_id = GameManager.get_current_area()

        # 将玩家加入player组 (供NPC交互检测)
        if player:
                player.add_to_group("player")

        # 添加随机遇敌系统到玩家
        if player:
                _encounter_system = load("res://script/system/random_encounter.gd").new()
                _encounter_system.encounter_rate = 0.015
                _encounter_system.min_steps_between_encounters = 8
                _encounter_system.area_id = area_id
                _encounter_system.encounter_triggered.connect(_on_encounter)
                player.add_child(_encounter_system)

        # 实例化暂停菜单
        _pause_menu = PAUSE_MENU_SCENE.instantiate()
        add_child(_pause_menu)

        # 实例化战车HUD
        _tank_hud = TANK_HUD_SCENE.instantiate()
        add_child(_tank_hud)

        # 实例化对话系统
        _dialog_system = DIALOG_SCENE.instantiate()
        add_child(_dialog_system)

        # 实例化商店系统
        _shop_system = SHOP_SCENE.instantiate()
        add_child(_shop_system)

        # 实例化 DialogueManager 对话框 (新系统)
        _dialogue_box = DIALOGUE_BOX_SCENE.instantiate()
        add_child(_dialogue_box)
        DialogueManager.set_dialogue_box(_dialogue_box)

        # 实例化游戏内HUD
        _game_hud = GAME_HUD_SCENE.instantiate()
        add_child(_game_hud)
        _game_hud.show_hud()
        _game_hud.set_area_name("奥多市")

        # 初始化战车
        var owned = TankSystem.get_owned_tanks()
        if owned.size() > 0 and not _in_tank:
                pass

        print("[CityExplorer] 区域: %s, 遇敌率: %.3f" % [area_id, _encounter_system.encounter_rate])

func _process(delta: float) -> void:
        # 更新游戏时间
        GameData.play_time += delta

func _unhandled_input(event: InputEvent) -> void:
        # DialogueManager 对话进行中时，按确认键推进对话
        if DialogueManager.is_active():
                if event.is_action_pressed("ui_accept"):
                        DialogueManager.advance()
                return

        if event.is_action_pressed("menu"):
                if _pause_menu and not _dialog_system.visible and not _shop_system.visible:
                        _pause_menu.toggle()
        elif event.is_action_pressed("tank_toggle"):
                _toggle_tank()
        elif event.is_action_pressed("interact"):
                if _nearby_npc and not _pause_menu.visible and not _dialog_system.visible:
                        _interact_with_npc(_nearby_npc)
        elif event.is_action_pressed("ui_cancel"):
                if _shop_system and _shop_system.visible:
                        _shop_system.close_shop()
                elif _dialog_system and _dialog_system.visible:
                        pass

## NPC交互
func _interact_with_npc(npc: Node3D) -> void:
        var npc_id: String = npc.get_meta("npc_id", "")
        var npc_area: String = npc.get_meta("area_id", area_id)
        var shop_id: String = npc.get_meta("shop_id", "")

        if shop_id != "" and not shop_id.is_empty():
                # 打开商店
                var shop_items = ShopData.get_shop_items(shop_id)
                _shop_system.open_shop(npc.get_meta("display_name", "商店"), shop_items)
        else:
                # 打开对话
                var npc_data = NPCData.get_npc_dialog(npc_area, npc_id)
                if npc_data.is_empty():
                        _dialog_system.show_dialog(npc.get_meta("display_name", "???"), "...")
                        return

                var dialogs: Array = npc_data.get("dialogs", [])
                if dialogs.is_empty():
                        _dialog_system.show_dialog(npc.get_meta("display_name", "???"), "...")
                        return

                # 将对话加入队列
                var dialog_queue: Array = []
                for d in dialogs:
                        dialog_queue.append({"name": d.get("name", ""), "text": d.get("text", "")})
                _dialog_system.show_dialog_queue(dialog_queue)

## 设置附近NPC
func set_nearby_npc(npc: Node3D) -> void:
        _nearby_npc = npc

## 清除附近NPC
func clear_nearby_npc() -> void:
        _nearby_npc = null

## 切换上下战车
func _toggle_tank() -> void:
        if _in_tank:
                TankSystem.exit_tank()
                _in_tank = false
                if player:
                        player.movement_speed = 200
                print("[CityExplorer] 下车，步行模式")
        else:
                var owned = TankSystem.get_owned_tanks()
                if owned.size() > 0:
                        TankSystem.enter_tank(owned[0].id)
                        _in_tank = true
                        if player:
                                player.movement_speed = 400
                        print("[CityExplorer] 上车，战车模式")
                else:
                        print("[CityExplorer] 没有战车")

## 遇敌回调
func _on_encounter() -> void:
        print("[CityExplorer] 进入战斗! 区域: " + area_id)
        if audio_stream_player:
                audio_stream_player.stop()
        GameData.game_flags["battle_area"] = area_id
        GameFlow.enter_battle()
