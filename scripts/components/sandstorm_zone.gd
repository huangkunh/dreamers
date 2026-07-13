extends Area3D
## 沙尘暴区域 (SandstormZone)
## 降低视野并对玩家造成伤害
## HD-2D视觉效果：沙尘粒子、风声、视野模糊

## 玩家进入信号
signal player_entered
## 玩家离开信号
signal player_exited

## 每秒伤害值
@export var damage_per_second: float = 2.0
## 视野降低百分比 (0-1)
@export var visibility_reduction: float = 0.6
## 沙尘暴强度 (影响粒子密度)
@export_range(0.1, 1.0) var storm_intensity: float = 0.7
## 区域大小
@export var zone_size: Vector3 = Vector3(10, 5, 10)
## 是否激活
@export var is_active: bool = true

## 玩家节点
var _player: Node = null
## 伤害计时器
var _damage_timer: float = 0.0
## 粒子系统
var _particles: GPUParticles3D = null
## 风声播放器
var _wind_audio: AudioStreamPlayer3D = null
## 视觉效果叠加层
var _overlay: ColorRect = null

func _ready() -> void:
	# 创建碰撞形状
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	collision.shape = box
	add_child(collision)
	
	# 创建沙尘粒子
	_create_sand_particles()
	
	# 创建风声
	_create_wind_audio()
	
	# 创建视野模糊叠加层
	_create_visibility_overlay()
	
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 初始状态
	if not is_active:
		_deactivate_storm()

func _create_sand_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.emitting = false
	
	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = zone_size / 2.0
	process_mat.direction = Vector3(-1, 0, 0)  # 风向
	process_mat.spread = 30.0
	process_mat.initial_velocity_min = 8.0 * storm_intensity
	process_mat.initial_velocity_max = 15.0 * storm_intensity
	process_mat.gravity = Vector3(0, -0.5, 0)
	process_mat.scale_min = 0.05
	process_mat.scale_max = 0.15
	process_mat.color = Color(0.76, 0.6, 0.42, 0.6)
	
	_particles.process_material = process_mat
	_particles.amount = int(200 * storm_intensity)
	_particles.lifetime = 2.0
	_particles.visibility_aabb = AABB(-zone_size, zone_size * 2)
	
	# 创建粒子网格
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.1, 0.1)
	_particles.draw_pass_1 = mesh
	
	add_child(_particles)

func _create_wind_audio() -> void:
	_wind_audio = AudioStreamPlayer3D.new()
	_wind_audio.volume_db = -10.0
	_wind_audio.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_SQUARE_DISTANCE
	_wind_audio.unit_size = zone_size.x
	
	# 尝试加载风声
	var wind_stream = load("res://music/sound_effect/wind.ogg")
	if wind_stream:
		_wind_audio.stream = wind_stream
	
	add_child(_wind_audio)

func _create_visibility_overlay() -> void:
	# 创建CanvasLayer用于全局叠加效果
	var canvas := CanvasLayer.new()
	canvas.layer = 100  # 确保在最上层
	
	_overlay = ColorRect.new()
	_overlay.color = Color(0.76, 0.65, 0.45, 0)
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.visible = false
	
	canvas.add_child(_overlay)
	add_child(canvas)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = body
	player_entered.emit()
	
	if is_active:
		_activate_storm_effects()
		print("[SandstormZone] 玩家进入沙尘暴区域")

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = null
	player_exited.emit()
	
	_deactivate_storm_effects()
	print("[SandstormZone] 玩家离开沙尘暴区域")

func _process(delta: float) -> void:
	if not is_active or not _player:
		return
	
	# 造成伤害
	_damage_timer += delta
	if _damage_timer >= 1.0:
		_damage_timer = 0.0
		_apply_damage()

func _apply_damage() -> void:
	# 检查玩家是否有受伤方法
	if _player.has_method("take_damage"):
		_player.take_damage(damage_per_second, "sandstorm")
	elif _player.has_node("HealthComponent"):
		var health = _player.get_node("HealthComponent")
		if health.has_method("take_damage"):
			health.take_damage(damage_per_second, "sandstorm")

func _activate_storm_effects() -> void:
	if _particles:
		_particles.emitting = true
	if _wind_audio:
		_wind_audio.play()
	if _overlay:
		_overlay.visible = true
		var tw := create_tween()
		tw.tween_property(_overlay, "color:a", visibility_reduction * 0.3, 0.5)

func _deactivate_storm_effects() -> void:
	if _particles:
		_particles.emitting = false
	if _wind_audio:
		_wind_audio.stop()
	if _overlay:
		var tw := create_tween()
		tw.tween_property(_overlay, "color:a", 0.0, 0.5)
		tw.tween_callback(func(): _overlay.visible = false)

func _deactivate_storm() -> void:
	is_active = false
	_deactivate_storm_effects()

func activate_storm() -> void:
	is_active = true
	if _player:
		_activate_storm_effects()