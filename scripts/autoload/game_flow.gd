extends Node
## 游戏流程管理器 (GameFlowManager)
## 负责场景切换、游戏状态管理、过渡效果
## 作为 Autoload 单例运行

signal scene_changed(scene_name: String)
signal game_state_changed(state: GameState)

enum GameState {
	TITLE,       ## 标题画面
	WORLD_MAP,   ## 世界地图
	CITY,        ## 城市探索
	BATTLE,      ## 战斗中
	MENU,        ## 菜单
}

## 当前游戏状态
var current_state: GameState = GameState.TITLE:
	set(v):
		current_state = v
		game_state_changed.emit(v)

## 场景路径映射
const SCENE_PATHS := {
	"title": "res://scenes/ui/title_screen.tscn",
	"world_map": "res://scenes/ui/world_map.tscn",
	"city": "res://scenes/city/aoduo_base.tscn",
	"wasteland": "res://scenes/city/wasteland.tscn",
	"factory": "res://scenes/world/abandoned_factory.tscn",
	"ant_nest": "res://scenes/world/ant_nest.tscn",
	"ancient_ruins": "res://scenes/world/ancient_ruins.tscn",
	"battle": "res://scenes/HUD/fight/fight.tscn",
}

## 过渡遮罩节点
var _transition_overlay: ColorRect
## 是否正在过渡
var _transitioning: bool = false

func _ready() -> void:
	# 创建过渡遮罩
	_transition_overlay = ColorRect.new()
	_transition_overlay.color = Color.BLACK
	_transition_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_overlay.modulate.a = 0.0
	# 添加到 CanvasLayer 以确保显示在最上层
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(_transition_overlay)
	add_child(canvas)

## 切换场景（带淡入淡出过渡）
func change_scene(scene_name: String, fade_duration: float = 0.5) -> void:
	if _transitioning:
		return
	if not SCENE_PATHS.has(scene_name):
		push_error("未知场景: " + scene_name)
		return
	_transitioning = true

	# 淡出（变黑）
	var tw := create_tween()
	tw.tween_property(_transition_overlay, "modulate:a", 1.0, fade_duration)
	await tw.finished

	# 切换场景
	var path: String = SCENE_PATHS[scene_name]
	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("场景切换失败: " + path)
		_transitioning = false
		return

	scene_changed.emit(scene_name)

	# 淡入（变透明）
	var tw2 := create_tween()
	tw2.tween_property(_transition_overlay, "modulate:a", 0.0, fade_duration)
	await tw2.finished
	_transitioning = false

## 开始新游戏
func start_new_game() -> void:
	BgmManager.play_area_bgm("world_map")
	change_scene("world_map")

## 进入城市
func enter_city() -> void:
	current_state = GameState.CITY
	# 根据当前区域选择场景
	var area_id = GameData.game_flags.get("current_area", "aoduo")
	match area_id:
		"aoduo":
			change_scene("city")
		"wasteland":
			change_scene("wasteland")
		"factory":
			change_scene("factory")
		"ant_nest":
			change_scene("ant_nest")
		"ancient_ruins":
			change_scene("ancient_ruins")
		_:
			change_scene("city")

## 进入战斗
func enter_battle() -> void:
	current_state = GameState.BATTLE
	change_scene("battle")

## 返回标题
func return_to_title() -> void:
	current_state = GameState.TITLE
	BgmManager.stop_bgm()
	change_scene("title")

## 返回世界地图
func return_to_world_map() -> void:
	current_state = GameState.WORLD_MAP
	BgmManager.play_area_bgm("world_map")
	change_scene("world_map")
