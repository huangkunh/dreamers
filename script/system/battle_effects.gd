extends Node
## 战斗特效管理器 (BattleEffects)
## 管理战斗中的视觉特效: 屏幕震动、闪光、粒子、伤害数字

## 屏幕震动
func screen_shake(camera: Camera3D, intensity: float = 0.15, duration: float = 0.3) -> void:
	if not camera:
		return
	var orig_pos := camera.position
	var tween := camera.create_tween()
	var steps := int(duration / 0.05)
	for i in range(steps):
		var shake := Vector3(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "position", orig_pos + shake, 0.05)
	tween.tween_property(camera, "position", orig_pos, 0.05)

## 闪光特效 (全屏)
func flash_screen(color_rect: ColorRect, color: Color, duration: float = 0.15) -> void:
	if not color_rect:
		return
	color_rect.color = color
	color_rect.visible = true
	var tween := color_rect.create_tween()
	tween.tween_property(color_rect, "color:a", 0.0, duration)
	tween.tween_callback(func(): color_rect.visible = false)

## 技能特效 (在目标位置)
func spawn_skill_effect(parent: Node3D, position: Vector3, effect_type: String) -> void:
	match effect_type:
		"slash":
			_spawn_slash_effect(parent, position)
		"explosion":
			_spawn_explosion_effect(parent, position)
		"flame":
			_spawn_flame_effect(parent, position)
		"acid":
			_spawn_acid_effect(parent, position)
		"heal":
			_spawn_heal_effect(parent, position)

## 普通斩击特效
func _spawn_slash_effect(parent: Node3D, pos: Vector3) -> void:
	var slash := MeshInstance3D.new()
	slash.position = pos
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.8, 0.8)
	slash.mesh = mesh
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1, 1, 0.8, 1)
	mat.emission_enabled = true
	mat.emission = Color(1, 1, 0.6)
	mat.emission_energy_multiplier = 2.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	slash.material_override = mat
	parent.add_child(slash)
	
	var tween := slash.create_tween()
	tween.tween_property(slash, "scale", Vector3(1.5, 1.5, 1.5), 0.15)
	tween.parallel().tween_property(mat, "albedo_color:a", 0.0, 0.2)
	tween.tween_callback(slash.queue_free)

## 爆炸特效
func _spawn_explosion_effect(parent: Node3D, pos: Vector3) -> void:
	var explosion := CPUParticles3D.new()
	explosion.position = pos
	explosion.amount = 30
	explosion.lifetime = 0.5
	explosion.one_shot = true
	explosion.emitting = true
	
	explosion.direction = Vector3(0, 1, 0)
	explosion.spread = 30.0
	explosion.initial_velocity_min = 2.0
	explosion.initial_velocity_max = 5.0
	explosion.gravity = Vector3(0, -5, 0)
	explosion.scale_amount_min = 0.1
	explosion.scale_amount_max = 0.3
	explosion.color = Color(1, 0.6, 0.2, 1)
	
	parent.add_child(explosion)
	
	# 自动清理
	var tween := parent.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(explosion.queue_free)

## 火焰特效
func _spawn_flame_effect(parent: Node3D, pos: Vector3) -> void:
	var flame := CPUParticles3D.new()
	flame.position = pos
	flame.amount = 20
	flame.lifetime = 0.6
	flame.one_shot = true
	flame.emitting = true
	
	flame.direction = Vector3(0, 1, 0)
	flame.spread = 15.0
	flame.initial_velocity_min = 1.0
	flame.initial_velocity_max = 3.0
	flame.color = Color(1, 0.3, 0.1, 1)
	flame.scale_amount_min = 0.15
	flame.scale_amount_max = 0.4
	
	parent.add_child(flame)
	
	var tween := parent.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(flame.queue_free)

## 酸液特效
func _spawn_acid_effect(parent: Node3D, pos: Vector3) -> void:
	var acid := CPUParticles3D.new()
	acid.position = pos
	acid.amount = 15
	acid.lifetime = 0.5
	acid.one_shot = true
	acid.emitting = true
	
	acid.direction = Vector3(0, -1, 0)
	acid.spread = 45.0
	acid.initial_velocity_min = 1.0
	acid.initial_velocity_max = 3.0
	acid.gravity = Vector3(0, -8, 0)
	acid.color = Color(0.3, 1, 0.2, 0.8)
	acid.scale_amount_min = 0.1
	acid.scale_amount_max = 0.25
	
	parent.add_child(acid)
	
	var tween := parent.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(acid.queue_free)

## 治疗特效
func _spawn_heal_effect(parent: Node3D, pos: Vector3) -> void:
	var heal := CPUParticles3D.new()
	heal.position = pos + Vector3(0, 0.5, 0)
	heal.amount = 12
	heal.lifetime = 0.8
	heal.one_shot = true
	heal.emitting = true
	
	heal.direction = Vector3(0, 1, 0)
	heal.spread = 20.0
	heal.initial_velocity_min = 0.5
	heal.initial_velocity_max = 1.5
	heal.gravity = Vector3(0, 2, 0)
	heal.color = Color(0.3, 1, 0.5, 0.8)
	heal.scale_amount_min = 0.1
	heal.scale_amount_max = 0.2
	
	parent.add_child(heal)
	
	var tween := parent.create_tween()
	tween.tween_interval(1.0)
	tween.tween_callback(heal.queue_free)
