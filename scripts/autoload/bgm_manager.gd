extends Node
## BGM管理器 (BgmManager)
## 管理游戏背景音乐播放
## 作为 Autoload 单例运行，跨场景持久化

const BGM_BATTLE := preload("res://music/background_music/battle.ogg")
const BGM_DEFEAT := preload("res://music/background_music/defeat.ogg")
const BGM_DRIVE := preload("res://music/background_music/hum_it_please_drive.ogg")
const SFX_VICTORY := preload("res://music/sound_effect/battle_victory_normal.wav")

## 区域BGM映射
const AREA_BGM := {
        "world_map": preload("res://music/background_music/hum_it_please_drive.ogg"),
        "aoduo": preload("res://music/background_music/hum_it_please_drive.ogg"),
        "wasteland": preload("res://music/background_music/hum_it_please_drive.ogg"),
        "factory": preload("res://music/background_music/battle.ogg"),
        "ant_nest": preload("res://music/background_music/battle.ogg"),
        "ancient_ruins": preload("res://music/background_music/battle.ogg"),
}

## BGM播放器 (循环播放背景音乐)
var _audio_player: AudioStreamPlayer
## SFX播放器 (播放一次性音效，如胜利音效)
var _sfx_player: AudioStreamPlayer
## 当前正在播放的BGM
var _current_bgm: AudioStream
## 当前活跃的淡入淡出Tween (用于在切换时终止旧Tween)
var _tween: Tween

func _ready() -> void:
        _audio_player = AudioStreamPlayer.new()
        _audio_player.bus = "Master"
        add_child(_audio_player)

        _sfx_player = AudioStreamPlayer.new()
        _sfx_player.bus = "Master"
        add_child(_sfx_player)

        # 确保区域BGM音频流启用循环播放 (失败BGM保持不循环)
        _ensure_loop(BGM_BATTLE)
        _ensure_loop(BGM_DRIVE)
        for bgm in AREA_BGM.values():
                _ensure_loop(bgm)

## 确保OGG音频流启用循环
func _ensure_loop(stream: AudioStream) -> void:
        if stream is AudioStreamOggVorbis:
                (stream as AudioStreamOggVorbis).loop = true

## 播放区域BGM
## area_id 区域ID，未匹配时默认使用驾驶BGM
func play_area_bgm(area_id: String) -> void:
        var bgm = AREA_BGM.get(area_id, BGM_DRIVE)
        if _current_bgm == bgm and _audio_player.playing:
                return
        _fade_to(bgm)

## 播放战斗BGM
func play_battle_bgm() -> void:
        _fade_to(BGM_BATTLE)

## 播放胜利音效 (一次性SFX，不打断BGM)
func play_victory_bgm() -> void:
        _sfx_player.stream = SFX_VICTORY
        _sfx_player.play()

## 播放失败BGM
func play_defeat_bgm() -> void:
        _fade_to(BGM_DEFEAT)

## 停止BGM (带淡出)
func stop_bgm() -> void:
        if _audio_player.playing:
                _kill_tween()
                _tween = create_tween()
                _tween.tween_property(_audio_player, "volume_db", -40, 0.5)
                _tween.tween_callback(_audio_player.stop)
                _tween.tween_callback(func(): _audio_player.volume_db = 0)

## 淡入淡出切换BGM
## stream 要播放的新音频流
func _fade_to(stream: AudioStream) -> void:
        _kill_tween()
        if _audio_player.playing:
                _tween = create_tween()
                _tween.tween_property(_audio_player, "volume_db", -40, 0.3)
                _tween.tween_callback(_audio_player.stop)
                _tween.tween_callback(func(): _audio_player.volume_db = 0)
                _tween.tween_callback(func(): _set_stream_and_play(stream))
        else:
                _set_stream_and_play(stream)
        _current_bgm = stream

## 终止当前活跃的Tween
func _kill_tween() -> void:
        if _tween and _tween.is_valid():
                _tween.kill()
        _audio_player.volume_db = 0

## 设置音频流并开始播放
func _set_stream_and_play(stream: AudioStream) -> void:
        _audio_player.volume_db = 0
        _audio_player.stream = stream
        _audio_player.play()
