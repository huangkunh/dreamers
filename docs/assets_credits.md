# 素材来源与版权声明 (Assets Credits)

本文档记录项目中所有素材的来源和授权信息。

## 素材分类

### 1. SFC ROM 提取素材

**来源**: SFC《Metal Max Returns》(重装机兵リターンズ, 1995, Crea-Tech/Data East)

**提取工具**:
- 自定义Python脚本 (基于snes9x libretro核心)
- snes9x 1.63 libretro core (headless截图)
- BGR555调色板解析

**提取内容**:
- 图块素材 (4BPP/8BPP/2BPP tiles)
- 调色板数据 (BGR555格式)
- 游戏截图 (40张, 用于参考和拼接)

**版权声明**:
- 《Metal Max》系列版权归 Crea-Tech / Data East (现Entergram) 所有
- 提取的素材仅用于学习和复刻本项目
- 不得用于任何商业用途
- 项目不包含ROM文件本身

### 2. 原创素材

**像素美术**:
- 玩家角色精灵 (hero.png) - 项目原创
- 敌人精灵 (ordinary_enemies/) - 基于原作风格重新绘制
- 战斗特效 (vfx/) - 项目原创

**音乐音效**:
- background_music/ - 原创或基于原作风格重新制作
- sound_effect/ - 原创音效

### 3. 网络素材

**Godot 插件**:
- godot-git-plugin (MIT License) - GitHub版本控制插件

**着色器**:
- vignette.gdshader - 暗角效果 (原创)
- depth_of_field.gdshader - HD-2D景深 (原创)
- cloud_shadow.gdshader - 云影效果 (原创)
- 其他着色器 - 原创或基于Godot社区教程修改

## 授权协议

### 项目代码
- 采用 MIT License 开源

### 素材使用限制
1. SFC ROM提取素材: 仅限学习用途，禁止商业使用
2. 原创素材: 可在MIT协议下使用
3. 第三方素材: 遵循各自授权协议

## 致谢

- **Crea-Tech / Data East**: 原作《Metal Max》系列的开发者
- **Godot Engine**: 游戏引擎开发团队
- **snes9x team**: SNES模拟器开发
- **libretro**: 模拟器前端框架
- **Octopath Traveler**: HD-2D风格灵感来源

## 素材文件清单

### 图形素材
```
resource/sprite/
├── hero/                    # 玩家角色
│   ├── hero.png            # 基础精灵
│   └── hero_normal.png     # 法线贴图
├── battlers/               # 战斗角色
│   ├── fight_player.png    # 战斗玩家
│   ├── fight_player_n.png  # 法线贴图
│   ├── weapons.png         # 武器
│   └── vfx/                # 战斗特效
├── ordinary_enemies/       # 敌人
│   └── aoduo/              # 按区域分类
└── buttons/                # UI按钮
```

### 音频素材
```
music/
├── background_music/
│   ├── battle.ogg          # 战斗BGM
│   ├── defeat.ogg          # 失败BGM
│   └── hum_it_please_drive.ogg  # 探索BGM
└── sound_effect/
    ├── attacked.wav        # 受击音效
    ├── battle_victory_normal.wav  # 胜利音效
    ├── enemy_defeat.wav    # 敌人击败
    ├── enter.wav           # 确认音效
    ├── normal_attack.wav   # 普通攻击
    ├── select.wav          # 选择音效
    └── weapon_stone.wav    # 武器音效
```

### 数据文件
```
resource/data/
├── attack_data.gd          # 攻击数据
├── enemy_data.gd           # 敌人数据
├── player_data.gd          # 玩家数据
├── npc_data.gd             # NPC对话
├── shop_data.gd            # 商店数据
└── tank_equipment_data.gd  # 战车装备

assets/data/
├── dialogue_tavern_keeper.json   # 酒馆老板对话
└── dialogue_factory_guard.json   # 工厂守卫对话
```

---

**最后更新**: 2026-07-08

如发现素材来源标注有误或授权信息不准确，请通过GitHub Issues联系。
