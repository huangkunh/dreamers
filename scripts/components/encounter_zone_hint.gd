extends Node3D
## 随机遇敌区域视觉提示 (EncounterZoneHint)
## 显示该区域可能遇敌的视觉效果
## HD-2D风格：微妙的警告粒子、区域边界标记

## 区域大小
@export var zone_size: Vector3 = Vector3(8, 3, 8)
## 遇敌概率 (显示强度)
@export_range(0.01, 0.1) var encounter_rate: float = 0.03
## 区域名称 (用于敌人类型)
@export var area_name: String = "wasteland"
## 警告颜色
@export var warning_color: Color = Color(0.6, 0.3, 0.15, 0.4)
## 是否显示边界
@export var show_boundary: bool = true

## 警告粒子
var _warning_particles: GPUParticles3D = null
## 区域边界网格
var _boundary_mesh: MeshInstance3D = null
## 区域提示标签
var _hint_label: Label3D = null
## 脉动计时器
var _pulse_timer: float = 0.0

func _ready() -> void:
	_create_warning_particles()
	if show_boundary:
		_create_boundary_mesh()
	_create_hint_label()

func _create_warning_particles() -> void:
	_warning_particles = GPUParticles3D.new()
	_warning_particles.emitting = true
	
	var process_mat := ParticleProcessMaterial.new()
	process_mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process_mat.emission_box_extents = zone_size / 2.0
	process_mat.direction = Vector3(0, 1, 0)
	process_mat.spread = 15.0
	process_mat.initial_velocity_min = 0.1
	process_mat.initial_velocity_max = 0.3
	process_mat.gravity = Vector3(0, 0.05, 0)
	process_mat.scale_min = 0.02
	process_mat.scale_max = 0.05
	process_mat.color = warning_color
	
	_warning_particles.process_material = process_mat
	_warning_particles.amount = int(20 + encounter_rate * 100)
	_warning_particles.lifetime = 4.0
	_warning_particles.visibility_aabb = AABB(-zone_size, zone_size * 2)
	
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.03, 0.03)
	_warning_particles.draw_pass_1 = mesh
	
	add_child(_warning_particles)

func _create_boundary_mesh() -> void:
	_boundary_mesh = MeshInstance3D.new()
	
	# 创建简单的盒子轮廓
	var mesh := ArrayMesh.new()
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	
	# 创建边界线框顶点
	var vertices := PackedVector3Array()
	var size := zone_size / 2.0
	
	# 底部四条边
	vertices.append(Vector3(-size.x, 0, -size.z))
	vertices.append(Vector3(size.x, 0, -size.z))
	vertices.append(Vector3(size.x, 0, -size.z))
	vertices.append(Vector3(size.x, 0, size.z))
	vertices.append(Vector3(size.x, 0, size.z))
	vertices.append(Vector3(-size.x, 0, size.z))
	vertices.append(Vector3(-size.x, 0, size.z))
	vertices.append(Vector3(-size.x, 0, -size.z))
	
	# 顶部四条边
	vertices.append(Vector3(-size.x, size.y, -size.z))
	vertices.append(Vector3(size.x, size.y, -size.z))
	vertices.append(Vector3(size.x, size.y, -size.z))
	vertices.append(Vector3(size.x, size.y, size.z))
	vertices.append(Vector3(size.x, size.y, size.z))
	vertices.append(Vector3(-size.x, size.y, size.z))
	vertices.append(Vector3(-size.x, size.y, size.z))
	vertices.append(Vector3(-size.x, size.y, -size.z))
	
	# 四条垂直边
	vertices.append(Vector3(-size.x, 0, -size.z))
	vertices.append(Vector3(-size.x, size.y, -size.z))
	vertices.append(Vector3(size.x, 0, -size.z))
	vertices.append(Vector3(size.x, size.y, -size.z))
	vertices.append(Vector3(size.x, 0, size.z))
	vertices.append(Vector3(size.x, size.y, size.z))
	vertices.append(Vector3(-size.x, 0, size.z))
	vertices.append(Vector3(-size.x, size.y, size.z))
	
	arrays[Mesh.ARRAY_VERTEX] = vertices
	
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	
	var mat := StandardMaterial3D.new()
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = warning_color
	mat.emission_enabled = true
	mat.emission = warning_color
	mat.emission_energy = 0.3
	
	mesh.surface_set_material(0, mat)
	_boundary_mesh.mesh = mesh
	
	add_child(_boundary_mesh)

func _create_hint_label() -> void:
	_hint_label = Label3D.new()
	_hint_label.text = "⚠ 随机遇敌区域"
	_hint_label.font_size = 16
	_hint_label.modulate = Color(0.8, 0.5, 0.2, 0.6)
	_hint_label.outline_modulate = Color.BLACK
	_hint_label.outline_size = 3
	_hint_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_hint_label.no_depth_test = true
	_hint_label.position = Vector3(0, zone_size.y + 0.3, 0)
	add_child(_hint_label)

func _process(delta: float) -> void:
	# 脉动效果 - 让警告更明显但不刺眼
	_pulse_timer += delta
	
	if _warning_particles:
		var intensity := 0.5 + sin(_pulse_timer * 2.0) * 0.3
		var mat := _warning_particles.process_material as ParticleProcessMaterial
		if mat:
			mat.color.a = warning_color.a * intensity
	
	if _boundary_mesh and _boundary_mesh.mesh:
		var intensity := 0.3 + sin(_pulse_timer * 2.0) * 0.2
		var mat := _boundary_mesh.mesh.surface_get_material(0) as StandardMaterial3D
		if mat:
			mat.albedo_color.a = warning_color.a * intensity
			mat.emission_energy = intensity
	
	if _hint_label:
		var intensity := 0.5 + sin(_pulse_timer * 1.5) * 0.3
		_hint_label.modulate.a = intensity

func set_visible_hint(visible: bool) -> void:
	if _warning_particles:
		_warning_particles.emitting = visible
	if _boundary_mesh:
		_boundary_mesh.visible = visible
	if _hint_label:
		_hint_label.visible = visible