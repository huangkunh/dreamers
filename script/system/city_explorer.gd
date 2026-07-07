extends Node3D
## 城市探索管理器 (CityExplorer)
## 管理城市探索模式，处理返回世界地图等

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	# 确保背景音乐播放
	if audio_stream_player and not audio_stream_player.playing:
		audio_stream_player.play()
	# 设置游戏状态
	GameFlow.current_state = GameFlow.GameState.CITY

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				# 返回世界地图
				GameFlow.return_to_world_map()
			KEY_M:
				# 打开菜单 (TODO)
				print("[CityExplorer] 菜单键按下")
