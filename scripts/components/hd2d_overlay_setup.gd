extends Node
## HD-2D 场景叠层快捷设置组件
## 挂载到场景根节点下，自动配置暗角/景深/像素增强叠层
## 使用方式：在场景中添加 Node 节点并附加此脚本

@export var preset: String = "city"  ## 预设名称: city/wasteland/dungeon/battle/title
@export var enable_vignette: bool = true
@export var enable_dof: bool = true
@export var enable_pixel_enhance: bool = true

const VIGNETTE_SHADER := preload("res://scripts/shader/vignette.gdshader")
const DOF_SHADER := preload("res://scripts/shader/depth_of_field.gdshader")
const HD2D_SHADER := preload("res://scripts/shader/hd2d_enhance.gdshader")

## 预设配置表
const PRESETS := {
	"city": {
		"vignette_intensity": 0.45, "vignette_color": Color.BLACK,
		"dof_strength": 2.0, "dof_radius": 3.0, "dof_center": 0.5,
		"pixel_size": 2.0, "edge_highlight": 0.3, "saturation": 1.15, "contrast": 1.1, "color_temp": 0.1,
	},
	"wasteland": {
		"vignette_intensity": 0.7, "vignette_color": Color.BLACK,
		"dof_strength": 1.5, "dof_radius": 4.0, "dof_center": 0.5,
		"pixel_size": 2.0, "edge_highlight": 0.25, "saturation": 1.1, "contrast": 1.15, "color_temp": 0.15,
	},
	"dungeon": {
		"vignette_intensity": 0.85, "vignette_color": Color(0.02, 0.01, 0.0, 1),
		"dof_strength": 2.5, "dof_radius": 2.5, "dof_center": 0.5,
		"pixel_size": 2.0, "edge_highlight": 0.25, "saturation": 1.05, "contrast": 1.1, "color_temp": -0.05,
	},
	"battle": {
		"vignette_intensity": 0.6, "vignette_color": Color.BLACK,
		"dof_strength": 2.0, "dof_radius": 2.0, "dof_center": 0.5,
		"pixel_size": 2.0, "edge_highlight": 0.3, "saturation": 1.2, "contrast": 1.2, "color_temp": 0.0,
	},
	"title": {
		"vignette_intensity": 0.8, "vignette_color": Color.BLACK,
		"dof_strength": 3.0, "dof_radius": 4.0, "dof_center": 0.5,
		"pixel_size": 2.0, "edge_highlight": 0.2, "saturation": 1.2, "contrast": 1.15, "color_temp": 0.15,
	},
}

var _canvas_layer: CanvasLayer
var _vignette_rect: ColorRect
var _dof_rect: ColorRect
var _hd2d_rect: ColorRect

func _ready() -> void:
	# 如果场景已有自己的叠层，跳过
	if _has_existing_overlays():
		return
	_setup_overlays()
	# 禁用全局 Hd2dManager 避免双重叠层
	if Hd2dManager:
		Hd2dManager.set_enabled(false)

func _has_existing_overlays() -> bool:
	# 检查场景是否已有 vignette/DOF overlay
	for child in get_parent().get_children():
		if child is ColorRect and child.name in ["VignetteOverlay", "VignetteRect", "DOFOverlay", "DOFRect"]:
			return true
	return false

func _setup_overlays() -> void:
	var p: Dictionary = PRESETS.get(preset, PRESETS["city"])

	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 100
	get_parent().add_child(_canvas_layer)

	if enable_vignette:
		_vignette_rect = ColorRect.new()
		_vignette_rect.name = "VignetteOverlay"
		_vignette_rect.material = ShaderMaterial.new()
		(_vignette_rect.material as ShaderMaterial).shader = VIGNETTE_SHADER
		(_vignette_rect.material as ShaderMaterial).set_shader_parameter("vignette_intensity", p["vignette_intensity"])
		(_vignette_rect.material as ShaderMaterial).set_shader_parameter("vignette_color", p["vignette_color"])
		_setup_full_rect(_vignette_rect)
		_canvas_layer.add_child(_vignette_rect)

	if enable_dof:
		_dof_rect = ColorRect.new()
		_dof_rect.name = "DOFOverlay"
		_dof_rect.material = ShaderMaterial.new()
		(_dof_rect.material as ShaderMaterial).shader = DOF_SHADER
		(_dof_rect.material as ShaderMaterial).set_shader_parameter("blur_strength", p["dof_strength"])
		(_dof_rect.material as ShaderMaterial).set_shader_parameter("blur_radius", p["dof_radius"])
		(_dof_rect.material as ShaderMaterial).set_shader_parameter("center_focus", p["dof_center"])
		(_dof_rect.material as ShaderMaterial).set_shader_parameter("vignette_color", Vector4(p["vignette_color"].r, p["vignette_color"].g, p["vignette_color"].b, 1.0))
		(_dof_rect.material as ShaderMaterial).set_shader_parameter("vignette_intensity", p["vignette_intensity"] * 0.5)
		_setup_full_rect(_dof_rect)
		_canvas_layer.add_child(_dof_rect)

	if enable_pixel_enhance:
		_hd2d_rect = ColorRect.new()
		_hd2d_rect.name = "HD2DEnhanceOverlay"
		_hd2d_rect.material = ShaderMaterial.new()
		(_hd2d_rect.material as ShaderMaterial).shader = HD2D_SHADER
		(_hd2d_rect.material as ShaderMaterial).set_shader_parameter("pixel_size", p["pixel_size"])
		(_hd2d_rect.material as ShaderMaterial).set_shader_parameter("edge_highlight", p["edge_highlight"])
		(_hd2d_rect.material as ShaderMaterial).set_shader_parameter("saturation_boost", p["saturation"])
		(_hd2d_rect.material as ShaderMaterial).set_shader_parameter("contrast", p["contrast"])
		(_hd2d_rect.material as ShaderMaterial).set_shader_parameter("color_temperature", p["color_temp"])
		_setup_full_rect(_hd2d_rect)
		_canvas_layer.add_child(_hd2d_rect)

func _setup_full_rect(rect: ColorRect) -> void:
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.color = Color.BLACK
