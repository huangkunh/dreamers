extends Area3D
## 放射性区域 (RadioactiveZone)
## 绿色辐射光效,对玩家造成持续伤害
## HD-2D视觉效果：绿色辉光、辐射粒子、警告标识

## 玩家进入信号
signal player_entered
## 玩家离开信号
signal player_exited

## 每秒伤害值
@export var damage_per_second: float = 5.0
## 辐射强度 (影响视觉效果)
@export_range(0.1, 1.0) var radiation_intensity: float = 0.6
## 区域大小
@export var zone_size: Vector3 = Vector3(6, 4, 6)
## 是否激活
@export var is_active: bool = true
## 辐射类型 (用于不同的视觉表现)
@export_enum("nuclear", "toxic", "alien") var radiation_type: String = "nuclear"

## 玩家节点
var _player: Node = null
## 伤害计时器
var _damage_timer: float = 0.0
## 辐射粒子系统
var _particles: GPUParticles3D = null
## 辐射光柱
var _glow_light: OmniLight3D = null
## 警告叠加层
var _warning_overlay: ColorRect = null
## 警告标签
var _warning_label: Label3D = null

func _ready() -> void:
	# 创建碰撞形状
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	collision.shape = box
	add_child(collision)
	
	# 创建视觉效果
	_create_radiation_particles()
	_create_radiation_light()
	_create_warning_elements()
	
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 初始状态
	if not is_active:
		_deactivate_zone()

func _create_radiation_particles() -> void:
	_particles = GPUParticles3D.new()
	_particles.emitting = true
	
	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = zone_size / 2.0
	process_mat.direction = Vector3(0, 1, 0)  # 向上飘动
	process_mat.spread = 20.0
	process_mat.initial_velocity_min = 0.5
	process_mat.initial_velocity_max = 1.5
	process_mat.gravity = Vector3(0, 0.2, 0)
	process_mat.scale_min = 0.03
	process_mat.scale_max = 0.08
	process_mat.color = _get_radiation_color()
	
	_particles.process_material = process_mat
	_particles.amount = int(100 * radiation_intensity)
	_particles.lifetime = 3.0
	_particles.visibility_aabb = AABB(-zone_size, zone_size * 2)
	
	# 创建粒子网格
	var mesh := QuadMesh.new()
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = _get_radiation_color()
	mat.emission_energy = 0.5
	mesh.material = mat
	mesh.size = Vector2(0.05, 0.05)
	_particles.draw_pass_1 = mesh
	
	add_child(_particles)

func _create_radiation_light() -> void:
	_glow_light = OmniLight3D.new()
	_glow_light.light_color = _get_radiation_color()
	_glow_light.light_energy = 1.5 * radiation_intensity
	_glow_light.light_intensity = 0.8
	_glow_light.omni_range = zone_size.x * 0.8
	_glow_light.position = Vector3.ZERO
	add_child(_glow_light)

func _create_warning_elements() -> void:
	# 创建警告叠加层
	var canvas := CanvasLayer.new()
	canvas.layer = 101
	
	_warning_overlay = ColorRect.new()
	_warning_overlay.color = Color(0.2, 1.0, 0.2, 0)  # 绿色调
	_warning_overlay.anchor_right = 1.0
	_warning_overlay.anchor_bottom = 1.0
	_warning_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warning_overlay.visible = false
	
	canvas.add_child(_warning_overlay)
	add_child(canvas)
	
	# 创建3D警告标签
	_warning_label = Label3D.new()
	_warning_label.text = "⚠ 辐射区域 RADIATION ⚠"
	_warning_label.font_size = 20
	_warning_label.modulate = Color(0.5, 1.0, 0.5, 1.0)
	_warning_label.outline_modulate = Color.BLACK
	_warning_label.outline_size = 4
	_warning_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_warning_label.no_depth_test = true
	_warning_label.position = Vector3(0, zone_size.y / 2 + 0.5, 0)
	add_child(_warning_label)

func _get_radiation_color() -> Color:
	match radiation_type:
		"nuclear":
			return Color(0.3, 1.0, 0.3, 0.5)
		"toxic":
			return Color(0.8, 1.0, 0.2, 0.5)
		"alien":
			return Color(0.5, 0.2, 1.0, 0.5)
		_:
			return Color(0.3, 1.0, 0.3, 0.5)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = body
	player_entered.emit()
	
	if is_active:
		_activate_warning()
		print("[RadioactiveZone] 玩家进入辐射区域!")

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = null
	player_exited.emit()
	
	_deactivate_warning()
	print("[RadioactiveZone] 玩家离开辐射区域")

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
		_player.take_damage(damage_per_second, "radiation")
	elif _player.has_node("HealthComponent"):
		var health = _player.get_node("HealthComponent")
		if health.has_method("take_damage"):
			health.take_damage(damage_per_second, "radiation")

func _activate_warning() -> void:
	if _warning_overlay:
		_warning_overlay.visible = true
		var tw := create_tween()
		tw.tween_property(_warning_overlay, "color:a", 0.15, 0.5)
		# 脉动效果
		_start_pulse_animation()

func _start_pulse_animation() -> void:
	while _player and is_active:
		var tw := create_tween()
		tw.tween_property(_warning_overlay, "color:a", 0.25, 0.8)
		await tw.finished
		if _player and is_active:
			tw = create_tween()
			tw.tween_property(_warning_overlay, "color:a", 0.1, 0.8)
			await tw.finished

func _deactivate_warning() -> void:
	if _warning_overlay:
		var tw := create_tween()
		tw.tween_property(_warning_overlay, "color:a", 0.0, 0.3)
		tw.tween_callback(func(): _warning_overlay.visible = false)

func _deactivate_zone() -> void:
	is_active = false
	if _particles:
		_particles.emitting = false
	if _glow_light:
		_glow_light.light_energy = 0

func activate_zone() -> void:
	is_active = true
	if _particles:
		_particles.emitting = true
	if _glow_light:
		_glow_light.light_energy = 1.5 * radiation_intensity