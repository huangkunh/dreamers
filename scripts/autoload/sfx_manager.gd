extends Node
## 音效管理器 (SfxManager)
## 集中管理所有游戏音效
## 作为 Autoload 单例运行，跨场景持久化

## 音效文件路径常量
const SFX_PATHS := {
	"menu_select": "res://music/sound_effect/menu_select.wav",
	"menu_confirm": "res://music/sound_effect/menu_confirm.wav",
	"menu_cancel": "res://music/sound_effect/menu_cancel.wav",
	"battle_start": "res://music/sound_effect/battle_start.wav",
	"attack_melee": "res://music/sound_effect/attack_melee.wav",
	"attack_ranged": "res://music/sound_effect/attack_ranged.wav",
	"skill_use": "res://music/sound_effect/skill_use.wav",
	"magic_use": "res://music/sound_effect/magic_use.wav",
	"item_use": "res://music/sound_effect/item_use.wav",
	"critical_hit": "res://music/sound_effect/critical_hit.wav",
	"miss": "res://music/sound_effect/miss.wav",
	"defend": "res://music/sound_effect/defend.wav",
	"victory": "res://music/sound_effect/battle_victory_normal.wav",
	"defeat": "res://music/sound_effect/battle_defeat.wav",
	"step": "res://music/sound_effect/step.wav",
	"door_open": "res://music/sound_effect/door_open.wav",
	"treasure_chest": "res://music/sound_effect/treasure_chest.wav",
	"coin_pickup": "res://music/sound_effect/coin_pickup.wav",
	"level_up": "res://music/sound_effect/level_up.wav",
	"quest_complete": "res://music/sound_effect/quest_complete.wav",
	"encounter": "res://music/sound_effect/encounter.wav",
	"tank_engine": "res://music/sound_effect/tank_engine.wav",
	"tank_cannon": "res://music/sound_effect/tank_cannon.wav",
}

## 音效播放器池
var _player_pool: Array[AudioStreamPlayer] = []
var _max_pool_size: int = 8
var _next_player_index: int = 0

## 缓存已加载的音效
var _stream_cache: Dictionary = {}

func _ready() -> void:
	# 预创建播放器池
	for i in range(_max_pool_size):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		player.name = "SfxPlayer_%d" % i
		add_child(player)
		_player_pool.append(player)

	# 预加载常用音效到缓存
	_preload_common_sfx()

## 预加载常用音效
func _preload_common_sfx() -> void:
	for sfx_name in ["menu_select", "menu_confirm", "attack_melee", "victory", "defeat", "coin_pickup", "level_up"]:
		var path = SFX_PATHS.get(sfx_name, "")
		if path and ResourceLoader.exists(path):
			var stream = load(path)
			if stream:
				_stream_cache[sfx_name] = stream

## 播放指定音效
## sfx_name: 音效名称
## volume_db: 音量调整（dB）
## pitch_scale: 音高调整
func play_sfx(sfx_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if sfx_name.is_empty():
		return

	var stream: AudioStream = null
	if _stream_cache.has(sfx_name):
		stream = _stream_cache[sfx_name]
	else:
		var path = SFX_PATHS.get(sfx_name, "")
		if path and ResourceLoader.exists(path):
			stream = load(path)
			_stream_cache[sfx_name] = stream

	if stream == null:
		# 音效文件不存在，静默失败
		return

	var player := _get_next_player()
	if player:
		player.stream = stream
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()

## 播放3D位置音效
## sfx_name: 音效名称
## position: 世界坐标
func play_sfx_at_position(sfx_name: String, position: Vector3) -> void:
	# 简单实现：3D音效退化为2D音效
	play_sfx(sfx_name)

## 播放随机变调的音效
## sfx_name: 音效名称
## pitch_min: 最低音高
## pitch_max: 最高音高
func play_sfx_varied(sfx_name: String, pitch_min: float = 0.9, pitch_max: float = 1.1) -> void:
	var pitch := randf_range(pitch_min, pitch_max)
	play_sfx(sfx_name, 0.0, pitch)

## 停止所有音效
func stop_all_sfx() -> void:
	for player in _player_pool:
		if player.playing:
			player.stop()

## 停止指定音效
func stop_sfx(sfx_name: String) -> void:
	for player in _player_pool:
		if player.playing and player.stream and _stream_cache.get(sfx_name) == player.stream:
			player.stop()

## 获取下一个可用的播放器
func _get_next_player() -> AudioStreamPlayer:
	if _player_pool.is_empty():
		return null
	# 循环使用播放器池，确保不会重叠过多
	var player = _player_pool[_next_player_index]
	_next_player_index = (_next_player_index + 1) % _player_pool.size()
	# 如果当前播放器正在播放，仍然分配给它（会自动停止）
	return player
