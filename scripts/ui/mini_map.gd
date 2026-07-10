extends Control
## 小地图 (MiniMap)
## 探索时显示在屏幕角落，标注玩家位置和兴趣点

@onready var player_marker: Sprite2D = $Panel/MapContainer/PlayerMarker
@onready var npc_markers: Node2D = $Panel/MapContainer/NPCMarkers
@onready var chest_markers: Node2D = $Panel/MapContainer/ChestMarkers
@onready var boss_marker: Sprite2D = $Panel/MapContainer/BossMarker
@onready var area_label: Label = $Panel/AreaLabel

## 地图缩放 (世界单位 -> 像素)
@export var map_scale: float = 3.0
## 地图中心偏移
@export var map_center: Vector2 = Vector2(120, 120)
## 玩家节点
var _player: CharacterBody3D
## 是否显示BOSS标记
var _show_boss: bool = false
## BOSS位置
var _boss_pos: Vector3 = Vector3.ZERO

func _ready() -> void:
	visible = false

## 设置玩家引用
func set_player(player: CharacterBody3D) -> void:
	_player = player

## 设置区域名
func set_area_name(name: String) -> void:
	area_label.text = name

## 设置BOSS标记
func set_boss_marker(pos: Vector3, show: bool = true) -> void:
	_boss_pos = pos
	_show_boss = show
	boss_marker.visible = show

## 添加NPC标记
func add_npc_marker(pos: Vector3) -> void:
	var marker := ColorRect.new()
	marker.color = Color(0.3, 0.9, 0.3, 0.8)
	marker.size = Vector2(6, 6)
	marker.position = _world_to_map(pos) - Vector2(3, 3)
	npc_markers.add_child(marker)

## 添加宝箱标记
func add_chest_marker(pos: Vector3) -> void:
	var marker := ColorRect.new()
	marker.color = Color(1, 0.85, 0.3, 0.8)
	marker.size = Vector2(5, 5)
	marker.position = _world_to_map(pos) - Vector2(2.5, 2.5)
	chest_markers.add_child(marker)

## 清除所有标记
func clear_markers() -> void:
	for child in npc_markers.get_children():
		child.queue_free()
	for child in chest_markers.get_children():
		child.queue_free()

## 世界坐标转地图坐标
func _world_to_map(world_pos: Vector3) -> Vector2:
	return Vector2(world_pos.x, world_pos.z) * map_scale + map_center

func _process(_delta: float) -> void:
	if not visible or not _player:
		return
	# 更新玩家位置
	player_marker.position = _world_to_map(_player.position)
	# 玩家旋转 (根据朝向)
	# TODO: 根据玩家朝向旋转标记

	# 更新BOSS标记
	if _show_boss:
		boss_marker.position = _world_to_map(_boss_pos)

## 显示小地图
func show_map() -> void:
	visible = true

## 隐藏小地图
func hide_map() -> void:
	visible = false
