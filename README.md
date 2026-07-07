# DREAMERS - Metal Max Returns HD-2D 复刻

基于 SFC《重装机兵Returns》(Metal Max Returns) 的 HD-2D 风格复刻游戏。
采用 Godot 4.3 引擎，融合八方旅人 (Octopath Traveler) 的 HD-2D 画面风格。

## 项目概述

在废土世界中，玩家扮演赏金猎人雷班纳，驾驶战车穿梭于荒野与城镇之间，
追捕危险的赏金首，揭开旧文明毁灭的真相。

### 核心玩法
- 🏜️ **开放世界探索** - 在荒野、城镇、遗迹间自由穿梭
- ⚔️ **回合制战斗** - 白刃战与战车战双系统
- 🚗 **战车定制** - Metal Max 标志性的战车改装系统
- 💰 **赏金首系统** - 追捕强大的悬赏目标
- 🎭 **HD-2D 画面** - 像素角色 + 3D 场景 + 景深/移轴效果

## 技术栈

- **引擎**: Godot 4.3 (Forward+ 渲染)
- **语言**: GDScript
- **画面风格**: HD-2D (3D场景 + 2D像素精灵 + 体积雾 + 景深着色器)
- **素材来源**: SFC ROM 提取 + 原创像素美术

## 项目结构

```
dreamers/
├── project.godot                 # Godot 项目配置
├── base.tscn                     # 城市探索主场景 (奥多市)
├── scene/
│   ├── ui/                       # UI 场景
│   │   ├── title_screen.tscn     # 标题画面
│   │   └── world_map.tscn        # 世界地图/区域选择
│   ├── city/
│   │   └── aoduo_city.tscn       # 奥多市 3D 场景
│   ├── characters/
│   │   ├── hero/                 # 玩家角色
│   │   └── enemies/              # 敌人
│   └── HUD/
│       └── fight/                # 战斗系统 HUD
├── script/
│   ├── autoload/
│   │   └── game_flow.gd          # 游戏流程管理器 (场景切换/状态)
│   ├── ui/                       # UI 脚本
│   ├── system/                   # 系统脚本
│   └── shader/                   # 着色器
│       ├── depth_of_field.gdshader  # HD-2D 景深效果
│       ├── vignette.gdshader        # 暗角效果
│       ├── cloud_shadow.gdshader    # 云影效果
│       └── ...
├── resource/
│   ├── data/                     # 游戏数据 (玩家/敌人/技能)
│   ├── sprite/                   # 精灵图
│   ├── tilesets/                 # 图块集
│   └── particles/                # 粒子效果
└── music/                        # 音乐和音效
    ├── background_music/
    └── sound_effect/
```

## 开发进度

### Phase 1 (当前) - 游戏框架与流程 ✅
- [x] 游戏流程管理器 (GameFlow autoload)
- [x] 标题画面 (带粒子效果、菜单导航、入场动画)
- [x] 世界地图/区域选择画面
- [x] 场景过渡效果 (淡入淡出)
- [x] 城市探索模式 (ESC 返回世界地图)
- [x] HD-2D 景深/移轴着色器
- [x] 输入映射配置

### Phase 2 - 战斗系统增强 (计划中)
- [ ] HD-2D 战斗镜头效果
- [ ] 技能特效系统
- [ ] 战斗结算画面优化
- [ ] 更多敌人种类

### Phase 3 - 角色与装备系统 (计划中)
- [ ] 队伍管理
- [ ] 背包/物品系统
- [ ] 装备系统
- [ ] 角色升级/技能树

### Phase 4 - 战车系统 (计划中)
- [ ] 战车驾驶/换乘
- [ ] 战车装备定制
- [ ] 战车战斗模式
- [ ] 燃料/弹药管理

## 运行方式

1. 安装 [Godot 4.3](https://godotengine.org/download)
2. 用 Godot 打开本项目目录
3. 按 F5 运行

## 操作说明

| 按键 | 功能 |
|------|------|
| 方向键/WASD | 移动/菜单导航 |
| Enter/Space | 确认 |
| ESC | 返回/取消 |

## 素材版权

- 游戏设计基于 Crea-Tech / Data East 的《重装机兵》系列
- 音乐素材为原创或基于原作风格重新制作
- 像素美术为原创或从 SFC ROM 提取后修改
- 本项目为非商业性质的同人复刻

## 贡献

本项目为个人学习/演示用途。如需贡献，请 Fork 后提交 Pull Request。
