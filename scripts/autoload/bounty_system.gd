extends Node
## 赏金首系统 (BountySystem)
## Metal Max 系列标志性的悬赏目标系统
## 管理赏金首数据、状态和奖励

signal bounty_defeated(bounty_id: String)
signal bounty_claimed(bounty_id: String, reward: int)

## 赏金首状态
enum BountyStatus {
        AVAILABLE,     ## 可接取/未击败
        DEFEATED,      ## 已击败，未领赏
        CLAIMED,       ## 已领赏
        LOCKED,        ## 未解锁
}

## 赏金首数据
class BountyTarget:
        var id: String
        var name: String
        var description: String
        var reward: int              ## 赏金金额
        var enemy_id: String         ## 对应的敌人ID
        var enemy_count: int = 1     ## 敌人数量
        var difficulty: int = 1      ## 难度等级 1-5
        var status: int = BountyStatus.AVAILABLE
        var location: String         ## 出没地点
        var min_level: int = 1       ## 建议最低等级

## 所有赏金首
var bounties: Dictionary = {}

## 区域-赏金首映射
## key: 区域ID, value: 该区域出现的赏金首ID数组
var area_bounty_map: Dictionary = {
        "factory": ["b01_rock_butterfly"],
        "wasteland": ["b02_mad_tank", "b05_desert_wolf"],
        "ant_nest": ["b03_ant_queen"],
        "ancient_ruins": ["b04_amorphous", "b07_noah_avatar"],
}

## 赏金首遭遇概率 (5%)
const BOUNTY_ENCOUNTER_RATE: float = 0.05

func _ready() -> void:
        _init_bounties()

## 初始化赏金首数据
func _init_bounties() -> void:
        _register_bounty("b01_rock_butterfly", "巨蝶", "出现在奥多周边的变异蝴蝶，体型巨大，翅膀上的鳞粉有剧毒。", 500, "b01_rock_butterfly", 1, 2, "奥多荒野", 1)
        _register_bounty("b02_mad_tank", "失控坦克", "旧文明留下的自动战斗坦克，仍在废墟中巡逻。火力极强。", 1500, "b02_mad_tank", 1, 4, "废弃工厂", 5)
        _register_bounty("b03_ant_queen", "蚁后", "巨大蚂蚁群落的母体，位于地下巢穴深处。", 800, "b03_ant_queen", 3, 3, "蚂蚁巢穴", 3)
        _register_bounty("b04_amorphous", "不定形", "神秘的液态生命体，能吞噬一切。", 3000, "b04_amorphous", 1, 5, "古代遗迹", 15)
        _register_bounty("b05_desert_wolf", "沙漠之狼", "在荒野游荡的变异巨狼，速度极快，牙尖爪利。", 600, "b05_desert_wolf", 2, 2, "沙漠公路", 2)

        # 隐藏赏金首 (需要解锁条件)
        _register_bounty("b06_red_ribcock", "红色公鸡", "传说中的变异公鸡，据说没人见过它还活着回来。", 5000, "e02_cannon", 2, 5, "未知", 15)
        bounties["b06_red_ribcock"].status = BountyStatus.LOCKED

        # 最终BOSS赏金首 (需要解锁条件)
        _register_bounty("b07_noah_avatar", "诺亚化身", "古代遗迹深处的超级计算机诺亚的化身。它声称大破坏是为了拯救人类。", 5000, "b07_noah_avatar", 1, 5, "古代遗迹最深处", 30)
        bounties["b07_noah_avatar"].status = BountyStatus.LOCKED

## 注册赏金首
func _register_bounty(bid: String, bname: String, bdesc: String, reward: int, enemy_id: String, count: int, difficulty: int, location: String, min_level: int) -> void:
        var bounty := BountyTarget.new()
        bounty.id = bid
        bounty.name = bname
        bounty.description = bdesc
        bounty.reward = reward
        bounty.enemy_id = enemy_id
        bounty.enemy_count = count
        bounty.difficulty = difficulty
        bounty.location = location
        bounty.min_level = min_level
        bounties[bid] = bounty

## 获取可接取的赏金首列表
func get_available_bounties() -> Array:
        var result := []
        for bounty in bounties.values():
                if bounty.status == BountyStatus.AVAILABLE:
                        result.append(bounty)
        return result

## 获取已击败未领赏的赏金首
func get_defeated_bounties() -> Array:
        var result := []
        for bounty in bounties.values():
                if bounty.status == BountyStatus.DEFEATED:
                        result.append(bounty)
        return result

## 标记赏金首为已击败
func defeat_bounty(bounty_id: String) -> void:
        if not bounties.has(bounty_id):
                return
        var bounty = bounties[bounty_id]
        if bounty.status == BountyStatus.AVAILABLE:
                bounty.status = BountyStatus.DEFEATED
                bounty_defeated.emit(bounty_id)
                print("[BountySystem] 赏金首 %s 已被击败! 前往公会领取 %dG 赏金" % [bounty.name, bounty.reward])

## 领取赏金
func claim_bounty(bounty_id: String) -> int:
        if not bounties.has(bounty_id):
                return 0
        var bounty = bounties[bounty_id]
        if bounty.status != BountyStatus.DEFEATED:
                return 0
        bounty.status = BountyStatus.CLAIMED
        GameData.coins += bounty.reward
        bounty_claimed.emit(bounty_id, bounty.reward)
        print("[BountySystem] 领取赏金: %s +%dG" % [bounty.name, bounty.reward])
        return bounty.reward

## 解锁赏金首
func unlock_bounty(bounty_id: String) -> void:
        if not bounties.has(bounty_id):
                return
        var bounty = bounties[bounty_id]
        if bounty.status == BountyStatus.LOCKED:
                bounty.status = BountyStatus.AVAILABLE
                print("[BountySystem] 新赏金首解锁: %s" % bounty.name)

## 检查战斗中是否击败了赏金首
## 在战斗结算时调用
func check_bounty_defeat(enemy_ids: Array) -> void:
        for bounty in bounties.values():
                if bounty.status != BountyStatus.AVAILABLE:
                        continue
                if enemy_ids.has(bounty.enemy_id):
                        defeat_bounty(bounty.id)

## 检查赏金首是否可以遭遇
## 检查状态是否为可接取，且在正确的区域
func can_encounter_bounty(bounty_id: String) -> bool:
        if not bounties.has(bounty_id):
                return false
        var bounty = bounties[bounty_id]
        return bounty.status == BountyStatus.AVAILABLE

## 获取指定区域内可遭遇的赏金首列表
func get_available_bounties_in_area(area_id: String) -> Array:
        var result: Array = []
        if not area_bounty_map.has(area_id):
                return result
        var bounty_ids = area_bounty_map[area_id]
        for bounty_id in bounty_ids:
                if can_encounter_bounty(bounty_id):
                        result.append(bounty_id)
        return result

## 尝试在指定区域触发赏金首遭遇
## 返回值: 成功触发返回赏金首ID，否则返回空字符串
func try_trigger_bounty_encounter(area_id: String) -> String:
        var available_bounties = get_available_bounties_in_area(area_id)
        if available_bounties.is_empty():
                return ""
        if randf() >= BOUNTY_ENCOUNTER_RATE:
                return ""
        var idx = randi() % available_bounties.size()
        return available_bounties[idx]
