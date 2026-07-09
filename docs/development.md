# 开发文档 (Development Guide)

本文档说明 Metal Max Returns HD-2D 复刻项目的架构、主要系统和开发指南。

## 项目架构

### 技术栈
- **引擎**: Godot 4.3 稳定版
- **渲染器**: Forward+ (支持高级光照、体积雾、HD-2D效果)
- **脚本语言**: GDScript 2.0 (带类型提示)
- **版本控制**: Git (Conventional Commits规范)

### 目录结构
```
dreamers/
├── docs/                 # 项目文档
├── assets/               # 原始资源 (JSON对话数据等)
│   └── data/             # 数据文件
├── scenes/               # 新结构场景
│   ├── ui/               # UI场景
│   └── world/            # 世界场景
├── scripts/              # 新结构脚本
│   ├── autoload/         # 自动加载单例
│   ├── components/       # 可复用组件
│   └── ui/               # UI脚本
├── scene/                # 原有场景 (兼容)
│   ├── HUD/fight/        # 战斗系统
│   ├── characters/       # 角色场景
│   ├── city/             # 城市场景
│   └── ui/               # UI场景
├── script/               # 原有脚本 (兼容)
│   ├── autoload/         # 自动加载单例
│   ├── system/           # 系统脚本
│   ├── shader/           # 着色器
│   └── ui/               # UI脚本
├── resource/             # 资源文件
│   ├── data/             # 游戏数据
│   ├── sprite/           # 精灵图
│   └── tilesets/         # 图块集
├── music/                # 音乐和音效
└── project.godot         # 项目设置
```

> 注: 项目正在从旧结构(scene/script/resource)迁移到新结构(scenes/scripts/assets)，目前两套结构共存。

## 核心系统

### Autoload 单例 (全局管理器)

| 单例名 | 文件 | 职责 |
|--------|------|------|
| AttackData | resource/data/attack_data.gd | 攻击类型和武器数据 |
| PlayerData | resource/data/player_data.gd | 玩家初始数据 |
| GameFlow | script/autoload/game_flow.gd | 场景切换和游戏状态 |
| GameData | script/autoload/game_data.gd | 全局游戏数据 (队伍/背包/金币) |
| GameManager | script/autoload/game_manager.gd | 游戏初始化 |
| TankSystem | script/autoload/tank_system.gd | 战车数据管理 |
| SaveSystem | script/autoload/save_system.gd | 存档/读档 |
| BountySystem | script/autoload/bounty_system.gd | 赏金首系统 |
| BattleEffects | script/system/battle_effects.gd | 战斗特效 |
| ShopData | resource/data/shop_data.gd | 商店物品 |
| NPCData | resource/data/npc_data.gd | NPC对话数据 |
| TankEquipData | resource/data/tank_equipment_data.gd | 战车装备数据 |
| DialogueManager | scripts/autoload/dialogue_manager.gd | 对话管理 (打字机/选项) |
| SkillData | scripts/autoload/skill_data.gd | 技能数据 (15个技能) |
| CDeviceSystem | scripts/autoload/c_device_system.gd | C装置战斗技能 |

### 游戏流程

```
标题画面 → 世界地图 → 区域选择
                         ↓
                    ┌─────────────┐
                    │ 奥多市 (城镇) │
                    │ 荒野         │
                    │ 废弃工厂     │
                    │ 蚂蚁巢穴     │
                    │ 古代遗迹     │
                    └──────┬──────┘
                           ↓
                    随机遇敌/BOSS战
                           ↓
                      战斗结算
                           ↓
                      返回区域
```

### 战斗系统

#### 回合制流程
1. 速度条决定行动顺序 (fight_speed_path.gd)
2. 玩家回合: 选择攻击/技能/道具
3. 敌人回合: AI选择技能和目标
4. 伤害计算: 攻击力×威力 - 防御力/2 (±10%浮动)
5. 状态效果: 中毒/麻痹/眩晕等
6. 胜利/失败判定

#### BOSS战特殊处理
- 通过 `GameData.game_flags["boss_battle"]` 标记BOSS战
- 胜利后更新 `BountySystem` 中的赏金首状态
- 额外奖励: 经验+等级×20, 金币+赏金金额

#### C装置技能
| 技能 | 效果 | 触发条件 |
|------|------|----------|
| 迎击 | 拦截敌方攻击 | 30%+速度差×2% |
| 援护 | 为队友挡攻击 | 队友HP<50%, 40%概率 |
| 自动归返 | HP低时撤退 | HP<20% |
| 目标锁定 | +20%命中率 | 被动 |

### 对话系统

#### 数据格式 (JSON)
```json
{
    "start": {
        "speaker": "NPC名字",
        "text": "对话文本",
        "next_id": "next_line"
    },
    "next_line": {
        "speaker": "NPC名字",
        "text": "带选项的对话",
        "choices": [
            {"text": "选项1", "next_id": "branch_1"},
            {"text": "选项2", "next_id": "branch_2"}
        ]
    }
}
```

#### 使用方式
```gdscript
var dialogue_data = DialogueManager.load_dialogue_from_dict(json_data)
DialogueManager.start_dialogue(dialogue_data, "start")
```

### 存档系统

- 存档路径: `user://save_data.json`
- 序列化: 队伍/背包/战车/游戏标志
- 使用 `SaveSystem.save_game()` 和 `SaveSystem.load_game()`

## 开发指南

### 添加新区域

1. 在 `scripts/world/` 创建场景脚本
2. 在 `scenes/world/` 创建 `.tscn` 场景文件
3. 在 `GameFlow.SCENE_PATHS` 添加场景路径
4. 在 `world_map.gd` 的 `AREAS` 数组添加区域数据
5. 在 `enemy_data.gd` 添加区域敌人编组
6. 在 `npc_data.gd` 添加区域NPC对话

### 添加新敌人

1. 在 `resource/data/enemy_data.gd` 定义敌人数据字典
2. 添加到 `enemies_init_data` 和区域敌人编组
3. 准备精灵图 (`resource/sprite/ordinary_enemies/`)

### 添加新技能

1. 在 `scripts/autoload/skill_data.gd` 的 `_init_skills()` 注册技能
2. 使用 `_register_skill()` 或 `_register_status_skill()` 方法
3. 在战斗脚本中调用 `SkillData.calculate_damage()` 计算伤害

### 添加新NPC

1. 在 `resource/data/npc_data.gd` 添加NPC对话数据
2. 在场景中放置 `scene/characters/npc/npc.tscn` 实例
3. 设置 `npc_id`, `npc_area`, `display_name` 属性

## 测试

### Headless 测试
```bash
godot --headless --import          # 导入项目检查错误
godot --headless --quit-after 60   # 运行60帧测试
```

### 测试清单
- [ ] 标题画面正常显示和导航
- [ ] 世界地图区域选择正常
- [ ] 城市探索移动正常
- [ ] NPC交互对话正常
- [ ] 随机遇敌触发
- [ ] 战斗系统完整流程
- [ ] BOSS战赏金首处理
- [ ] 存档/读档功能
- [ ] 战车上下车切换

## Conventional Commits 规范

```
feat: 新功能
fix: 修复Bug
docs: 文档更新
style: 代码格式
refactor: 重构
test: 测试
chore: 构建/工具
```

示例: `feat: 添加废弃工厂迷宫关卡`
