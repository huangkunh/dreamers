extends Control

const OUTPUT_DIR := "/workspace/godot_flow_screenshots"

var _failures: Array[String] = []

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1280, 720))
	get_viewport().transparent_bg = false
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	await get_tree().process_frame
	await _prepare_game_state()
	await _capture_core_flow()
	_write_report()
	if _failures.is_empty():
		print("[FlowCapture] PASS")
		get_tree().quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		get_tree().quit(1)

func _prepare_game_state() -> void:
	var game_manager := get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("_init_game_data"):
		game_manager.call("_init_game_data")

func _capture_core_flow() -> void:
	await _capture_scene("01_title_screen", "res://scenes/ui/title_screen.tscn")
	await _capture_scene("02_options_screen", "res://scenes/ui/options_screen.tscn", "open")
	await _capture_scene("03_help_screen", "res://scenes/ui/help_screen.tscn", "open")
	await _capture_scene("04_world_map", "res://scenes/ui/world_map.tscn")
	await _capture_scene("05_pause_menu", "res://scenes/ui/pause_menu.tscn")
	await _capture_scene("06_save_screen", "res://scenes/ui/save_load_screen.tscn", "open_save")
	await _capture_scene("07_load_screen", "res://scenes/ui/save_load_screen.tscn", "open_load")
	await _capture_shop()
	await _capture_scene("09_tank_garage", "res://scenes/ui/tank_garage.tscn", "open_garage")
	await _capture_scene("10_bounty_guild", "res://scenes/ui/bounty_guild.tscn", "open_guild")
	await _capture_victory()
	await _capture_drops()
	await _capture_scene("13_game_over", "res://scenes/ui/game_over_screen.tscn", "show_game_over")
	await _capture_scene("14_aoduo_base", "res://scenes/city/aoduo_base.tscn")
	await _capture_scene("15_wasteland", "res://scenes/city/wasteland.tscn")
	await _capture_scene("16_abandoned_factory", "res://scenes/world/abandoned_factory.tscn")
	await _capture_scene("17_ant_nest", "res://scenes/world/ant_nest.tscn")
	await _capture_scene("18_ancient_ruins", "res://scenes/world/ancient_ruins.tscn")
	await _capture_scene("19_battle_scene", "res://scenes/HUD/fight/fight.tscn")

func _capture_shop() -> void:
	var items := [
		{"id": "potion", "name": "恢复药", "description": "恢复 50 HP", "type": 0, "price": 30, "stackable": true},
		{"id": "slingshot", "name": "弹弓", "description": "简单的远程武器", "type": 1, "price": 80, "attack": 3},
	]
	await _capture_scene_with_callable("08_shop_system", "res://scenes/ui/shop_system.tscn", func(node):
		node.open_shop("测试商店", items)
	)

func _capture_victory() -> void:
	await _capture_scene_with_callable("11_battle_victory", "res://scenes/ui/battle_victory_screen.tscn", func(node):
		node.show_victory(120, 80, [{"name": "雷班纳", "old_level": 1, "new_level": 2}])
	)

func _capture_drops() -> void:
	await _capture_scene_with_callable("12_battle_drops", "res://scenes/ui/battle_drop_display.tscn", func(node):
		node.show_drops([{"id": "scrap", "name": "废铁", "type": 4, "count": 2}])
	)

func _capture_scene(name: String, path: String, method: String = "") -> void:
	await _capture_scene_with_callable(name, path, func(node):
		if not method.is_empty() and node.has_method(method):
			node.call(method)
	)

func _capture_scene_with_callable(name: String, path: String, setup: Callable) -> void:
	get_tree().paused = false
	var packed := load(path)
	if packed == null:
		_failures.append("无法加载场景: %s" % path)
		return
	var node = packed.instantiate()
	add_child(node)
	await get_tree().process_frame
	if setup.is_valid():
		setup.call(node)
	get_tree().paused = false
	await _wait_frames(6)
	await _save_screenshot(name)
	node.queue_free()
	await get_tree().process_frame
	get_tree().paused = false

func _wait_frames(count: int) -> void:
	for i in range(count):
		await get_tree().process_frame

func _save_screenshot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	var output_path := "%s/%s.png" % [OUTPUT_DIR, name]
	var err := image.save_png(output_path)
	if err != OK:
		_failures.append("截图保存失败: %s err=%s" % [output_path, err])
	else:
		print("[FlowCapture] saved %s" % output_path)

func _write_report() -> void:
	var report_path := "%s/flow_capture_report.txt" % OUTPUT_DIR
	var file := FileAccess.open(report_path, FileAccess.WRITE)
	if file == null:
		return
	file.store_line("Godot 4.3 场景流程截图测试")
	file.store_line("截图目录: %s" % OUTPUT_DIR)
	file.store_line("失败数量: %d" % _failures.size())
	for failure in _failures:
		file.store_line("- %s" % failure)
	file.close()
