# 开发文档 (Development Guide)

## 项目结构 (v0.10 — 目录规范化后)

```
dreamers/
├── project.godot                 # Godot 项目配置
├── export_presets.cfg            # 多平台导出预设
├── default_env.tres              # 默认环境
├── default_bus_layout.tres       # 音频总线布局
├── docs/                         # 项目文档
│   ├── project_plan.md           # 项目规划
│   ├── development.md            # 本文档
│   └── assets_credits.md         # 素材来源
├── assets/                       # 原始数据文件
│   └── data/
│       ├── dialogues/            # NPC对话JSON (bar_owner/mechanic/guild_master)
│       ├── dialogue_factory_guard.json
│       └── dialogue_tavern_keeper.json
├── fonts/                        # 字体资源
│   └── fang_zheng_hei.ttf
├── music/                        # 音频资源
│   ├── background_music/         # BGM (.ogg)
│   └── sound_effect/             # SFX (.wav)
├── resource/                     # 美术资源
│   ├── material/                 # 材质
│   ├── mesh_libraries/           # GridMap网格库
│   ├── particles/                # 粒子场景
│   ├── sprite/                   # 像素精灵图
│   │   ├── backgrounds/          # 背景图
│   │   ├── battlers/             # 战斗精灵 + vfx/
│   │   ├── buttons/              # UI按钮
│   │   ├── hero/                 # 玩家角色
│   │   ├── icons/                # UI图标
│   │   ├── line/                 # 分割线
│   │   ├── ordinary_enemies/     # 敌人 (aoduo/wasteland/bounty)
│   │   ├── tanks/                # 战车精灵
│   │   └── tileset/              # 地图tile
│   ├── theme/                    # 主题资源
│   └── tilesets/                 # TileSet资源
├── scenes/                       # 所有场景文件
│   ├── HUD/
│   │   └── fight/                # 战斗场景 (fight.tscn + 子组件)
│   ├── characters/
│   │   ├── enemies/              # 敌人场景
│   │   ├── hero/                 # 玩家/战斗玩家场景
│   │   └── npc/                  # NPC场景
│   ├── city/
│   │   ├── aoduo_base.tscn       # 奥多市主场景
│   │   ├── aoduo_city.tscn       # 奥多市3D建筑
│   │   └── wasteland.tscn        # 荒野场景
│   ├── ui/                       # UI场景 (20个)
│   │   ├── title_screen.tscn     # 标题画面
│   │   ├── world_map.tscn        # 世界地图
│   │   ├── pause_menu.tscn       # 暂停菜单
│   │   ├── dialogue_box.tscn     # 对话框
│   │   ├── game_hud.tscn         # 游戏内HUD
│   │   ├── save_load_screen.tscn # 存档界面
│   │   ├── options_screen.tscn   # 设置界面
│   │   └── ...
│   ├── world/                    # 迷宫关卡
│   │   ├── abandoned_factory.tscn  # 废弃工厂
│   │   ├── ant_nest.tscn           # 蚂蚁巢穴
│   │   └── ancient_ruins.tscn      # 古代遗迹
│   └── text_tree.tscn
├── scripts/                      # 所有脚本
│   ├── autoload/                 # 自动加载单例 (17个)
│   │   ├── game_flow.gd          # 场景切换/游戏状态
│   │   ├── game_data.gd          # 队伍/背包/金币
│   │   ├── game_manager.gd       # 游戏初始化
│   │   ├── save_system.gd        # 存档系统
│   │   ├── tank_system.gd        # 战车系统
│   │   ├── bounty_system.gd      # 赏金首系统
│   │   ├── dialogue_manager.gd   # 对话管理
│   │   ├── skill_data.gd         # 技能数据
│   │   ├── level_up_system.gd    # 升级系统
│   │   ├── quest_system.gd       # 任务系统
│   │   ├── status_effect_system.gd # 状态效果
│   │   ├── c_device_system.gd    # C装置战斗
│   │   ├── crafting_system.gd    # 合成系统
│   │   ├── achievement_system.gd # 成就系统
│   │   ├── game_time_system.gd   # 昼夜系统
│   │   ├── party_manager.gd      # 队伍管理
│   │   └── item_drop_system.gd   # 物品掉落
│   ├── components/               # 可复用组件
│   │   ├── player.gd             # 玩家控制器 (8方向移动)
│   │   ├── player_controller.gd  # 玩家控制器 (备用)
│   │   ├── npc_interactable.gd   # NPC交互组件
│   │   ├── event_trigger.gd      # 事件触发器
│   │   └── treasure_chest.gd     # 宝箱组件
│   ├── data/                     # 数据定义
│   │   ├── attack_data.gd        # 攻击/武器定义
│   │   ├── enemy_data.gd         # 敌人数据 (12种+6赏金首)
│   │   ├── player_data.gd        # 玩家初始数据
│   │   ├── shop_data.gd          # 商店物品
│   │   ├── npc_data.gd           # NPC数据
│   │   ├── tank_equipment_data.gd # 战车装备 (15+配件)
│   │   └── menu/fight_menu_data.gd
│   ├── shader/                   # 着色器 (12个)
│   │   ├── vignette.gdshader     # 暗角
│   │   ├── depth_of_field.gdshader # 景深
│   │   ├── cloud_shadow.gdshader # 云影
│   │   ├── hd2d_enhance.gdshader # HD-2D增强
│   │   └── ...
│   ├── system/                   # 系统脚本
│   │   ├── city_explorer.gd      # 城市探索管理
│   │   ├── random_encounter.gd   # 随机遇敌
│   │   └── battle_effects.gd     # 战斗特效
│   ├── ui/                       # UI脚本 (18个)
│   │   ├── title_screen.gd
│   │   ├── world_map.gd
│   │   ├── pause_menu.gd
│   │   ├── game_hud.gd
│   │   ├── dialogue_box.gd
│   │   ├── battle_skill_panel.gd
│   │   ├── battle_log.gd
│   │   ├── crafting_screen.gd
│   │   ├── achievement_screen.gd
│   │   └── ...
│   └── world/                    # 迷宫脚本
│       ├── abandoned_factory.gd
│       ├── ant_nest.gd
│       └── ancient_ruins.gd
├── addons/                       # 插件
│   └── godot-git-plugin/
└── exports/                      # 导出目录
```

## 架构概览

### Autoload 单例 (17个)

| 单例 | 路径 | 职责 |
|------|------|------|
| GameFlow | `scripts/autoload/game_flow.gd` | 场景切换/游戏状态/过渡效果 |
| GameData | `scripts/autoload/game_data.gd` | 队伍/背包/金币/物品 |
| GameManager | `scripts/autoload/game_manager.gd` | 游戏初始化/新游戏/区域管理 |
| SaveSystem | `scripts/autoload/save_system.gd` | JSON存档/读档 |
| TankSystem | `scripts/autoload/tank_system.gd` | 战车数据/装备/修复/补给 |
| BountySystem | `scripts/autoload/bounty_system.gd` | 赏金首注册/击败/领赏 |
| DialogueManager | `scripts/autoload/dialogue_manager.gd` | 对话显示/选项/事件触发 |
| SkillData | `scripts/autoload/skill_data.gd` | 技能定义/伤害计算 |
| LevelUpSystem | `scripts/autoload/level_up_system.gd` | 经验/升级/属性提升 |
| QuestSystem | `scripts/autoload/quest_system.gd` | 主线/支线任务 |
| StatusEffectSystem | `scripts/autoload/status_effect_system.gd` | 中毒/麻痹/眩晕/增益 |
| CDeviceSystem | `scripts/autoload/c_device_system.gd` | 迎击/援护/自动归返 |
| CraftingSystem | `scripts/autoload/crafting_system.gd` | 合成配方/材料消耗 |
| AchievementSystem | `scripts/autoload/achievement_system.gd` | 24个成就/7大类 |
| GameTimeSystem | `scripts/autoload/game_time_system.gd` | 昼夜4阶段/遇敌率 |
| PartyManager | `scripts/autoload/party_manager.gd` | 队伍成员管理 |
| ItemDropSystem | `scripts/autoload/item_drop_system.gd` | 战利品掉落 |
| AttackData | `scripts/data/attack_data.gd` | 攻击类型/武器定义 |
| PlayerData | `scripts/data/player_data.gd` | 玩家初始数据 |
| ShopData | `scripts/data/shop_data.gd` | 商店物品 |
| NPCData | `scripts/data/npc_data.gd` | NPC数据 |
| TankEquipData | `scripts/data/tank_equipment_data.gd` | 战车装备 |
| BattleEffects | `scripts/system/battle_effects.gd` | 战斗特效 |

### 游戏流程

```
标题画面 → 世界地图 → 选择区域 → 城市/迷宫探索 → 随机遇敌 → 战斗 → 结算 → 返回
                          ↓                        ↓
                     暂停菜单                   BOSS触发
                     (队伍/背包/                (赏金首)
                     存档/设置/任务)
```

### 输入映射

| 动作 | 按键 |
|------|------|
| move_up/down/left/right | WASD + 方向键 |
| ui_accept | Enter/Space |
| ui_cancel | ESC |
| menu | M |
| interact | E |
| tank_toggle | T |

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

### 命名规范
- 脚本: `snake_case.gd`
- 场景: `snake_case.tscn`
- 着色器: `snake_case.gdshader`
- 类: `PascalCase`
- 变量: `snake_case`
- 常量: `UPPER_SNAKE_CASE`
