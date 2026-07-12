# Godot 4.3 场景流程运行测试报告

## 测试环境

测试日期：2026-07-12

| 项目 | 结果 |
|---|---|
| Godot 版本 | `4.3.stable.official.77dcf97d8` |
| 运行方式 | `xvfb-run` 虚拟显示 + Godot 标准 Linux 版 |
| 渲染后端 | `opengl3` |
| 分辨率 | `1280x720` |
| 项目版本 | 远端 `main` 最新代码 |

本轮测试先执行 Godot 4.3 headless 导入，确认脚本能通过编辑器加载；随后运行 `tests/flow_capture_runner.tscn`，逐个加载关键 UI、地图、迷宫和战斗场景，并保存运行截图。

## 已修复问题

| 文件 | 问题 | 修复 |
|---|---|---|
| `scripts/ui/save_load_screen.gd` | `_confirm_dialog` 声明为 `Control`，但实际赋值为 `AcceptDialog`，Godot 4.3 编译时报类型错误 | 改为 `ConfirmationDialog`，同时使用确认/取消语义一致的对话框类型 |
| `scenes/characters/enemies/enemy.gd` | 战斗敌人初始化时，`init_enemy()` 在 `@onready` 初始化前访问 `LocalPlayerName`，导致战斗场景运行时报空对象错误 | 在初始化函数中主动获取 `LocalPlayerName` 与 `AnimatedSprite3D`，并加入空值防护 |

## 运行结果

| 检查项 | 结果 |
|---|---|
| Godot 4.3 版本验证 | 通过 |
| 项目 headless 导入 | 通过 |
| 脚本编译 | 通过 |
| 自动截图流程 | 通过 |
| 截图数量 | 19 |
| 失败数量 | 0 |

## 覆盖场景

| 截图 | 场景 |
|---|---|
| `01_title_screen.png` | 标题画面 |
| `02_options_screen.png` | 设置界面 |
| `03_help_screen.png` | 帮助界面 |
| `04_world_map.png` | 世界地图 |
| `05_pause_menu.png` | 暂停菜单 |
| `06_save_screen.png` | 存档界面 |
| `07_load_screen.png` | 读档界面 |
| `08_shop_system.png` | 商店界面 |
| `09_tank_garage.png` | 战车车库 |
| `10_bounty_guild.png` | 赏金公会 |
| `11_battle_victory.png` | 战斗胜利结算 |
| `12_battle_drops.png` | 战斗掉落 |
| `13_game_over.png` | 失败界面 |
| `14_aoduo_base.png` | 奥多基地 |
| `15_wasteland.png` | 荒野 |
| `16_abandoned_factory.png` | 废弃工厂 |
| `17_ant_nest.png` | 蚂蚁巢穴 |
| `18_ancient_ruins.png` | 古代遗迹 |
| `19_battle_scene.png` | 战斗场景 |

## 备注

虚拟显示环境没有音频设备，Godot 自动回退到 dummy audio driver；这不影响本轮图形和场景流程测试。使用 `opengl3` 后端运行 3D 场景时，部分 Forward+ 特效会降级并输出警告，包括体积雾、自动曝光、景深、粒子拖尾和 fog shader。这些是当前虚拟显示/软件渲染环境限制，不代表桌面 Forward+ 目标环境必然失败。
