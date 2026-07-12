extends Control
## 选项/设置界面 (OptionsScreen)
## 游戏设置: 音量/全屏/窗口模式/难度等

@onready var master_volume_slider: HSlider = $Panel/ScrollContainer/VBoxContainer/AudioSection/MasterVolume/MasterSlider
@onready var bgm_volume_slider: HSlider = $Panel/ScrollContainer/VBoxContainer/AudioSection/BGMVolume/BGMSlider
@onready var sfx_volume_slider: HSlider = $Panel/ScrollContainer/VBoxContainer/AudioSection/SFXVolume/SFXSlider
@onready var fullscreen_check: CheckBox = $Panel/ScrollContainer/VBoxContainer/VideoSection/FullscreenCheck
@onready var vsync_check: CheckBox = $Panel/ScrollContainer/VBoxContainer/VideoSection/VsyncCheck
@onready var back_button: Button = $Panel/BackButton
@onready var difficulty_selector: OptionButton = $Panel/ScrollContainer/VBoxContainer/GameSection/DifficultyRow/DifficultySelector

## 设置数据
var _settings: Dictionary = {
        "master_volume": 1.0,
        "bgm_volume": 0.8,
        "sfx_volume": 1.0,
        "fullscreen": false,
        "vsync": true,
}

func _ready() -> void:
        visible = false
        back_button.pressed.connect(close)

        # 连接信号
        master_volume_slider.value_changed.connect(_on_master_volume_changed)
        bgm_volume_slider.value_changed.connect(_on_bgm_volume_changed)
        sfx_volume_slider.value_changed.connect(_on_sfx_volume_changed)
        fullscreen_check.toggled.connect(_on_fullscreen_toggled)
        vsync_check.toggled.connect(_on_vsync_toggled)

        # 初始化难度选择器
        if difficulty_selector:
                difficulty_selector.clear()
                for diff in BattleBalance.get_all_difficulties():
                        difficulty_selector.add_item(diff.name)
                difficulty_selector.selected = BattleBalance.current_difficulty
                difficulty_selector.item_selected.connect(_on_difficulty_changed)

        # 加载设置
        _load_settings()

## 难度改变
func _on_difficulty_changed(index: int) -> void:
        BattleBalance.set_difficulty(index)
        # 保存到配置
        var config := ConfigFile.new()
        config.load("user://settings.cfg")
        config.set_value("game", "difficulty", index)
        config.save("user://settings.cfg")

## 加载设置
func _load_settings() -> void:
        var config := ConfigFile.new()
        var err := config.load("user://settings.cfg")
        if err == OK:
                _settings["master_volume"] = config.get_value("audio", "master_volume", 1.0)
                _settings["bgm_volume"] = config.get_value("audio", "bgm_volume", 0.8)
                _settings["sfx_volume"] = config.get_value("audio", "sfx_volume", 1.0)
                _settings["fullscreen"] = config.get_value("video", "fullscreen", false)
                _settings["vsync"] = config.get_value("video", "vsync", true)

        # 应用到UI
        master_volume_slider.value = _settings["master_volume"] * 100
        bgm_volume_slider.value = _settings["bgm_volume"] * 100
        sfx_volume_slider.value = _settings["sfx_volume"] * 100
        fullscreen_check.button_pressed = _settings["fullscreen"]
        vsync_check.button_pressed = _settings["vsync"]

        # 应用设置
        _apply_settings()

## 保存设置
func _save_settings() -> void:
        var config := ConfigFile.new()
        config.set_value("audio", "master_volume", _settings["master_volume"])
        config.set_value("audio", "bgm_volume", _settings["bgm_volume"])
        config.set_value("audio", "sfx_volume", _settings["sfx_volume"])
        config.set_value("video", "fullscreen", _settings["fullscreen"])
        config.set_value("video", "vsync", _settings["vsync"])
        config.save("user://settings.cfg")

## 应用设置
func _apply_settings() -> void:
        # 音量
        AudioServer.set_bus_volume_db(0, linear_to_db(_settings["master_volume"]))
        # BGM和SFX总线 (如果存在)
        if AudioServer.get_bus_count() > 1:
                AudioServer.set_bus_volume_db(1, linear_to_db(_settings["bgm_volume"]))
        if AudioServer.get_bus_count() > 2:
                AudioServer.set_bus_volume_db(2, linear_to_db(_settings["sfx_volume"]))

        # 视频
        DisplayServer.window_set_mode(
                DisplayServer.WINDOW_MODE_FULLSCREEN if _settings["fullscreen"] else DisplayServer.WINDOW_MODE_WINDOWED
        )
        DisplayServer.window_set_vsync_mode(
                DisplayServer.VSYNC_ENABLED if _settings["vsync"] else DisplayServer.VSYNC_DISABLED
        )

## 主音量改变
func _on_master_volume_changed(value: float) -> void:
        _settings["master_volume"] = value / 100.0
        _apply_settings()
        _save_settings()

## BGM音量改变
func _on_bgm_volume_changed(value: float) -> void:
        _settings["bgm_volume"] = value / 100.0
        _apply_settings()
        _save_settings()

## SFX音量改变
func _on_sfx_volume_changed(value: float) -> void:
        _settings["sfx_volume"] = value / 100.0
        _apply_settings()
        _save_settings()

## 全屏切换
func _on_fullscreen_toggled(toggled: bool) -> void:
        _settings["fullscreen"] = toggled
        _apply_settings()
        _save_settings()

## VSync切换
func _on_vsync_toggled(toggled: bool) -> void:
        _settings["vsync"] = toggled
        _apply_settings()
        _save_settings()

## 打开设置
func open() -> void:
        visible = true

## 关闭设置
func close() -> void:
        visible = false
        queue_free()

func _input(event: InputEvent) -> void:
        if visible and event.is_action_pressed("ui_cancel"):
                close()
