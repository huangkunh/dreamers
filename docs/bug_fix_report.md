# Bug修复报告

## 修复日期
2026-07-12

## 修复的Bug列表

### Bug 1: NPC双重碰撞检测导致交互失败
**文件**: `scripts/components/npc_interactable.gd`

**问题**: 信号连接没有检查是否已连接，可能导致重复连接；body_entered/body_exited信号处理可能重复触发

**修复内容**:
- 添加了`_signals_connected`标志防止重复连接
- 添加了`_player_in_range`跟踪防止重复触发
- 添加了`_connect_signals()`函数确保信号只连接一次
- 在`_on_body_entered`和`_on_body_exited`中添加玩家实例检查

---

### Bug 2: 对话框键盘确认逻辑异常
**文件**: `scripts/ui/dialogue_box.gd`

**问题**: `_process`中处理输入，但没有检查DialogueManager的状态，可能导致冲突；输入可能重复触发

**修复内容**:
- 添加了输入冷却机制(`INPUT_COOLDOWN = 0.15秒`)
- 添加了`_input_locked`标志防止重复触发
- 分离了选项导航和对话推进的处理逻辑
- 添加了`reset_input_state()`函数重置输入状态
- 添加了`_lock_input()`函数管理输入锁定

---

### Bug 3: 快速旅行功能异常
**文件**: `scripts/ui/fast_travel_screen.gd`

**问题**: 使用`GameFlow.enter_city()`但缺少状态保存和恢复；可能重复触发

**修复内容**:
- 添加了`_is_traveling`状态标志防止重复触发
- 添加了`_selected_area`跟踪选中的区域
- 使用`SceneTransitionManager`进行场景切换
- 添加了延迟确保UI关闭后再切换场景
- 添加了旅行完成回调处理
- 添加了`_get_scene_path()`函数获取场景路径

---

### Bug 4: 存档多槽位操作UI响应问题
**文件**: `scripts/ui/save_load_screen.gd`

**问题**: 使用`queue_free()`关闭界面，但按钮可能仍然响应；缺少操作状态管理

**修复内容**:
- 添加了`_is_processing`状态标志防止重复操作
- 添加了`_selected_slot`跟踪当前选中的槽位
- 添加了确认对话框防止误操作
- 使用延迟释放确保信号处理完成
- 分离了保存/读取逻辑和UI操作
- 添加了`_do_save()`和`_do_load()`执行实际操作

---

### Bug 5: 场景按钮功能失效
**文件**: `scripts/ui/title_screen.gd`, `scripts/ui/pause_menu.gd`

**问题**: 键盘导航使用`emit_signal("pressed")`可能不正确；缺少状态管理

**修复内容**:
**title_screen.gd**:
- 添加了`_is_processing`状态防止重复触发
- 修复了键盘导航逻辑，使用直接函数调用替代`emit_signal`
- 添加了`get_viewport().set_input_as_handled()`防止输入传播
- 添加了按钮功能映射字典`_button_actions`
- 添加了`_activate_current_button()`函数处理按钮激活

**pause_menu.gd**:
- 添加了`_is_processing`状态防止重复触发
- 添加了`_sub_menu_open`状态跟踪子菜单
- 添加了子菜单关闭回调`_on_sub_menu_closed()`
- 改进了按钮点击处理逻辑
- 添加了关闭按钮处理函数`_on_close_pressed()`

---

### Bug 6: 输入映射冲突或缺失
**文件**: `project.godot`

**问题**: `ui_*`和`move_*`都映射到方向键，可能导致冲突

**修复内容**:
- 分离了UI导航(`ui_*`)和角色移动(`move_*`)的输入映射
- `ui_*`仅使用方向键(↑↓←→)
- `move_*`仅使用WASD键
- 添加了战斗快捷键(`battle_attack`, `battle_skill`, `battle_item`, `battle_defend`, `battle_escape`)
- 为`interact`添加了Z键作为备选
- 为`ui_cancel`添加了Backspace键作为备选

---

## 附加修复

### DialogueManager更新
**文件**: `scripts/autoload/dialogue_manager.gd`

**更新内容**:
- 添加了`is_active()`函数供dialogue_box检查状态
- 添加了`set_current_id()`和`show_current_line()`供dialogue_box调用
- 添加了`end_dialogue()`供dialogue_box调用
- 添加了`reset_input_state()`调用
- 添加了`hide_continue_hint()`调用

---

## 代码规范

所有修复的代码均符合GDScript 2.0类型提示规范:
- 函数参数标注类型
- 返回值标注类型
- 使用`var`时标注类型
- 常量使用`const`标注类型

---

## 测试建议

1. **NPC交互测试**: 多次进出NPC范围，验证交互是否正常触发
2. **对话框测试**: 快速按键测试，验证输入冷却是否生效
3. **快速旅行测试**: 多次点击旅行按钮，验证是否只触发一次
4. **存档测试**: 快速点击保存/读取按钮，验证确认对话框是否出现
5. **按钮测试**: 使用键盘导航菜单，验证按钮是否正常响应
6. **输入测试**: 同时按方向键和WASD，验证输入分离是否生效
