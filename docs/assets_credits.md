# 素材来源与版权声明 (Assets Credits)

## 声明
本项目为非商业性质的同人复刻，仅用于学习和研究目的。
所有素材版权归原始版权方所有。

## 原作版权
- **Metal Max Returns** © Crea-Tech / Data East (1995, SFC/Super Famicom)
- **Octopath Traveler** © Square Enix (HD-2D风格参考)
- 本项目不以任何形式盈利，不会用于商业发行

## 素材分类

### 1. 像素美术素材

#### 从 SFC ROM 提取 (经修改)
| 素材 | 来源 | 用途 |
|------|------|------|
| hero.png, hero_normal.png | ROM提取 | 玩家角色精灵图 |
| fight_player.png | ROM提取 | 战斗场景玩家精灵 |
| e01_flame_guns.png | ROM提取 | 火焰枪敌人 |
| e02_cannon.png | ROM提取 | 炮台敌人 |
| l01_giant_ants.png | ROM提取 | 巨蚁敌人 |
| l01_sour_ants.png | ROM提取 | 酸蚁敌人 |
| l02_amoeba.png | ROM提取 | 变形虫敌人 |
| weapons.png | ROM提取 | 武器精灵图 |
| figth_animated.png | ROM提取 | 战斗动画 |
| player_death.png | ROM提取 | 玩家死亡动画 |

#### 程序生成 (Python Pillow)
| 素材 | 生成脚本 | 用途 |
|------|----------|------|
| w01_desert_rat.png | generate_sprites.py | 荒野敌人: 沙漠鼠 |
| w02_sand_worm.png | generate_sprites.py | 荒野敌人: 沙虫 |
| w03_mad_biker.png | generate_sprites.py | 荒野敌人: 暴走族 |
| b01_rock_butterfly.png | generate_sprites.py | 赏金首: 巨蝶 |
| b02_mad_tank.png | generate_sprites.py | 赏金首: 失控坦克 |
| b03_ant_queen.png | generate_sprites.py | 赏金首: 蚁后 |
| icon_potion.png | generate_sprites.py | UI图标: 药水 |
| icon_weapon.png | generate_sprites.py | UI图标: 武器 |
| icon_armor.png | generate_sprites.py | UI图标: 防具 |
| icon_accessory.png | generate_sprites.py | UI图标: 饰品 |

### 2. 音频素材
| 素材 | 来源 | 用途 |
|------|------|------|
| hum_it_please_drive.ogg | 原创制作 | 城镇BGM |
| battle.ogg | 原创制作 | 战斗BGM |
| defeat.ogg | 原创制作 | 败北BGM |
| normal_attack.wav | 原创制作 | 攻击音效 |
| enemy_defeat.wav | 原创制作 | 敌人击败音效 |
| enter.wav | 原创制作 | 确认音效 |
| select.wav | 原创制作 | 选择音效 |
| attacked.wav | 原创制作 | 受击音效 |
| weapon_stone.wav | 原创制作 | 武器石击音效 |
| battle_victory_normal.wav | 原创制作 | 胜利音效 |
| fight_win_normal.wav | 原创制作 | 战斗胜利音效 |

### 3. 字体素材
| 素材 | 来源 | 授权 |
|------|------|------|
| fang_zheng_hei.ttf | 方正黑体 | 免费商用 |

### 4. 3D资源
| 素材 | 来源 | 用途 |
|------|------|------|
| tree.glb | 原创制作 | 场景树木 |
| mesh_libararies.tres | 原创制作 | GridMap网格库 |

## 法线贴图说明
所有 `_n.png` 后缀的文件为法线贴图(Normal Map)，用于2D像素精灵的3D光照效果。
来源与对应的颜色贴图相同（ROM提取或程序生成）。

## 使用许可
- ROM提取的素材仅用于本项目的学习和演示
- 程序生成的素材可自由使用 (CC0)
- 原创音频素材可自由使用 (CC0)
- 商业使用需获得原作版权方授权
