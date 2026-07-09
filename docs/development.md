# 开发文档 (Development Guide)

## 项目结构

```
dreamers/
├── project.godot                 # Godot 项目配置
├── base.tscn                     # 城市探索主场景 (奥多市)
├── docs/                         # 项目文档
│   ├── project_plan.md           # 项目规划
│   ├── development.md            # 本文档
│   └── assets_credits.md         # 素材来源
├── scene/                        # 场景文件 (旧目录, 逐步迁移)
│   ├── HUD/fight/                # 战斗HUD
│   ├── characters/               # 角色场景
│   ├── city/                     # 城市场景
│   └── ui/                       # UI场景
├── scenes/                       # 场景文件 (新目录)
│   └── ui/                       # 新UI场景
├── script/                       # 脚本 (旧目录)
│   ├── autoload/                 # 自动加载单例
│   ├── system/                   # 系统脚本
│   └── ui/                       # UI脚本
├── scripts/                      # 脚本 (新目录)
│   ├── autoload/                 # 新自动加载单例
│   ├── components/               # 可复用组件
│   └── ui/                       # 新UI脚本
├── resource/                     # 游戏资源
│   ├── data/                     # 数据定义
│   ├── sprite/                   # 像素精灵图
│   ├── theme/                    # 主题/字体
│   ├── tilesets/                 # 图块集
│   ├── particles/                # 粒子效果
│   └── mesh_libraries/           # 3D网格库
├── music/                        # 音频资源
│   ├── background_music/         # BGM (.ogg)
│   └── sound_effect/             # SFX (.wav)
└── addons/                       # 插件
    └── godot-git-plugin/         # Git版本控制插件
```

## 核心系统架构

### Autoload 单例

| 名称 | 路径 | 职责 |
|------|------|------|
| GameData | `script/autoload/game_data.gd` | 全局游戏状态 (队伍/背包/金币/标志位) |
| GameFlow | `script/autoload/game_flow.gd` | 场景切换/过渡效果/游戏状态机 |
| GameManager | `script/autoload/game_manager.gd` | 游戏初始化/新游戏/区域管理 |
| TankSystem | `script/autoload/tank_system.gd` | 战车数据/装备/上下车 |
| SaveSystem | `script/autoload/save_system.gd` | JSON存档/读档 |
| BountySystem | `script/autoload/bounty_system.gd` | 赏金首数据/击败/领赏 |
| DialogueManager | `scripts/autoload/dialogue_manager.gd` | 对话显示/选项/事件触发 |
| SkillData | `scripts/autoload/skill_data.gd` | 技能定义/伤害计算/状态效果 |
| AttackData | `resource/data/attack_data.gd` | 攻击类型/武器定义 |
| PlayerData | `resource/data/player_data.gd` | 玩家角色初始数据 |
| EnemyData | `resource/data/enemy_data.gd` | 敌人数据 (11种) |
| ShopData | `resource/data/shop_data.gd` | 商店物品数据 |
| NPCData | `resource/data/npc_data.gd` | NPC对话数据 |
| TankEquipData | `resource/data/tank_equipment_data.gd` | 战车装备数据 (15+配件) |
| BattleEffects | `script/system/battle_effects.gd` | 战斗特效 (震动/闪光/粒子) |

### 游戏流程

```
标题画面 → 世界地图 → 选择区域 → 城[SYSTEM_NOTE: Content compressed. Read the full version if needed.]overy.gd)
- 8方向移动 (WASD/方向键)
- E键交互 (NPC/事件)
- M键暂停菜单
- T键上下战车
```

## 开发规范

### GDScript 风格
- 使用类型提示: `var name: String = ""`
- 信号声明在文件顶部
- 公开函数添加 `##` 注释
- 内部函数以 `_` 开头
- 使用 `@export` 暴露编辑器属性

### 提交规范 (Conventional Commits)
```
feat: 新功能
fix: 修复Bug
docs: 文档变更
style: 代码格式
refactor: 重构
test: 测试
chore: 构建/工具
```
