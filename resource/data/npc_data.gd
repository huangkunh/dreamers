extends Node
## NPC 对话数据 (NPCData)
## 存储各区域 NPC 的对话脚本

## 奥多市 NPC
var aoduo_npcs: Dictionary = {
        "bar_owner": {
                "name": "酒吧老板",
                "dialogs": [
                        {"name": "酒吧老板", "text": "欢迎来到奥多酒吧！你是新来的赏金猎人吧？"},
                        {"name": "酒吧老板", "text": "最近荒野上不太平，变异生物越来越多了。"},
                        {"name": "酒吧老板", "text": "如果你想接赏金任务，去赏金猎人公会看看吧。"},
                ],
                "choices": {
                        "ask_info": [
                                {"name": "酒吧老板", "text": "想知道这附近的情况？"},
                                {"name": "酒吧老板", "text": "东边有座废弃工厂，里面据说有台失控的旧文明坦克。赏金1500G，不过很危险。"},
                                {"name": "酒吧老板", "text": "南边的蚂蚁巢穴也出了问题，蚁后最近变得很暴躁。"},
                        ],
                        "ask_drink": [
                                {"name": "酒吧老板", "text": "来杯废土特调？10G一杯。"},
                                {"name": "酒吧老板", "text": "喝了能恢复体力，不过别喝太多..."},
                        ],
                },
        },
        "mechanic": {
                "name": "机械师",
                "dialogs": [
                        {"name": "机械师", "text": "嘿！我是镇上的机械师。你的战车有问题就来找我。"},
                        {"name": "机械师", "text": "战车的装甲、引擎、武器都可以升级。"},
                        {"name": "机械师", "text": "不过好零件可不便宜，多攒点钱吧。"},
                ],
        },
        "hunter_guild_master": {
                "name": "公会会长",
                "dialogs": [
                        {"name": "公会会长", "text": "这里是赏金猎人公会。消灭赏金首后来这里领赏。"},
                        {"name": "公会会长", "text": "目前的悬赏名单你看一下。注意难度标记。"},
                        {"name": "公会会长", "text": "最近有个红色公鸡的传闻...算了，你等级太低了。"},
                ],
                "choices": {
                        "check_bounty": [
                                {"name": "公会会长", "text": "让我看看有哪些悬赏目标..."},
                        ],
                },
        },
        "merchant": {
                "name": "旅行商人",
                "dialogs": [
                        {"name": "旅行商人", "text": "需要补给吗？我的货品齐全，价格公道！"},
                        {"name": "旅行商人", "text": "恢复药、解毒剂、燃料、弹药都有卖。"},
                ],
        },
        "old_man": {
                "name": "老人",
                "dialogs": [
                        {"name": "老人", "text": "年轻人...你见过旧文明的光辉吗？"},
                        {"name": "老人", "text": "那时候天空是蓝的，水是清的，没有变异生物..."},
                        {"name": "老人", "text": "据说在地下遗迹深处，还保存着旧文明的科技。"},
                ],
        },
        "girl": {
                "name": "少女",
                "dialogs": [
                        {"name": "少女", "text": "你是赏金猎人吗？好帅气！"},
                        {"name": "少女", "text": "我哥哥也是猎人，他去打巨蝶就一直没回来..."},
                        {"name": "少女", "text": "如果你在路上遇到他，告诉他妹妹在等他..."},
                ],
        },
}

## 荒野 NPC
var wasteland_npcs: Dictionary = {
        "hermit": {
                "name": "隐士",
                "dialogs": [
                        {"name": "隐士", "text": "别在这晃悠，荒野上到处是危险。"},
                        {"name": "隐士", "text": "看到远处那个废弃工厂了吗？那里有台失控坦克。"},
                        {"name": "隐士", "text": "没有足够的装备别去送死。"},
                ],
        },
}

## 获取 NPC 对话
func get_npc_dialog(area: String, npc_id: String) -> Dictionary:
        var area_data: Dictionary = {}
        match area:
                "aoduo": area_data = aoduo_npcs
                "wasteland": area_data = wasteland_npcs
                "factory": area_data = factory_npcs
                _: return {}

        if area_data.has(npc_id):
                return area_data[npc_id]
        return {}

## 废弃工厂 NPC
var factory_npcs: Dictionary = {
        "factory_guard": {
                "name": "工厂守卫",
                "dialogs": [
                        {"name": "工厂守卫", "text": "站住！你是来探索这座废弃工厂的赏金猎人吗？"},
                        {"name": "工厂守卫", "text": "这里是旧文明的武器工厂遗址。最近里面有一台失控的自动坦克在巡逻，见人就攻击。"},
                        {"name": "工厂守卫", "text": "赏金猎人公会悬赏1500金币缉拿那台失控坦克。不过它的装甲很厚，普通武器很难造成伤害。"},
                        {"name": "工厂守卫", "text": "坦克在工厂深处巡逻。小心它的主炮，一炮就能把你送上天。祝你好运！"},
                ],
        },
}
