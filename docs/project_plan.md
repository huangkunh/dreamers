# Metal Max Returns HD-2D 复刻 - 项目计划

## 项目状态总结 (2026-07-08)

### 已完成功能

| 系统 | 状态 | 说明 |
|------|------|------|
| 游戏流程管理 | ✅ 完成 | GameFlow autoload，场景切换+淡入淡出过渡 |
| 标题画面 | ✅ 完成 | HD-2D风格，沙尘粒子，菜单导航 |
| 世界地图 | ✅ 完成 | 区域选择列表（奥多市/荒野/遗迹/赏金首） |
| 城市探索 | ✅ 完成 | 3D场景+GridMap，ESC返回，M键菜单 |
| 战斗系统 | ✅ 基础完成 | 回合制，速度条，攻击动画，结算画面 |
| 随机遇敌 | ✅ 完成 | 基于移动距离触发 |
| 战斗过渡 | ✅ 完成 | 白闪→合拢→战斗文字动画 |
| 伤害数字 | ✅ 完成 | 3D Label弹出，4种类型 |
| 队伍/背包 | ✅ 基础完成 | GameData autoload，Item/PartyMember类 |
| 暂停菜单 | ✅ 基础完成 | 队伍状态/背包分页 |
| 战车系统 | ✅ 基础完成 | TankSystem autoload，HUD，上下车切换 |
| HD-2D着色器 | ✅ 完成 | 景深、暗角、云影等10个着色器 |

### 当前代码规模
- GD脚本: 30 个
- 场景文件: 21 个
- 着色器: 10 个
- Autoload单例: 5 个 (AttackData, PlayerData, GameFlow, GameData, TankSystem)
- 项目体积: ~49MB

### 存在的问题与不足

1. **目录结构不规范** — 使用 `scene/` 而非 `scenes/`，`resource/` 而非 `assets/`
2. **玩家移动仅4方向** — 需改为8方向移动
3. **无对话系统** — 缺少RPG核心的对话框/NPC交互
4. **无存档系统** — 无法保存进度
5. **ROM素材未整合** — 已提取的素材未导入项目
6. **战斗系统不完整** — 缺少技能系统、状态效果、战车战斗
7. **无C装置系统** — Metal Max标志性的战车C装置未实现
8. **无赏金首系统** — 核心玩法缺失
9. **数值不平衡** — 敌人/玩家属性需要调整

---

## 技术选型说明

### 引擎与渲染
- **引擎**: Godot 4.3 稳定版
- **渲染器**: Forward+ (桌面平台，支持高级光照和体积雾)
- **色彩空间**: sRGB (默认)

### 碰撞层规划
| 层 | 名称 | 用途 |
|----|------|------|
| 1 | Player | 玩家角色 |
| 2 | Enemy | 敌人 |
| 3 | NPC | 可交互NPC |
| 4 | Terrain | 地形/墙壁 |
| 5 | Trigger | 事件触发器 |
| 6 | Tank | 战车 |
| 7 | Projectile | 弹射物 |

### 输入映射
| 动作 | 按键 | 用途 |
|------|------|------|
| move_up | W/↑ | 向上移动 |
| move_down | S/↓ | 向下移动 |
| move_left | A/← | 向左移动 |
| move_right | D/→ | 向右移动 |
| interact | E/Enter | 交互/确认 |
| cancel | ESC | 取消/返回 |
| menu | M | 打开菜单 |
| tank_toggle | T | 上下战车 |
| battle_attack | Space | 战斗中攻击 |

---

## 目录结构规范

当前项目使用非标准目录，将逐步迁移至以下规范结构：

```
dreamers/
├── docs/                 # 项目文档
│   ├── project_plan.md   # 本文档
│   ├── development.md    # 开发文档
│   └── assets_credits.md # 素材来源
├── scenes/               # 游戏场景 (迁移自 scene/)
│   ├── main/             # 主场景
│   ├── ui/               # UI场景
│   ├── world/            # 世界地图与城镇
│   └── battle/           # 战斗场景
├── scripts/              # 脚本 (迁移自 script/)
│   ├── autoload/         # 自动加载单例
│   ├── components/       # 可复用组件
│   ├── data/             # 数据定义
│   └── utils/            # 工具函数
├── assets/               # 资源 (迁移自 resource/ + music/)
│   ├── sprites/          # 精灵图
│   ├── tilesets/         # 图块集
│   ├── audio/            # 音频
│   ├── fonts/            # 字体
│   └── data/             # 数据文件
├── shaders/              # 着色器
├── project.godot
└── export_presets.cfg
```

> 注：目录迁移将分阶段进行，避免破坏现有功能。

---

## 阶段任务清单

### 第一阶段：奠基与核心系统 (当前进行中)

#### 1.1 核心系统补全
- [ ] 8方向玩家移动
- [ ] 对话系统 (DialogueManager + 对话框UI)
- [ ] 存档系统 (SaveManager)
- [ ] NPC交互系统
- [ ] 事件触发器系统

#### 1.2 ROM素材整合
- [ ] 导入已提取的图块素材
- [ ] 导入调色板数据
- [ ] 创建素材预览场景
- [ ] 整理音频素材命名

#### 1.3 战斗系统完善
- [ ] 技能系统 (多技能、MP消耗)
- [ ] 状态效果 (中毒、麻痹等)
- [ ] 战车战斗模式
- [ ] 战斗AI增强

### 第二阶段：内容与玩法填充

#### 2.1 剧情与关卡
- [ ] 对话脚本系统
- [ ] 第一个迷宫关卡
- [ ] 第一个BOSS战
- [ ] 赏金首系统

#### 2.2 战车系统深化
- [ ] C装置系统 (迎击/援护/自动归返)
- [ ] 战车装备改造界面
- [ ] 战车战斗模式

#### 2.3 美术音效提升
- [ ] HD-2D光影增强
- [ ] 技能特效粒子系统
- [ ] 音效空间化处理

### 第三阶段：完善与优化

#### 3.1 UI/UX打磨
- [ ] 主菜单美化
- [ ] HUD设计优化
- [ ] 对话框动画

#### 3.2 平衡与调试
- [ ] 数值平衡调整
- [ ] Bug修复
- [ ] 性能优化

#### 3.3 打包发布
- [ ] 多平台导出
- [ ] 文档完善
- [ ] Release发布

---

## 每日任务记录

### 2026-07-08 (Day 1)
**计划完成:**
- 创建项目计划文档
- 实现8方向玩家移动
- 实现对话系统
- 整合ROM素材

**实际完成:**
- ✅ 创建 docs/project_plan.md 项目计划文档
- ✅ 实现 PlayerController 8方向移动组件 (对角线归一化)
- ✅ 实现 DialogueManager 对话管理系统 (打字机效果/选项分支/事件触发)
- ✅ 实现 DialogueBox 对话框UI (说话者/文本/选项/继续提示)
- ✅ 实现 NPCInteractable NPC交互组件 (Area3D检测/JSON对话加载)
- ✅ 创建示例对话数据 (酒馆老板NPC)
- ✅ 实现 SkillData 技能系统 (15个技能/7种状态效果/伤害计算)
- ✅ 实现 SaveLoadScreen 存档/读档界面 (3槽位)
- ✅ 实现 EventTrigger 事件触发器 (6种事件类型)
- ✅ 修复远程代码错误 (enemy_data类型推断/world_map const赋值)
- ✅ 合并远程新增系统 (GameManager/SaveSystem/BountySystem/BattleEffects/ShopData/NPCData/TankEquipData)

**明日计划:**
- 创建第一个迷宫关卡场景
- 实现BOSS战
- 整合ROM提取的图块素材到TileMap
- 完善战斗系统技能使用

### 2026-07-09 (Day 2)
**计划完成:**
- 集成新系统 (DialogueManager/SkillData) 到主游戏流程
- 添加缺失的 move_* 输入映射
- 升级玩家移动为8方向
- 创建废弃工厂迷宫场景
- 创建NPC对话数据文件 (JSON)
- 编写开发文档和素材版权声明

**实际完成:**
- ✅ 添加 move_up/down/left/right 输入映射 (WASD+方向键)
- ✅ 升级 player.gd 为8方向移动 (对角线归一化, 交互信号)
- ✅ 注册 DialogueManager 和 SkillData autoload
- ✅ 修复 DialogueManager (set_dialogue_box/start_dialogue_queue/load_from_file)
- ✅ 修复 dialogue_box.gd (show_choices/输入处理)
- ✅ 更新 city_explorer.gd (集成对话/商店/改造/公会)
- ✅ 创建废弃工厂场景 (factory_ruins.tscn)
- ✅ GameFlow 添加 factory 场景路由
- ✅ 创建NPC对话JSON文件 (酒吧老板/机械师/公会会长)
- ✅ 编写 docs/development.md 开发文档
- ✅ 编写 docs/assets_credits.md 素材版权声明

**明日计划:**
- 在 base.tscn 中放置可交互NPC节点
- 实现废弃工厂BOSS战触发
- 将 SkillData 接入战斗系统
- 创建荒野场景NPC和事件触发器
