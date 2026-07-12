extends Control
## 游戏内HUD (GameHUD)
## 探索时显示在屏幕上的状态信息
## 显示: 玩家HP/等级/金币/区域名/游戏时间

@onready var hp_bar: ProgressBar = $TopLeft/PlayerInfo/HPBar
@onready var hp_label: Label = $TopLeft/PlayerInfo/HPLabel
@onready var level_label: Label = $TopLeft/PlayerInfo/LevelLabel
@onready var coins_label: Label = $TopRight/CoinsLabel
@onready var area_label: Label = $TopRight/AreaLabel
@onready var time_label: Label = $TopRight/TimeLabel
@onready var tank_indicator: Label = $TopLeft/PlayerInfo/TankIndicator
@onready var status_effects_container: HBoxContainer = $TopLeft/StatusEffectsContainer

func _ready() -> void:
	# 初始隐藏，城市探索时由city_explorer显示
	visible = false

func _process(_delta: float) -> void:
	if not visible:
		return
	_update_player_info()
	_update_coins()
	_update_time()
	_update_tank_status()
	_update_status_effects()

## 更新玩家信息
func _update_player_info() -> void:
	if GameData.party.is_empty():
		return
	var player = GameData.party[0]
	hp_label.text = "HP: %d / %d" % [player.current_hp, player.max_hp]
	hp_bar.value = float(player.current_hp) / player.max_hp * 100
	level_label.text = "Lv.%d" % player.level

## 更新金币
func _update_coins() -> void:
	coins_label.text = "💰 %d G" % GameData.coins

## 更新游戏时间
func _update_time() -> void:
	time_label.text = GameData.get_play_time_string()

## 更新战车状态
func _update_tank_status() -> void:
	var tank = TankSystem.get_active_tank()
	if tank:
		tank_indicator.text = "🚗 %s (装甲:%d/%d)" % [tank.name, tank.current_hp, tank.max_hp]
		tank_indicator.visible = true
	else:
		tank_indicator.visible = false

## 更新状态效果显示
func _update_status_effects() -> void:
	if GameData.party.is_empty():
		status_effects_container.visible = false
		return
	
	var player = GameData.party[0]
	var status_effects = player.status_effects
	
	if status_effects.is_empty():
		status_effects_container.visible = false
		return
	
	status_effects_container.visible = true
	
	for child in status_effects_container.get_children():
		child.queue_free()
	
	for status in status_effects:
		var status_label := Label.new()
		var effect_type: int = 0
		if status is Dictionary:
			effect_type = status.get("effect_type", 0)
		else:
			effect_type = status.effect_type
		var status_name = StatusEffectSystem.get_status_name(effect_type)
		var status_color = StatusEffectSystem.get_status_color(effect_type)
		status_label.text = status_name
		status_label.add_theme_color_override("font_color", status_color)
		status_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		status_label.add_theme_constant_override("shadow_offset_x", 1)
		status_label.add_theme_constant_override("shadow_offset_y", 1)
		status_label.add_theme_font_size_override("font_size", 12)
		status_effects_container.add_child(status_label)

## 设置区域名
func set_area_name(area_name: String) -> void:
	area_label.text = "📍 " + area_name

## 显示HUD
func show_hud() -> void:
	visible = true

## 隐藏HUD
func hide_hud() -> void:
	visible = false
