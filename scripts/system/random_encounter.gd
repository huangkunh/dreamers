extends Node
## 随机遇敌系统 (RandomEncounter)
## 管理城市/荒野中的随机战斗触发
## 附加到玩家节点或场景管理器上

## 遇敌触发信号
signal encounter_triggered

## 每步遇敌概率 (0-1)
@export var encounter_rate: float = 0.02
## 最小步数间隔 (避免连续遇敌)
@export var min_steps_between_encounters: int = 5
## 遇敌区域名称 (决定敌人种类)
@export var area_id: String = "aoduo"

## 上次遇敌后的步数
var _steps_since_encounter: int = 0
## 上次位置
var _last_pos: Vector3 = Vector3.ZERO
## 累计移动距离
var _accumulated_distance: float = 0.0
## 每步距离阈值
const STEP_THRESHOLD: float = 1.0

var _parent_node: Node

func _ready() -> void:
        _parent_node = get_parent()
        if _parent_node is Node3D:
                _last_pos = _parent_node.position

func _process(_delta: float) -> void:
        if not _parent_node is Node3D:
                return

        # 计算移动距离
        var current_pos: Vector3 = _parent_node.position
        var distance = current_pos.distance_to(_last_pos)
        if distance > 0.01:
                _accumulated_distance += distance
                _last_pos = current_pos

                # 每移动 STEP_THRESHOLD 距离算一步
                while _accumulated_distance >= STEP_THRESHOLD:
                        _accumulated_distance -= STEP_THRESHOLD
                        _step_taken()

## 每步检查是否遇敌
func _step_taken() -> void:
        _steps_since_encounter += 1
        if _steps_since_encounter < min_steps_between_encounters:
                return

        if randf() < encounter_rate:
                _trigger_encounter()

## 触发遇敌
func _trigger_encounter() -> void:
        _steps_since_encounter = 0
        encounter_triggered.emit()
        print("[RandomEncounter] 触发随机战斗! 区域: " + area_id)
        # 设置战斗区域
        GameData.game_flags["battle_area"] = area_id
        # 保存战斗模式 (战车或步行)
        var active_tank = TankSystem.get_active_tank()
        GameData.game_flags["battle_in_tank"] = active_tank != null
        
        # 检查是否遇到赏金首
        var bounty_id = BountySystem.try_trigger_bounty_encounter(area_id)
        if not bounty_id.is_empty():
                GameData.game_flags["boss_battle"] = bounty_id
                var bounty_name = BountySystem.bounties[bounty_id].name
                print("[RandomEncounter] 遭遇赏金首! " + bounty_name)
                # 播放特殊提示音和提示文字
                _show_bounty_encounter_notification(bounty_name)
        else:
                # 清除可能存在的旧BOSS战标记
                if GameData.game_flags.has("boss_battle"):
                        GameData.game_flags.erase("boss_battle")
        
        # 通过 GameFlow 进入战斗
        GameFlow.enter_battle()

## 显示赏金首遭遇通知
func _show_bounty_encounter_notification(bounty_name: String) -> void:
        # 播放特殊提示音
        var sfx_path = "res://music/sound_effect/enter.wav"
        var sfx = load(sfx_path)
        if sfx != null:
                var player = AudioStreamPlayer.new()
                player.stream = sfx
                get_tree().root.add_child(player)
                player.play()
                player.finished.connect(player.queue_free)
        print("[RandomEncounter] ⚠ 遭遇赏金首: " + bounty_name + "!")

## 重置遇敌计数 (战斗结束后调用)
func reset_encounter_counter() -> void:
        _steps_since_encounter = 0
