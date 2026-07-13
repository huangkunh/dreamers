extends Area3D
## 绿洲/水源区域 (OasisZone)
## 玩家在此区域可以恢复生命值
## HD-2D视觉效果：水波纹、蓝绿色光效、生机粒子

## 玩家进入信号
signal player_entered
## 玩家离开信号
signal player_exited

## 每秒治疗量
@export var heal_per_second: float = 3.0
## 区域大小
@export var zone_size: Vector3 = Vector3(4, 2, 4)
## 是否激活
@export var is_active: bool = true
## 绿洲类型
@export_enum("oasis", "spring", "well") var oasis_type: String = "oasis"

## 玩家节点
var _player: Node = null
## 治疗计时器
var _heal_timer: float = 0.0
## 水面粒子
var _water_particles: GPUParticles3D = null
## 治愈光环
var _heal_light: OmniLight3D = null
## 水面网格
var _water_surface: MeshInstance3D = null
## 生机粒子
var _life_particles: GPUParticles3D = null

func _ready() -> void:
	# 创建碰撞形状
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	collision.shape = box
	add_child(collision)
	
	# 创建视觉效果
	_create_water_surface()
	_create_water_particles()
	_create_heal_light()
	_create_life_particles()
	
	# 连接信号
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# 初始状态
	if not is_active:
		_deactivate_oasis()

func _create_water_surface() -> void:
	_water_surface = MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(zone_size.x, zone_size.z)
	
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color = Color(0.2, 0.6, 0.8, 0.6)
	mat.metallic = 0.3
	mat.roughness = 0.2
	mat.emission_enabled = true
	mat.emission = Color(0.1, 0.4, 0.5)
	mat.emission_energy = 0.3
	
	plane.material = mat
	_water_surface.mesh = plane
	_water_surface.position = Vector3(0, 0.05, 0)
	add_child(_water_surface)

func _create_water_particles() -> void:
	_water_particles = GPUParticles3D.new()
	_water_particles.emitting = true
	
	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(zone_size.x / 2, 0.1, zone_size.z / 2)
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 10.0
	process_mat.initial_velocity_min = 0.2
	process_mat.initial_velocity_max = 0.5
	process_mat.gravity = Vector3(0, -0.1, 0)
	process_mat.scale_min = 0.05
	process_mat.scale_max = 0.1
	process_mat.color = Color(0.4, 0.7, 0.9, 0.5)
	
	_water_particles.process_material = process_mat
	_water_particles.amount = 30
	_water_particles.lifetime = 2.0
	_water_particles.visibility_aabb = AABB(Vector3(-zone_size.x/2, 0, -zone_size.z/2), Vector3(zone_size.x, 1, zone_size.z))
	
	# 创建粒子网格
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.08, 0.08)
	_water_particles.draw_pass_1 = mesh
	
	add_child(_water_particles)

func _create_heal_light() -> void:
	_heal_light = OmniLight3D.new()
	_heal_light.light_color = Color(0.4, 0.8, 0.6)
	_heal_light.light_energy = 1.0
	_heal_light.light_intensity = 1.2
	_heal_light.omni_range = zone_size.x * 0.8
	_heal_light.position = Vector3(0, 0.5, 0)
	add_child(_heal_light)

func _create_life_particles() -> void:
	_life_particles = GPUParticles3D.new()
	_life_particles.emitting = true
	
	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = Vector3(zone_size.x / 2, 0.5, zone_size.z / 2)
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 30.0
	process_mat.initial_velocity_min = 0.3
	process_mat.initial_velocity_max = 0.8
	process_mat.gravity = Vector3(0, 0.05, 0)
	process_mat.scale_min = 0.02
	process_mat.scale_max = 0.06
	process_mat.color = Color(0.6, 1.0, 0.7, 0.6)
	
	_life_particles.process_material = process_mat
	_life_particles.amount = 20
	_life_particles.lifetime = 3.0
	
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.04, 0.04)
	_life_particles.draw_pass_1 = mesh
	
	add_child(_life_particles)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = body
	player_entered.emit()
	
	if is_active:
		print("[OasisZone] 玩家进入绿洲区域 - 开始治疗")

func _on_body_exited(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	
	_player = null
	player_exited.emit()
	
	print("[OasisZone] 玩家离开绿洲区域")

func _process(delta: float) -> void:
	if not is_active or not _player:
		return
	
	# 持续治疗
	_heal_timer += delta
	if _heal_timer >= 1.0:
		_heal_timer = 0.0
		_apply_heal()
	
	# 水面动画
	if _water_surface:
		var time = Time.get_ticks_msec() / 1000.0
		_water_surface.position.y = 0.05 + sin(time * 2.0) * 0.02

func _apply_heal() -> void:
	# 检查玩家是否有治疗方法
	if _player.has_method("heal"):
		_player.heal(heal_per_second)
	elif _player.has_node("HealthComponent"):
		var health = _player.get_node("HealthComponent")
		if health.has_method("heal"):
			health.heal(heal_per_second)

func _deactivate_oasis() -> void:
	is_active = false
	if _water_particles:
		_water_particles.emitting = false
	if _life_particles:
		_life_particles.emitting = false
	if _heal_light:
		_heal_light.light_energy = 0

func activate_oasis() -> void:
	is_active = true
	if _water_particles:
		_water_particles.emitting = true
	if _life_particles:
		_life_particles.emitting = true
	if _heal_light:
		_heal_light.light_energy = 1.0