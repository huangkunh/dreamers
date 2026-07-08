# Metal Max Returns HD-2D 复刻 — 项目规划

> **项目名称**: DREAMERS  
> **仓库**: https://github.com/huangkunh/dreamers  
> **引擎**: Godot 4.3 (Forward+ 渲染)  
> **语言**: GDScript 2.0  
> **最后更新**: 2026-07-08  

---

## 1. 当前项目状态总结

### 已完成功能 (Phase 1-5)

| 模块 | 状态 | 关键文件 |
|------|------|----------|
| 标题画面 | ✅ | `scene/ui/title_screen.tscn`, `script/ui/title_screen.gd` |
| 世界地图 | ✅ | `scene/ui/world_map.tscn`, `script/ui/world_map.gd` (5个区域) |
| 城市探索 | ✅ | `base.tscn`, `script/system/city_explorer.gd` |
| 荒野场景 | ⚠️ 半成品 | `scene/city/wasteland.tscn` (缺环境资源) |
| 回合制战斗 | ✅ | `scene/HUD/fight/fight.tscn`, `fight.gd` |
| 战斗HUD | ✅ | 血条/速度条/技能名/结算画面 |
| 随机遇敌 | ✅ | `script/system/random_encounter.gd` |
| 暂停菜单 | ✅ | `scene/ui/pause_menu.tscn` (队伍/背包/存档) |
| 存档系统 | ✅ | `script/autoload/save_system.gd` |
| 对话系统 | ✅ | `script/ui/dialog_system.gd` + `.tscn` |
| 商店系统 | ✅ | `script/ui/shop_system.gd` + `.tscn` |
| 赏金首系统 | ✅ | `script/autoload/bounty_system.gd` (5个赏金首) |
| 战车系统 | ✅ | `script/autoload/tank_system.gd` |
| NPC交互 | ✅ | `scene/characters/npc/npc.gd` + `.tscn` |
| HD-2D 着色器 | ✅ | 10个gdshader (景深/晕影/云影/树摇等) |

### 已有素材

| 类型 | 数量 | 说明 |
|------|------|------|
| 玩家精灵 | 2 | `hero.png` + `hero_normal.png` (法线贴图) |
| 战斗玩家 | 4 | `fight_player.png`, `figth_animated.png`, `weapons.png`, `player_death.png` |
| 敌人精灵 | 5 | 火焰枪/炮台/巨型蚂蚁/酸液蚂蚁/变形虫 (各有法线贴图) |
| VFX | 3 | 石头/远程命中/武器样本 |
| UI素材 | 3 | 指针/面板边框/分割线 |
| BGM | 3 | 战斗/探索/失败 |
| SFX | 7 | 攻击/命中/胜利/失败/选择/确认/武器石 |
| 字体 | 1 | `fang_zheng_hei.ttf` |

### 架构分析

**Autoload 单例 (7个)**:
```
AttackData  → 武器/技能数据定义
PlayerData  → 玩家角色数据
GameFlow    → 场景切换/游戏状态
GameData    → 队伍/背包/金钱/时间全局状态
TankSystem  → 战车数据/装备/上下车
SaveSystem  → JSON存档/读档
BountySystem → 赏金首状态管理
BattleEffects → 战斗视觉特效
ShopData    → 商店物品库存
NPCData     → NPC对话脚本
```

**目录结构问题**:
- 目录命名不统一 (`scene/` vs `scenes/`, `script/` vs `scripts/`, `resource/` vs `assets/`)
- 数据文件混放在 `resource/data/` 而非 `scripts/data/`
- 缺少 `docs/`, `exports/` 目录
- 缺少标准的 Godot 项目结构

### 关键技术债

1. **enemy_data.gd 与 attack_data.gd 枚举重复定义** — `Attack_Type` 和 `Attack_Target` 在两个文件各定义了一份
2. **player_data.gd 使用硬编码 Dictionary** — 与 GameData.PartyMember 类不统一
3. **fight.gd 里 enemy_data 用 `load().new()` 实例化** — Autoload 已注册但没使用
4. **荒野敌人缺少精灵图** — `albedo_texture_path` 为空字符串
5. **wasteland.tscn 引用 `default_env.tres`** — 文件不存在
6. **BattleEffects 注册为 Autoload 但 extends Node** — 应为静态工具类或 Node 子类
7. **city_explorer.gd 被重写后可能丢失原有功能** — 需验证暂停菜单/战车切换完整性

---

## 2. 技术选型说明

### 渲染器
- **Forward+** (已选定): 适合 HD-2D 风格，支持高级光照/阴影/体积雾
- 目标分辨率: 1920×1080 (默认), 支持 1280×720 最小
- 像素艺术使用 `Nearest` 纹理过滤

### 碰撞层规划
| 层 | 名称 | 用途 |
|----|------|------|
| 1 | Player | 玩家角色 |
| 2 | Enemy | 敌人/怪物 |
| 3 | NPC | 可交互NPC |
| 4 | Environment | 建筑/障碍物 |
| 5 | Trigger | 事件触发区域 |
| 6 | Projectile | 射弹/飞行物 |

### 输入映射 (已配置)
| 动作名 | 按键 | 用途 |
|--------|------|------|
| `ui_up/down/left/right` | 方向键/WASD | 移动/菜单 |
| `ui_accept` | Enter/Space | 确认/对话 |
| `ui_cancel` | ESC | 返回/取消 |
| `menu` | M | 暂停菜单 |
| `interact` | E | NPC交互 |
| `tank_toggle` | T | 上下战车 |

### HD-2D 风格技术栈
- **3D场景 + 2D像素精灵**: `AnimatedSprite3D` + `StandardMaterial3D` (alpha_cut=2, shaded=true)
- **景深效果**: `depth_of_field.gdshader` (已实现)
- **晕影效果**: `vignette.gdshader` (已实现)
- **体积雾**: `FogVolume` 节点 (已在 base.tscn 中使用)
- **云影**: `simulating_cloud_shadows.gdshader` (已实现)
- **法线贴图**: 像素精灵带法线贴图增强立体感 (已实现)

---

## 3. 目录结构规范

### 目标结构 (逐步迁移)
```
dreamers/
├── docs/                   # 项目文档
│   ├── project_plan.md     # 本文件
│   ├── development.md      # 开发文档
│   └── assets_credits.md   # 素材来源
├── scenes/                 # 游戏场景 (从 scene/ 重命名)
│   ├── main/               # 主场景/入口
│   ├── ui/                 # UI场景
│   ├── world/              # 世界地图与城镇
│   └── battle/             # 战斗场景
├── scripts/                # 脚本 (从 script/ 重命名)
│   ├── autoload/           # 自动加载单例
│   ├── components/         # 可复用组件
│   ├── data/               # 数据定义
│   └── utils/              # 工具函数
├── resources/              # 导入后的资源 (从 resource/ 重命名)
│   ├── sprites/            # 精灵图
│   ├── tilesets/           # 瓦片集
│   ├── shaders/            # 着色器
│   ├── materials/          # 材质
│   ├── themes/             # UI主题
│   ├── particles/          # 粒子效果
│   └── data/               # 数据文件
├── audio/                  # 音频资源 (从 music/ 重命名)
│   ├── bgm/                # 背景音乐
│   └── sfx/                # 音效
├── addons/                 # 插件
├── exports/                # 导出预设
├── project.godot
└── export_presets.cfg
```

> **注意**: 目录重命名涉及大量 import 路径更新，将在 Phase 3 统一处理。当前阶段保持现有结构。

---

## 4. 下一步工作计划

### 第一阶段：奠基与核心系统修复 (当前)

#### 4.1.1 架构修复 (优先级: P0)
- [ ] 修复 `default_env.tres` 缺失问题
- [ ] 统一 `AttackData` 枚举，消除重复定义
- [ ] 修复 `enemy_data.gd` 中荒野敌人缺少精灵图的问题 (生成占位图)
- [ ] 修复 `fight.gd` 使用 Autoload 而非 `load().new()`
- [ ] 验证 `city_explorer.gd` 完整性 (暂停菜单/战车/对话/商店)

#### 4.1.2 像素素材生成
- [ ] 为荒野敌人生成占位像素精灵 (沙漠鼠/沙虫/暴走族)
- [ ] 为赏金首生成占位像素精灵 (巨蝶/失控坦克/蚁后)
- [ ] 生成 NPC 占位精灵 (酒吧老板/机械师/公会会长等)
- [ ] 生成战车精灵 (步行/驾驶状态)

#### 4.1.3 核心系统增强
- [ ] 实现战车战斗模式 (主炮/机枪/SE脉冲)
- [ ] 实现等级/经验值系统 (升级/属性增长)
- [ ] 实现物品掉落系统
- [ ] 实现装备效果实际生效 (装备的 attack/defense 实际参与伤害计算)

#### 4.1.4 剧情框架
- [ ] 创建 `story_data.gd` 存储主线剧情脚本
- [ ] 实现序章: 雷班纳离开父亲的家 → 到达奥多市
- [ ] 实现第一个任务: 酒吧老板引导 → 赏金公会注册 → 第一个赏金首

### 第二阶段：内容与玩法填充

#### 4.2.1 关卡设计
- [ ] 奥多市完整地图 (酒吧/机械店/赏金公会/旅馆/民宅)
- [ ] 荒野地图 (连接奥多到废弃工厂)
- [ ] 废弃工厂迷宫 (含BOSS: 失控坦克)
- [ ] 蚂蚁巢穴迷宫 (含BOSS: 蚁后)

#### 4.2.2 战车系统完善
- [ ] 战车装备界面 (主炮/副炮/引擎/装甲/C装置)
- [ ] 战车改造系统 (升级装甲/引擎)
- [ ] C装置技能 (迎击/援护/自动归返)
- [ ] 战车战斗模式 (与白刃战切换)

#### 4.2.3 HD-2D 视觉提升
- [ ] 景深效果调优 (战斗场景)
- [ ] 动态光照 (火光/爆炸/技能特效)
- [ ] 粒子系统 (爆炸/烟雾/治疗)
- [ ] 屏幕震动 (受击/炮击)

### 第三阶段：完善与优化
- [ ] UI/UX 打磨 (主菜单/HUD/对话框统一风格)
- [ ] 数值平衡 (敌人/经验/金钱/装备)
- [ ] Bug修复 (战斗逻辑/场景切换/存档)
- [ ] 多平台导出 (Windows/macOS/Linux)
- [ ] 文档完善 (README/development/assets_credits)

---

## 5. 每次提交的测试清单

| 测试项 | 方法 |
|--------|------|
| 项目可加载 | Godot 编辑器无报错打开项目 |
| 标题画面 | F5 运行 → 标题画面显示 |
| 场景切换 | 标题 → 世界地图 → 城市 → 战斗 → 返回 |
| 战斗流程 | 遇敌 → 攻击 → 击败 → 结算 → 返回 |
| 存档/读档 | 暂停菜单存档 → 标题画面继续 |
| 无控制台错误 | 运行时无 push_error 输出 |

---

## 6. 版本里程碑

| 版本 | 目标 | 预计 |
|------|------|------|
| v0.1.0 | 核心系统修复 + 可运行原型 | Phase 1 完成 |
| v0.2.0 | 第一个完整关卡 (奥多→荒野→BOSS) | Phase 2 完成 |
| v0.3.0 | 战车系统完善 + HD-2D 视觉提升 | Phase 2 完成 |
| v0.5.0 | UI打磨 + 数值平衡 | Phase 3 完成 |
| v1.0.0-alpha | 可发布版本 | Phase 3 完成 |
